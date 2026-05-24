import SwiftUI

// MARK: - ScrollCounterView (mode chapelet)

struct ScrollCounterView: View {
    @EnvironmentObject private var store: SessionStore

    @State private var showCompletion = false
    @State private var swipeDirection: SwipeDirection = .none

    private let threshold: CGFloat = 50
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactLight  = UIImpactFeedbackGenerator(style: .light)

    private enum SwipeDirection { case up, down, none }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: AppTheme.paddingL) {
                Spacer()
                progressRing
                swipeHint
                if !store.isSessionComplete {
                    Text("\(store.remaining) restant\(store.remaining > 1 ? "s" : "")")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                Spacer()
            }
            .overlay(completionOverlay)
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onChanged { value in
                    guard !store.isSessionComplete else { return }
                    let dir: SwipeDirection = value.translation.height < 0 ? .up : .down
                    withAnimation(.easeOut(duration: 0.1)) { swipeDirection = dir }
                }
                .onEnded { value in
                    defer {
                        withAnimation(.easeOut(duration: 0.3)) { swipeDirection = .none }
                    }
                    guard !store.isSessionComplete else { return }
                    let translation = -value.translation.height
                    if translation >= threshold {
                        store.increment()
                        impactMedium.impactOccurred()
                    } else if translation <= -threshold {
                        store.decrement()
                        impactLight.impactOccurred()
                    }
                }
        )
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            impactMedium.prepare()
            impactLight.prepare()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onChange(of: store.isSessionComplete) { _, completed in
            if completed { showCompletion = true }
        }
    }

    // MARK: - Subviews

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.divider, lineWidth: 6)
                .frame(width: 200, height: 200)

            Circle()
                .trim(from: 0, to: store.progress)
                .stroke(
                    store.isSessionComplete ? AppTheme.success : AppTheme.gold,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.2), value: store.progress)

            VStack(spacing: 2) {
                Text("\(store.count)")
                    .font(AppTheme.counterFont)
                    .foregroundStyle(AppTheme.textPrimary)
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.15), value: store.count)

                Text("/ \(store.currentTarget)")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
    }

    private var swipeHint: some View {
        VStack(spacing: 6) {
            Image(systemName: "chevron.up")
                .foregroundStyle(swipeDirection == .up ? AppTheme.gold : AppTheme.textSecondary.opacity(0.3))
            Text("glisser")
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary.opacity(0.3))
            Image(systemName: "chevron.down")
                .foregroundStyle(swipeDirection == .down ? AppTheme.textSecondary : AppTheme.textSecondary.opacity(0.3))
        }
        .font(.system(size: 14, weight: .medium))
        .animation(.easeOut(duration: 0.15), value: swipeDirection)
    }

    @ViewBuilder
    private var completionOverlay: some View {
        if showCompletion {
            VStack(spacing: AppTheme.paddingM) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.success)

                Text("بَارَكَ اللهُ فِيكَ")
                    .font(AppTheme.arabicFont)
                    .foregroundStyle(AppTheme.gold)

                Text("Session complète !")
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.textPrimary)
            }
            .padding(AppTheme.paddingXL)
            .background(AppTheme.surface.opacity(0.97))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL))
            .transition(.scale.combined(with: .opacity))
            .onTapGesture { withAnimation { showCompletion = false } }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation { showCompletion = false }
                }
            }
        }
    }

}

#Preview {
    ScrollCounterView()
        .environmentObject(SessionStore())
}
