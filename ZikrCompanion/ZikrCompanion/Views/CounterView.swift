import SwiftUI

struct CounterView: View {
    @EnvironmentObject private var store: SessionStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var ringSize = 200.0
    @ScaledMetric(relativeTo: .title) private var actionSize = 80.0
    @State private var showCompletion = false
    @State private var feedbackTrigger = 0
    @State private var dismissalTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: AppTheme.paddingL) {
            progressRing
            incrementButton

            if !store.isSessionComplete {
                Text("^[\(store.remaining) répétition restante](inflect: true)")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(.secondary)
            }
        }
        .onChange(of: store.isSessionComplete) { _, completed in
            guard completed else { return }
            presentCompletion()
        }
        .overlay {
            if showCompletion {
                SessionCompletionBanner {
                    dismissCompletion()
                }
                .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
            }
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
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: store.progress)

            VStack(spacing: 2) {
                Text(store.count, format: .number)
                    .font(AppTheme.counterFont)
                    .foregroundStyle(AppTheme.textPrimary)
                    .contentTransition(reduceMotion ? .identity : .numericText())

                Text(store.currentTarget, format: .number)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Objectif \(store.currentTarget)")
            }
        }
        .frame(width: diameter, height: diameter)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progression")
        .accessibilityValue("\(store.count) sur \(store.currentTarget)")
    }

    private var incrementButton: some View {
        Button(
            store.isSessionComplete ? "Session terminée" : "Ajouter une répétition",
            systemImage: store.isSessionComplete ? "checkmark" : "plus",
            action: increment
        )
        .labelStyle(.iconOnly)
        .font(.title2)
        .foregroundStyle(AppTheme.background)
        .frame(width: max(actionSize, 64), height: max(actionSize, 64))
        .background(store.isSessionComplete ? AppTheme.success : AppTheme.gold)
        .clipShape(.circle)
        .shadow(
            color: (store.isSessionComplete ? AppTheme.success : AppTheme.gold).opacity(0.35),
            radius: 12,
            y: 6
        )
        .disabled(store.isSessionComplete)
        .sensoryFeedback(.impact(weight: .light), trigger: feedbackTrigger)
        .accessibilityValue("\(store.count) sur \(store.currentTarget)")
    }

    private func increment() {
        store.increment()
        feedbackTrigger += 1
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
}

#Preview {
    CounterView()
        .environmentObject(SessionStore())
        .padding()
        .background(AppTheme.background)
}
