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
                .environment(\.layoutDirection, .rightToLeft)

            Divider()
                .background(AppTheme.divider)

            // Translitération + traduction
            VStack(alignment: .leading, spacing: 4) {
                Text(item.transliteration)
                    .font(AppTheme.bodyFont.italic())
                    .foregroundStyle(AppTheme.textSecondary)

                Text(item.translation)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(AppTheme.paddingM)
        .background(AppTheme.surfaceAlt)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.radiusM)
                .stroke(AppTheme.divider, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.transliteration). \(item.translation)")
    }
}

#Preview {
    ZikrCardView(item: ZikrItem.morningItems[0])
        .padding()
        .background(AppTheme.background)
}
