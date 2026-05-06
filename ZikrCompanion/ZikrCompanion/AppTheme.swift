import SwiftUI

enum AppTheme {
    // MARK: - Colors
    static let gold         = Color(hex: "#C9A96E")
    static let background   = Color(hex: "#0A0A0F")
    static let surface      = Color(hex: "#13131A")
    static let surfaceAlt   = Color(hex: "#1C1C26")
    static let textPrimary  = Color.white
    static let textSecondary = Color(hex: "#8A8AA0")
    static let success      = Color(hex: "#4CAF7D")
    static let divider      = Color(hex: "#2A2A38")

    // MARK: - Typography
    static let titleFont    = Font.system(.title2, design: .rounded).weight(.semibold)
    static let headlineFont = Font.system(.headline, design: .rounded).weight(.medium)
    static let bodyFont     = Font.system(.body, design: .rounded)
    static let captionFont  = Font.system(.caption, design: .rounded)
    static let counterFont  = Font.system(size: 72, weight: .thin, design: .rounded)
    static let arabicFont   = Font.system(size: 28, weight: .regular, design: .default)

    // MARK: - Spacing
    static let paddingS: CGFloat  = 8
    static let paddingM: CGFloat  = 16
    static let paddingL: CGFloat  = 24
    static let paddingXL: CGFloat = 40

    // MARK: - Radius
    static let radiusS: CGFloat = 8
    static let radiusM: CGFloat = 16
    static let radiusL: CGFloat = 24
}

// MARK: - Color hex init
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
