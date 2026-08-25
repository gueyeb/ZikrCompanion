import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {
    @EnvironmentObject private var store: SessionStore
    @Environment(\.openURL) private var openURL
    @State private var reminderTime: Date = .now
    @State private var permissionDenied = false
    @State private var notificationErrorMessage = ""
    @State private var isShowingNotificationError = false

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            List {
                // MARK: Rappel
                Section {
                    Toggle(isOn: $store.isReminderEnabled) {
                        Label("Rappel quotidien", systemImage: "bell.fill")
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                    .tint(AppTheme.gold)
                    .onChange(of: store.isReminderEnabled) { _, enabled in
                        Task { await toggleReminder(enabled) }
                    }

                    if store.isReminderEnabled {
                        DatePicker(
                            "Heure",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .foregroundStyle(AppTheme.textPrimary)
                        .tint(AppTheme.gold)
                        .onChange(of: reminderTime) { _, newValue in
                            updateReminderTime(newValue)
                        }
                    }
                } header: {
                    Text("Notifications")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .listRowBackground(AppTheme.surfaceAlt)

                // MARK: Streak reset
                Section {
                    Button(role: .destructive) {
                        store.resetCount()
                    } label: {
                        Label("Remettre le compteur à zéro", systemImage: "arrow.counterclockwise")
                    }
                } header: {
                    Text("Session")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .listRowBackground(AppTheme.surfaceAlt)

                // MARK: Version
                Section {
                    HStack {
                        Text("Version")
                            .foregroundStyle(AppTheme.textSecondary)
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .listRowBackground(AppTheme.surfaceAlt)
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Paramètres")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear(perform: syncReminderTime)
        .alert("Notifications désactivées", isPresented: $permissionDenied) {
            Button("Ouvrir Réglages") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Active les notifications pour Zikr Companion dans les Réglages de ton iPhone.")
        }
        .alert("Rappel non enregistré", isPresented: $isShowingNotificationError) {
        } message: {
            Text(notificationErrorMessage)
        }
    }

    // MARK: - Helpers

    private func toggleReminder(_ enabled: Bool) async {
        if enabled {
            do {
                let granted = try await NotificationManager.shared.requestAuthorization()
                guard granted else {
                    store.isReminderEnabled = false
                    permissionDenied = true
                    return
                }
                try await NotificationManager.shared.scheduleDailyReminder(
                    hour: store.reminderHour,
                    minute: store.reminderMinute
                )
                store.saveReminderSettings()
            } catch {
                store.isReminderEnabled = false
                store.saveReminderSettings()
                showNotificationError(error)
            }
        } else {
            store.saveReminderSettings()
            NotificationManager.shared.cancelDailyReminder()
        }
    }

    private func updateReminderTime(_ date: Date) {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        store.reminderHour   = comps.hour ?? 7
        store.reminderMinute = comps.minute ?? 0
        store.saveReminderSettings()
        guard store.isReminderEnabled else { return }
        Task {
            do {
                try await NotificationManager.shared.scheduleDailyReminder(
                    hour: store.reminderHour,
                    minute: store.reminderMinute
                )
            } catch {
                showNotificationError(error)
            }
        }
    }

    private func syncReminderTime() {
        var comps = DateComponents()
        comps.hour   = store.reminderHour
        comps.minute = store.reminderMinute
        reminderTime = Calendar.current.date(from: comps) ?? .now
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private func showNotificationError(_ error: Error) {
        notificationErrorMessage = error.localizedDescription
        isShowingNotificationError = true
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(SessionStore())
    }
}
