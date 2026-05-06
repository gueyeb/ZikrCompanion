import SwiftUI

// MARK: - ContentView (root)

struct ContentView: View {
    @EnvironmentObject private var store: SessionStore
    @State private var showNiyya: Bool = false
    @State private var activeTab: Tab = .counter

    enum Tab { case counter, settings }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            NavigationStack {
                TabView(selection: $activeTab) {
                    // MARK: Counter tab
                    counterTab
                        .tabItem {
                            Label("Zikr", systemImage: "circle.grid.3x3.fill")
                        }
                        .tag(Tab.counter)

                    // MARK: Settings tab
                    SettingsView()
                        .tabItem {
                            Label("Paramètres", systemImage: "gearshape")
                        }
                        .tag(Tab.settings)
                }
                .tint(AppTheme.gold)
            }
        }
        .sheet(isPresented: $showNiyya) {
            NiyyaView(isPresented: $showNiyya)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .task {
            await NotificationManager.shared.rescheduleIfNeeded(store: store)
        }
    }

    // MARK: - Counter tab content

    private var counterTab: some View {
        ScrollView {
            VStack(spacing: AppTheme.paddingL) {

                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Zikr Companion")
                            .font(AppTheme.titleFont)
                            .foregroundStyle(AppTheme.textPrimary)
                        Text(greeting)
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer()
                    StreakView(streak: store.streak)
                }
                .padding(.horizontal, AppTheme.paddingL)
                .padding(.top, AppTheme.paddingM)

                // Sélecteur routine
                RoutineView()
                    .padding(.horizontal, AppTheme.paddingL)

                // Compteur
                CounterView()
                    .padding(.vertical, AppTheme.paddingM)

                // ZikrCards
                if !zikrItems.isEmpty {
                    VStack(alignment: .leading, spacing: AppTheme.paddingS) {
                        Text("Formules")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.textSecondary)
                            .padding(.horizontal, AppTheme.paddingL)

                        ForEach(zikrItems) { item in
                            ZikrCardView(item: item)
                                .padding(.horizontal, AppTheme.paddingL)
                        }
                    }
                }

                // Niyya button
                Button {
                    showNiyya = true
                } label: {
                    Label("Intention", systemImage: "heart")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.bottom, AppTheme.paddingXL)
            }
        }
        .background(AppTheme.background)
        .scrollIndicators(.hidden)
    }

    // MARK: - Helpers

    private var zikrItems: [ZikrItem] {
        switch store.selectedRoutine {
        case .morning: return ZikrItem.morningItems
        case .evening: return ZikrItem.eveningItems
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Assalam aleykum 🌅"
        case 12..<18: return "Bon après-midi ☀️"
        default:      return "Bonsoir 🌙"
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionStore())
}
