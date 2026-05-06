import SwiftUI

// MARK: - ZikrCardView (DAK-153)

struct ZikrCardView: View {
    let item: ZikrItem

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.paddingM) {
            // Arabic
            Text(item.arabic)
                .font(AppTheme.arabicFont)
                .foregroundStyle(AppTheme.gold)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .multilineTextAlignment(.trailing)

            Divider()
                .background(AppTheme.divider)

            // Translitération + traduction
            VStack(alignment: .leading, spacing: 4) {
                Text(item.transliteration)
                    .font(AppTheme.bodyFont.italic())
                    .foregroundStyle(AppTheme.textSecondary)

                Text(item.translation)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.textSecondary.opacity(0.7))
            }
        }
        .padding(AppTheme.paddingM)
        .background(AppTheme.surfaceAlt)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.radiusM)
                .stroke(AppTheme.divider, lineWidth: 1)
        )
    }
}

#Preview {
    ZikrCardView(item: ZikrItem.morningItems[0])
        .padding()
        .background(AppTheme.background)
}
