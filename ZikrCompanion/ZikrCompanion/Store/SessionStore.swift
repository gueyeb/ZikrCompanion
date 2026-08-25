import Foundation
import Combine

// MARK: - SessionStore

@MainActor
final class SessionStore: ObservableObject {

    // MARK: - Published state

    @Published private(set) var count: Int = 0
    @Published private(set) var streak: Int = 0
    @Published private(set) var isSessionComplete: Bool = false
    @Published private(set) var history: [SessionRecord] = []
    @Published var selectedRoutine: RoutineType = .morning
    @Published var reminderHour: Int = 7
    @Published var reminderMinute: Int = 0
    @Published var isReminderEnabled: Bool = false

    // MARK: - UserDefaults keys

    private enum Keys {
        static let count           = "zc_count"
        static let countDate       = "zc_countDate"
        static let streak          = "zc_streak"
        static let lastSessionDate = "zc_lastSessionDate"
        static let selectedRoutine = "zc_selectedRoutine"
        static let reminderHour    = "zc_reminderHour"
        static let reminderMinute  = "zc_reminderMinute"
        static let reminderEnabled = "zc_reminderEnabled"
        static let history         = "zc_history"
    }

    private let defaults: UserDefaults
    private let calendar: Calendar
    private let now: () -> Date

    // MARK: - Init

    init(
        defaults: UserDefaults = .standard,
        calendar: Calendar = .current,
        now: @escaping () -> Date = { .now }
    ) {
        self.defaults = defaults
        self.calendar = calendar
        self.now = now
        load()
    }

    // MARK: - Public actions

    /// Incrémente le compteur de 1. Retourne le nouveau total.
    @discardableResult
    func increment() -> Int {
        refreshForCurrentDay()
        count += 1
        saveCount()
        if count >= selectedRoutine.target && !isSessionComplete {
            completeSession()
        }
        return count
    }

    /// Décrémente le compteur de 1 (mode chapelet).
    func decrement() {
        refreshForCurrentDay()
        guard count > 0 else { return }
        count -= 1
        if isSessionComplete { isSessionComplete = false }
        saveCount()
    }

    /// Remet le compteur à zéro sans toucher au streak.
    func resetCount() {
        refreshForCurrentDay()
        count = 0
        isSessionComplete = false
        saveCount()
    }

    /// Change de routine et remet le compteur à 0.
    func selectRoutine(_ routine: RoutineType) {
        refreshForCurrentDay()
        guard routine != selectedRoutine else { return }
        selectedRoutine = routine
        resetCount()
        defaults.set(routine.rawValue, forKey: Keys.selectedRoutine)
    }

    // MARK: - Session completion + streak (idempotent)

    private func completeSession() {
        isSessionComplete = true
        let today = calendar.startOfDay(for: now())
        let lastDate = defaults.object(forKey: Keys.lastSessionDate) as? Date
        let lastDay = lastDate.map { calendar.startOfDay(for: $0) }

        recordCompletedSession(on: today)

        // Idempotent : ne s'incrémente qu'une fois par jour
        if lastDay != today {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)
            if lastDay == yesterday {
                streak += 1
            } else if lastDay == nil {
                streak = 1
            } else {
                // Rupture de série
                streak = 1
            }
            defaults.set(today, forKey: Keys.lastSessionDate)
            defaults.set(streak, forKey: Keys.streak)
        }
    }

    // MARK: - Persistence

    private func load() {
        loadHistory()
        refreshForCurrentDay()

        if let raw = defaults.string(forKey: Keys.selectedRoutine),
           let routine = RoutineType(rawValue: raw) {
            selectedRoutine = routine
        }

        reminderHour      = defaults.object(forKey: Keys.reminderHour) as? Int ?? 7
        reminderMinute    = defaults.object(forKey: Keys.reminderMinute) as? Int ?? 0
        isReminderEnabled = defaults.bool(forKey: Keys.reminderEnabled)

        restoreCompletionState()
    }

    /// Réconcilie l'état sauvegardé avec le jour courant.
    /// À appeler lorsque l'app redevient active et avant toute mutation du compteur.
    func refreshForCurrentDay() {
        let today = calendar.startOfDay(for: now())

        let savedCount = defaults.integer(forKey: Keys.count)
        if let countDate = defaults.object(forKey: Keys.countDate) as? Date {
            let savedDay = calendar.startOfDay(for: countDate)
            if savedDay == today {
                count = savedCount
            } else {
                count = 0
                isSessionComplete = false
                defaults.set(0, forKey: Keys.count)
                defaults.set(today, forKey: Keys.countDate)
            }
        } else {
            count = savedCount
        }

        streak = defaults.integer(forKey: Keys.streak)
        if let lastDate = defaults.object(forKey: Keys.lastSessionDate) as? Date {
            let lastDay = calendar.startOfDay(for: lastDate)
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)
            if lastDay != today && lastDay != yesterday {
                streak = 0
                defaults.set(0, forKey: Keys.streak)
            }
        }
    }

    private func saveCount() {
        defaults.set(count, forKey: Keys.count)
        defaults.set(now(), forKey: Keys.countDate)
    }

    private func restoreCompletionState() {
        let today = calendar.startOfDay(for: now())
        let hasHistoryRecord = history.contains {
            $0.routineType == selectedRoutine
                && calendar.isDate($0.completedAt, inSameDayAs: today)
        }
        let legacyCompletionDate = defaults.object(forKey: Keys.lastSessionDate) as? Date
        let completedTodayBeforeHistory = legacyCompletionDate.map {
            calendar.isDate($0, inSameDayAs: today)
        } ?? false

        isSessionComplete = count >= selectedRoutine.target
            && (hasHistoryRecord || completedTodayBeforeHistory)

        if isSessionComplete && !hasHistoryRecord {
            recordCompletedSession(on: today)
        }
    }

    private func recordCompletedSession(on day: Date) {
        let alreadyRecorded = history.contains {
            $0.routineType == selectedRoutine
                && calendar.isDate($0.completedAt, inSameDayAs: day)
        }
        guard !alreadyRecorded else { return }

        history.insert(
            SessionRecord(
                completedAt: now(),
                routineType: selectedRoutine,
                completedCount: count
            ),
            at: 0
        )
        saveHistory()
    }

    private func loadHistory() {
        guard let data = defaults.data(forKey: Keys.history),
              let records = try? JSONDecoder().decode([SessionRecord].self, from: data) else {
            history = []
            return
        }
        history = records.sorted { $0.completedAt > $1.completedAt }
    }

    private func saveHistory() {
        guard let data = try? JSONEncoder().encode(history) else { return }
        defaults.set(data, forKey: Keys.history)
    }

    func saveReminderSettings() {
        defaults.set(reminderHour,    forKey: Keys.reminderHour)
        defaults.set(reminderMinute,  forKey: Keys.reminderMinute)
        defaults.set(isReminderEnabled, forKey: Keys.reminderEnabled)
    }

    // MARK: - Computed helpers

    var currentTarget: Int { selectedRoutine.target }
    var progress: Double { min(Double(count) / Double(currentTarget), 1.0) }
    var remaining: Int { max(currentTarget - count, 0) }
}
