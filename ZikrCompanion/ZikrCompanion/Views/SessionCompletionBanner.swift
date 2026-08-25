import SwiftUI

struct SessionCompletionBanner: View {
    let dismiss: () -> Void

    var body: some View {
        Button(action: dismiss) {
            VStack(spacing: AppTheme.paddingM) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(AppTheme.success)
                    .accessibilityHidden(true)

                Text("بَارَكَ اللهُ فِيكَ")
                    .font(AppTheme.arabicFont)
                    .foregroundStyle(AppTheme.gold)
                    .environment(\.layoutDirection, .rightToLeft)

                Text("Session terminée")
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.textPrimary)
            }
            .padding(AppTheme.paddingXL)
            .background(AppTheme.surface.opacity(0.97))
            .clipShape(.rect(cornerRadius: AppTheme.radiusL))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Session terminée")
        .accessibilityHint("Touchez deux fois pour fermer ce message")
    }
}
