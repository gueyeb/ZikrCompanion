import Foundation
import UserNotifications

// MARK: - NotificationManager

@MainActor
final class NotificationManager {

    static let shared = NotificationManager()
    private init() {}

    private let center = UNUserNotificationCenter.current()
    private let reminderIdentifier = "zc.daily.reminder"

    // MARK: - Permission

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Schedule

    /// Planifie (ou remplace) un rappel quotidien à l'heure donnée.
    func scheduleDailyReminder(hour: Int, minute: Int) async {
        // Retire l'ancien
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])

        var components = DateComponents()
        components.hour   = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let content = UNMutableNotificationContent()
        content.title = "Zikr du jour"
        content.body  = "Prends un moment pour te souvenir d'Allah. سُبْحَانَ اللهِ"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: reminderIdentifier,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("NotificationManager — erreur scheduling: \(error)")
        }
    }

    /// Annule le rappel quotidien.
    func cancelDailyReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
    }

    /// Replanifie si le rappel était activé (à appeler au launch).
    func rescheduleIfNeeded(store: SessionStore) async {
        guard store.isReminderEnabled else { return }
        let status = await authorizationStatus()
        guard status == .authorized else { return }
        await scheduleDailyReminder(hour: store.reminderHour, minute: store.reminderMinute)
    }
}
