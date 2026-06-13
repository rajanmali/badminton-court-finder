// Design tokens — source of truth ported from packages/ui/src/tokens.ts (RN app).
// After RN retirement this is the canonical token definition.

import SwiftUI

// MARK: - Colors

extension Color {
    /// Brand green. Token: colors.primary (#00C853).
    static let smashPrimary = Color(hex: 0x00C853)
    /// Token: colors.background (#FFFFFF).
    static let smashBackground = Color(hex: 0xFFFFFF)
    /// Token: colors.surface (#F5F5F5).
    static let smashSurface = Color(hex: 0xF5F5F5)
    /// Token: colors.text (#1A1A1A).
    static let smashText = Color(hex: 0x1A1A1A)
    /// Token: colors.textSecondary (#666666).
    static let smashTextSecondary = Color(hex: 0x666666)
    /// Token: colors.border (#E0E0E0).
    static let smashBorder = Color(hex: 0xE0E0E0)
    /// Token: colors.error (#D32F2F).
    static let smashError = Color(hex: 0xD32F2F)

    // Non-token literals used by later screens (kept here for a single colour source).
    /// Multi-sport venue map pin (#1565C0).
    static let smashMultiSportPin = Color(hex: 0x1565C0)
    /// Warning accent (#F57C00).
    static let smashWarning = Color(hex: 0xF57C00)

    /// Initialise a colour from a 24-bit RGB hex literal (e.g. 0x00C853).
    init(hex: UInt32, opacity: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

// MARK: - Spacing

/// Spacing scale (ported from spacing in tokens.ts).
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

// MARK: - Typography

/// Typography scale (ported from typography in tokens.ts).
enum Typography {
    enum Size {
        static let sm: CGFloat = 12
        static let md: CGFloat = 14
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
    }

    enum Weight {
        case regular
        case medium
        case bold
    }

    /// Map a token weight to a SwiftUI `Font.Weight`.
    static func weight(_ weight: Weight) -> Font.Weight {
        switch weight {
        case .regular: return .regular
        case .medium: return .medium
        case .bold: return .bold
        }
    }
}
