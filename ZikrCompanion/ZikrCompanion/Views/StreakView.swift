import SwiftUI

// MARK: - StreakView (DAK-153)

struct StreakView: View {
    let streak: Int

    var body: some View {
        HStack(spacing: AppTheme.paddingS) {
            Image(systemName: "flame.fill")
                .foregroundStyle(streak > 0 ? AppTheme.gold : AppTheme.textSecondary)
                .font(.system(size: 18, weight: .semibold))

            VStack(alignment: .leading, spacing: 2) {
                Text("^[\(streak) jour consécutif](inflect: true)")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(streak > 0 ? AppTheme.gold : AppTheme.textSecondary)
            }
        }
        .padding(.horizontal, AppTheme.paddingM)
        .padding(.vertical, AppTheme.paddingS)
        .background(AppTheme.surfaceAlt)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(
                    streak > 0 ? AppTheme.gold.opacity(0.3) : AppTheme.divider,
                    lineWidth: 1
                )
        )
        .animation(.easeInOut(duration: 0.3), value: streak)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Série de \(streak) jours consécutifs")
    }
}

#Preview {
    VStack(spacing: 16) {
        StreakView(streak: 0)
        StreakView(streak: 1)
        StreakView(streak: 7)
    }
    .padding()
    .background(AppTheme.background)
}
