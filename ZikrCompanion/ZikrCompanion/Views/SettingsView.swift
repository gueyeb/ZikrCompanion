import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {
    @EnvironmentObject private var store: SessionStore
    @State private var reminderTime: Date = .now
    @State private var permissionDenied = false

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            List {
                // MARK: Rappel
                Section {
                    Toggle(isOn: Binding(
                        get: { store.isReminderEnabled },
                        set: { toggleReminder($0) }
                    )) {
                        Label("Rappel quotidien", systemImage: "bell.fill")
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                    .tint(AppTheme.gold)

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
        .onAppear { syncReminderTime() }
        .alert("Notifications désactivées", isPresented: $permissionDenied) {
            Button("Ouvrir Réglages") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Active les notifications pour Zikr Companion dans les Réglages de ton iPhone.")
        }
    }

    // MARK: - Helpers

    private func toggleReminder(_ enabled: Bool) {
        Task { @MainActor in
            if enabled {
                let granted = await NotificationManager.shared.requestAuthorization()
                if granted {
                    store.isReminderEnabled = true
                    store.saveReminderSettings()
                    await NotificationManager.shared.scheduleDailyReminder(
                        hour: store.reminderHour,
                        minute: store.reminderMinute
                    )
                } else {
                    permissionDenied = true
                }
            } else {
                store.isReminderEnabled = false
                store.saveReminderSettings()
                NotificationManager.shared.cancelDailyReminder()
            }
        }
    }

    private func updateReminderTime(_ date: Date) {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        store.reminderHour   = comps.hour ?? 7
        store.reminderMinute = comps.minute ?? 0
        store.saveReminderSettings()
        Task {
            await NotificationManager.shared.scheduleDailyReminder(
                hour: store.reminderHour,
                minute: store.reminderMinute
            )
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
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(SessionStore())
    }
}
