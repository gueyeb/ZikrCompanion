import SwiftUI

// MARK: - CounterView

struct CounterView: View {
    @EnvironmentObject private var store: SessionStore
    @State private var isPressed = false
    @State private var showCompletion = false

    var body: some View {
        VStack(spacing: AppTheme.paddingL) {
            // Anneau de progression
            progressRing

            // Compteur principal
            counterLabel

            // Bouton tap
            tapButton

            // Remaining hint
            if !store.isSessionComplete {
                Text("\(store.remaining) restant\(store.remaining > 1 ? "s" : "")")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .onChange(of: store.isSessionComplete) { _, completed in
            if completed { showCompletion = true }
        }
        .overlay(completionOverlay)
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
                .animation(.easeInOut(duration: 0.3), value: store.progress)

            // Compteur centré dans l'anneau
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

    private var counterLabel: some View {
        EmptyView() // Compteur déjà dans l'anneau
    }

    private var tapButton: some View {
        Button {
            guard !store.isSessionComplete else { return }
            store.increment()
            impactFeedback()
        } label: {
            ZStack {
                Circle()
                    .fill(store.isSessionComplete ? AppTheme.success : AppTheme.gold)
                    .frame(width: 80, height: 80)
                    .shadow(
                        color: (store.isSessionComplete ? AppTheme.success : AppTheme.gold).opacity(0.4),
                        radius: isPressed ? 4 : 16,
                        y: isPressed ? 2 : 8
                    )

                Image(systemName: store.isSessionComplete ? "checkmark" : "plus")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(AppTheme.background)
            }
            .scaleEffect(isPressed ? 0.93 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(store.isSessionComplete)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeOut(duration: 0.1)) { isPressed = true } }
                .onEnded   { _ in withAnimation(.spring(duration: 0.3)) { isPressed = false } }
        )
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

    // MARK: - Haptic

    private func impactFeedback() {
        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.impactOccurred()
    }
}

#Preview {
    CounterView()
        .environmentObject(SessionStore())
        .padding()
        .background(AppTheme.background)
}
