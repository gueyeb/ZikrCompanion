import SwiftUI

// MARK: - ContentView (root)

struct ContentView: View {
    @EnvironmentObject private var store: SessionStore
    @State private var showNiyya: Bool = false
    @State private var niyyaIsEnforced: Bool = false
    @State private var niyyaAcknowledged: Bool = false
    @State private var activeTab: Tab = .counter
    @State private var counterMode: CounterMode = .tap

    enum Tab { case counter, history, settings }
    enum CounterMode { case tap, scroll }

    var body: some View {
        TabView(selection: $activeTab) {
            NavigationStack {
                counterTab
            }
            .tabItem {
                Label("Zikr", systemImage: "circle.grid.3x3.fill")
            }
            .tag(Tab.counter)

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("Historique", systemImage: "clock.arrow.circlepath")
            }
            .tag(Tab.history)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Paramètres", systemImage: "gearshape")
            }
            .tag(Tab.settings)
        }
        .tint(AppTheme.gold)
        .sheet(isPresented: $showNiyya, onDismiss: {
            if niyyaIsEnforced { niyyaAcknowledged = true }
            niyyaIsEnforced = false
        }) {
            NiyyaView(isPresented: $showNiyya)
                .presentationDetents([.medium])
                .presentationDragIndicator(niyyaIsEnforced ? .hidden : .visible)
                .interactiveDismissDisabled(niyyaIsEnforced)
        }
        .task {
            await NotificationManager.shared.rescheduleIfNeeded(store: store)
        }
    }

    // MARK: - Counter tab content

    private var counterTab: some View {
        Group {
            if counterMode == .scroll {
                ZStack(alignment: .bottom) {
                    ScrollCounterView()
                    modeToggle.padding(.bottom, AppTheme.paddingXL)
                }
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.paddingL) {

                        // Header
                        HStack {
                            Image("BrandMark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44)
                                .clipShape(.rect(cornerRadius: AppTheme.radiusS))
                                .accessibilityHidden(true)

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

                        // Bottom controls
                        HStack(spacing: AppTheme.paddingL) {
                            // Niyya button (voluntary reminder mid-session)
                            Button {
                                niyyaIsEnforced = false
                                showNiyya = true
                            } label: {
                                Label("Intention", systemImage: "heart")
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(AppTheme.textSecondary)
                            }

                            modeToggle
                        }
                        .padding(.bottom, AppTheme.paddingXL)
                    }
                }
                .background(AppTheme.background)
                .scrollIndicators(.hidden)
            }
        }
        .onAppear {
            guard activeTab == .counter else { return }
            if store.count == 0 && !niyyaAcknowledged {
                niyyaIsEnforced = true
                showNiyya = true
            }
        }
        .onChange(of: store.count) { _, newCount in
            if newCount == 0 && activeTab == .counter {
                niyyaAcknowledged = false
                niyyaIsEnforced = true
                showNiyya = true
            }
        }
    }

    // MARK: - Mode toggle

    private var modeToggle: some View {
        HStack(spacing: 2) {
            Button { counterMode = .tap } label: {
                Label("Mode tactile", systemImage: "hand.tap.fill")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(counterMode == .tap ? AppTheme.gold : AppTheme.textSecondary.opacity(0.4))
                    .frame(minWidth: 44, minHeight: 44)
            }
            .accessibilityAddTraits(counterMode == .tap ? .isSelected : [])
            Button { counterMode = .scroll } label: {
                Label("Mode chapelet", systemImage: "arrow.up.arrow.down")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(counterMode == .scroll ? AppTheme.gold : AppTheme.textSecondary.opacity(0.4))
                    .frame(minWidth: 44, minHeight: 44)
            }
            .accessibilityAddTraits(counterMode == .scroll ? .isSelected : [])
        }
        .font(.system(size: 16))
        .background(AppTheme.surface)
        .clipShape(Capsule())
    }

    // MARK: - Helpers

    private var zikrItems: [ZikrItem] {
        switch store.selectedRoutine {
        case .morning: return ZikrItem.morningItems
        case .evening: return ZikrItem.eveningItems
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
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
