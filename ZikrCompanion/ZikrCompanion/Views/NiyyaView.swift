import SwiftUI

// MARK: - NiyyaView (écran d'intention / onboarding léger)

struct NiyyaView: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: AppTheme.paddingL) {
                Spacer()

                // Icône
                Image(systemName: "heart.fill")
                    .font(.largeTitle)
                    .foregroundStyle(AppTheme.gold)
                    .accessibilityHidden(true)

                // Titre arabic
                Text("نِيَّة")
                    .font(.system(.largeTitle, design: .default).weight(.light))
                    .foregroundStyle(AppTheme.gold)
                    .environment(\.layoutDirection, .rightToLeft)

                Text("Intention")
                    .font(AppTheme.titleFont)
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Renouvelle ton intention avant de commencer.\nChaque dhikr compte pour Allah.")
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.paddingXL)

                Spacer()

                // CTA
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isPresented = false
                    }
                } label: {
                    Text("Commencer")
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(AppTheme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.paddingM)
                        .background(AppTheme.gold)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM))
                }
                .accessibilityHint("Ferme l'écran d'intention et ouvre le compteur")
                .padding(.horizontal, AppTheme.paddingL)
                .padding(.bottom, AppTheme.paddingXL)
            }
        }
    }
}

#Preview {
    NiyyaView(isPresented: .constant(true))
}
