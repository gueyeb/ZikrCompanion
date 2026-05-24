import Foundation
import Combine

// MARK: - SessionStore

@MainActor
final class SessionStore: ObservableObject {

    // MARK: - Published state

    @Published private(set) var count: Int = 0
    @Published private(set) var streak: Int = 0
    @Published private(set) var isSessionComplete: Bool = false
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
    }

    private let defaults: UserDefaults

    // MARK: - Init

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    // MARK: - Public actions

    /// Incrémente le compteur de 1. Retourne le nouveau total.
    @discardableResult
    func increment() -> Int {
        count += 1
        saveCount()
        if count >= selectedRoutine.target && !isSessionComplete {
            completeSession()
        }
        return count
    }

    /// Décrémente le compteur de 1 (mode chapelet).
    func decrement() {
        guard count > 0 else { return }
        count -= 1
        if isSessionComplete { isSessionComplete = false }
        saveCount()
    }

    /// Remet le compteur à zéro sans toucher au streak.
    func resetCount() {
        count = 0
        isSessionComplete = false
        saveCount()
    }

    /// Change de routine et remet le compteur à 0.
    func selectRoutine(_ routine: RoutineType) {
        guard routine != selectedRoutine else { return }
        selectedRoutine = routine
        resetCount()
        defaults.set(routine.rawValue, forKey: Keys.selectedRoutine)
    }

    // MARK: - Session completion + streak (idempotent)

    private func completeSession() {
        isSessionComplete = true
        let today = Calendar.current.startOfDay(for: Date())
        let lastDate = defaults.object(forKey: Keys.lastSessionDate) as? Date
        let lastDay = lastDate.map { Calendar.current.startOfDay(for: $0) }

        // Idempotent : ne s'incrémente qu'une fois par jour
        if lastDay != today {
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
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
        let today = Calendar.current.startOfDay(for: Date())

        // Reset count if it was saved on a previous day
        let savedCount = defaults.integer(forKey: Keys.count)
        if let countDate = defaults.object(forKey: Keys.countDate) as? Date {
            let savedDay = Calendar.current.startOfDay(for: countDate)
            count = savedDay < today ? 0 : savedCount
        } else {
            count = savedCount
        }

        streak = defaults.integer(forKey: Keys.streak)

        if let raw = defaults.string(forKey: Keys.selectedRoutine),
           let routine = RoutineType(rawValue: raw) {
            selectedRoutine = routine
        }

        reminderHour      = defaults.object(forKey: Keys.reminderHour) as? Int ?? 7
        reminderMinute    = defaults.object(forKey: Keys.reminderMinute) as? Int ?? 0
        isReminderEnabled = defaults.bool(forKey: Keys.reminderEnabled)

        // Restitue l'état de complétion si déjà fait aujourd'hui
        if let lastDate = defaults.object(forKey: Keys.lastSessionDate) as? Date {
            let last = Calendar.current.startOfDay(for: lastDate)
            if last == today && count >= selectedRoutine.target {
                isSessionComplete = true
            }
        }
    }

    private func saveCount() {
        defaults.set(count, forKey: Keys.count)
        defaults.set(Date(), forKey: Keys.countDate)
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
