import SwiftUI

@main
struct ZikrCompanionApp: App {
    @StateObject private var store = SessionStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            store.refreshForCurrentDay()
        }
    }
}
