import SwiftUI

struct ScrollCounterView: View {
    @EnvironmentObject private var store: SessionStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var ringSize = 200.0
    @State private var showCompletion = false
    @State private var swipeDirection: SwipeDirection = .none
    @State private var incrementFeedback = 0
    @State private var decrementFeedback = 0
    @State private var dismissalTask: Task<Void, Never>?

    private let threshold = 50.0

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: AppTheme.paddingL) {
                Spacer()
                progressRing
                swipeHint
                accessibleControls

                if !store.isSessionComplete {
                    Text("^[\(store.remaining) répétition restante](inflect: true)")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, AppTheme.paddingL)
            .overlay {
                if showCompletion {
                    SessionCompletionBanner {
                        dismissCompletion()
                    }
                    .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                }
            }
        }
        .contentShape(.rect)
        .gesture(dragGesture)
        .onChange(of: store.isSessionComplete) { _, completed in
            guard completed else { return }
            presentCompletion()
        }
        .onDisappear {
            dismissalTask?.cancel()
        }
    }

    private var progressRing: some View {
        let diameter = min(ringSize, 240)

        return ZStack {
            Circle()
                .stroke(AppTheme.divider, lineWidth: 6)

            Circle()
                .trim(from: 0, to: store.progress)
                .stroke(
                    store.isSessionComplete ? AppTheme.success : AppTheme.gold,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: store.progress)

            VStack(spacing: 2) {
                Text(store.count, format: .number)
                    .font(AppTheme.counterFont)
                    .foregroundStyle(AppTheme.textPrimary)
                    .contentTransition(reduceMotion ? .identity : .numericText())

                Text(store.currentTarget, format: .number)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: diameter, height: diameter)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Compteur chapelet")
        .accessibilityValue("\(store.count) sur \(store.currentTarget)")
        .accessibilityHint("Balayez verticalement, ou utilisez les boutons ajouter et retirer")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                increment()
            case .decrement:
                decrement()
            @unknown default:
                break
            }
        }
    }

    private var swipeHint: some View {
        Label("Glisser vers le haut pour ajouter, vers le bas pour retirer", systemImage: "arrow.up.arrow.down")
            .font(AppTheme.captionFont)
            .foregroundStyle(AppTheme.textSecondary)
            .multilineTextAlignment(.center)
            .symbolEffect(.pulse, value: swipeDirection)
    }

    private var accessibleControls: some View {
        HStack(spacing: AppTheme.paddingM) {
            Button("Retirer", systemImage: "minus", action: decrement)
                .disabled(store.count == 0)
                .sensoryFeedback(.impact(weight: .light), trigger: decrementFeedback)

            Button("Ajouter", systemImage: "plus", action: increment)
                .disabled(store.isSessionComplete)
                .sensoryFeedback(.impact(weight: .medium), trigger: incrementFeedback)
        }
        .buttonStyle(.bordered)
        .tint(AppTheme.gold)
        .controlSize(.large)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onChanged { value in
                guard !store.isSessionComplete else { return }
                swipeDirection = value.translation.height < 0 ? .up : .down
            }
            .onEnded { value in
                defer { swipeDirection = .none }
                guard !store.isSessionComplete else { return }
                let translation = -value.translation.height
                if translation >= threshold {
                    increment()
                } else if translation <= -threshold {
                    decrement()
                }
            }
    }

    private func increment() {
        guard !store.isSessionComplete else { return }
        store.increment()
        incrementFeedback += 1
    }

    private func decrement() {
        guard store.count > 0 else { return }
        store.decrement()
        decrementFeedback += 1
    }

    private func presentCompletion() {
        dismissalTask?.cancel()
        withAnimation(reduceMotion ? nil : .easeInOut) {
            showCompletion = true
        }
        dismissalTask = Task {
            try? await Task.sleep(for: .seconds(2.5))
            guard !Task.isCancelled else { return }
            dismissCompletion()
        }
    }

    private func dismissCompletion() {
        dismissalTask?.cancel()
        withAnimation(reduceMotion ? nil : .easeInOut) {
            showCompletion = false
        }
    }

    private enum SwipeDirection {
        case up
        case down
        case none
    }
}

#Preview {
    ScrollCounterView()
        .environmentObject(SessionStore())
}
