// Smash design system — BWF-court glass redesign.
// Values mirror design_handoff_smash/app/system.css.
// Light/dark via dynamic colors.

import SwiftUI

// MARK: - Color helpers

extension Color {
    /// Initialise a color from a 24-bit RGB hex literal (e.g. 0x00B964).
    init(hex: UInt32, opacity: Double = 1.0) {
        let red   = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >>  8) & 0xFF) / 255.0
        let blue  = Double( hex        & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

    /// A color that resolves differently in light vs dark.
    init(light: UInt32, lightAlpha: Double = 1, dark: UInt32, darkAlpha: Double = 1) {
        self = Color(uiColor: UIColor { tc in
            tc.userInterfaceStyle == .dark
                ? UIColor(Color(hex: dark,  opacity: darkAlpha))
                : UIColor(Color(hex: light, opacity: lightAlpha))
        })
    }
}

// MARK: - Brand colors (theme-independent)
// Source: system.css :root block

extension Color {
    // ── Green family ──────────────────────────────────────────────
    /// BWF court green — primary accent (prices, active, CTAs, dedicated). #00B964
    static let green      = Color(hex: 0x00B964)
    /// Gradient top / glow. #19D680
    static let greenBright = Color(hex: 0x19D680)
    /// Gradient bottom / on-light text. #0A6E42
    static let greenDeep  = Color(hex: 0x0A6E42)
    /// Darkest green ink. #053A23
    static let greenInk   = Color(hex: 0x053A23)

    // ── Red family ────────────────────────────────────────────────
    /// BWF red — energy, alerts, active-filter dot, "Closed". #E5392B
    static let red        = Color(hex: 0xE5392B)
    /// Red gradient top. #FF5A47
    static let redBright  = Color(hex: 0xFF5A47)
    /// Red gradient bottom. #9E1E14
    static let redDeep    = Color(hex: 0x9E1E14)

    // ── Court grey ────────────────────────────────────────────────
    /// Multi-sport grey — pins / tiles. #6B7178
    static let court      = Color(hex: 0x6B7178)

    // ── On-accent ─────────────────────────────────────────────────
    /// Text / icon color used ON green fills (chip-on, btn-primary, badge-ded).
    /// Same in light & dark because it sits over a colored fill, not the page. #04190F
    static let onAccent   = Color(hex: 0x04190F)

    // ── Warning ───────────────────────────────────────────────────
    /// Amber warning accent — location-denied hint, attention states. #F57C00
    /// Fixed (not dynamic): amber reads clearly on both light and dark backgrounds.
    static let warning    = Color(hex: 0xF57C00)
}

// MARK: - Neutral colors (dynamic light/dark)
// Source: system.css [data-theme="light"] and [data-theme="dark"]

extension Color {
    /// Primary text. Light #16140F / Dark #F4F2EC
    static let textPrimary = Color(light: 0x16140F, dark: 0xF4F2EC)

    /// Secondary text. Light rgba(34,31,26,.60) / Dark rgba(236,233,225,.62)
    static let textSecondary = Color(light: 0x221F1A, lightAlpha: 0.60,
                                     dark:  0xECE9E1, darkAlpha:  0.62)

    /// Tertiary / hint text. Light rgba(34,31,26,.38) / Dark rgba(236,233,225,.38)
    static let textTertiary = Color(light: 0x221F1A, lightAlpha: 0.38,
                                    dark:  0xECE9E1, darkAlpha:  0.38)

    /// Hairline separator. Light rgba(20,18,15,.10) / Dark rgba(255,255,255,.10)
    static let hairline = Color(light: 0x14120F, lightAlpha: 0.10,
                                dark:  0xFFFFFF, darkAlpha:  0.10)

    /// Strong hairline / divider. Light rgba(20,18,15,.16) / Dark rgba(255,255,255,.16)
    static let hairlineStrong = Color(light: 0x14120F, lightAlpha: 0.16,
                                      dark:  0xFFFFFF, darkAlpha:  0.16)

    /// Page background. Light cream #E9E5DC / Dark charcoal #0C0E0F
    static let pageBackground = Color(light: 0xE9E5DC, dark: 0x0C0E0F)

    /// Chip / glass-ultra-thin fill. Light rgba(255,255,255,.55) / Dark rgba(255,255,255,.08)
    static let chipBackground = Color(light: 0xFFFFFF, lightAlpha: 0.55,
                                      dark:  0xFFFFFF, darkAlpha:  0.08)
}

// MARK: - Radii
// Source: system.css :root --r-* variables

enum Radius {
    /// Chip / pill corners (999 = fully rounded). Use for badges, filters, tabs.
    static let chip: CGFloat = 999
    /// Same as chip; alias for pills / floating elements.
    static let pill: CGFloat = 999
    /// Venue card. 26 pt.
    static let card: CGFloat = 26
    /// Section card (rates, hours). 22 pt.
    static let section: CGFloat = 22
    /// Button. 18 pt.
    static let button: CGFloat = 18
    /// Court tile thumbnail. 15 pt.
    static let tile: CGFloat = 15
}

// MARK: - Spacing

/// Spacing scale. Core steps unchanged so existing consumers compile.
enum Spacing {
    static let xs: CGFloat     = 4
    static let sm: CGFloat     = 8
    static let md: CGFloat     = 16
    static let lg: CGFloat     = 24
    static let xl: CGFloat     = 32
    /// Screen-edge side padding. 18 pt.
    static let screen: CGFloat = 18
    /// Gap between venue cards in the list. 13 pt.
    static let cardGap: CGFloat = 13
}

// MARK: - Typography

/// Typography scale.
/// Sizes keep backward-compat (`Size.md == 14`, `Size.xxl == 24`).
/// Role-based `Font` helpers use SF Pro via `.system(size:weight:)`.
/// Apply tracking at the call site with `.tracking(value)`.
enum Typography {

    // ── Legacy size/weight enums (kept for existing consumers) ─────

    enum Size {
        static let sm: CGFloat  = 12
        static let md: CGFloat  = 14   // e.g. SmashScaffoldTests expects 14
        static let lg: CGFloat  = 16
        static let xl: CGFloat  = 20
        static let xxl: CGFloat = 24   // e.g. SmashScaffoldTests expects 24
    }

    enum Weight {
        case regular
        case medium
        case bold
    }

    /// Map a legacy token weight to a SwiftUI `Font.Weight`.
    static func weight(_ weight: Weight) -> Font.Weight {
        switch weight {
        case .regular: return .regular
        case .medium:  return .medium
        case .bold:    return .bold
        }
    }

    // ── Role-based font helpers (new) ──────────────────────────────
    // Tracking guidance is in the doc-comment; apply `.tracking(value)` at call site.
    // SF Pro Display/Text is auto-selected by the system at these sizes.

    /// Wordmark / app title. 34 pt, black. Apply `.tracking(-1.6)` at call site.
    static let display: Font = .system(size: 34, weight: .black)

    /// Venue name in Detail screen. 26 pt, black. Apply `.tracking(-1.0)` at call site.
    static let title: Font = .system(size: 26, weight: .black)

    /// Section titles, card name in List. 18 pt, heavy. Apply `.tracking(-0.5)` at call site.
    static let headline: Font = .system(size: 18, weight: .heavy)

    /// Card venue name (List card). 17 pt, heavy. Apply `.tracking(-0.4)` at call site.
    static let cardTitle: Font = .system(size: 17, weight: .heavy)

    /// Body copy, booking address. 17 pt, semibold. Apply `.tracking(-0.2)` at call site.
    static let body: Font = .system(size: 17, weight: .semibold)

    /// Subhead / filter-chip label. 15 pt, semibold. Apply `.tracking(-0.2)` at call site.
    static let subhead: Font = .system(size: 15, weight: .semibold)

    /// Caption / meta rows. 13 pt, semibold. No tracking needed.
    static let caption: Font = .system(size: 13, weight: .semibold)

    /// Micro uppercase label (e.g. "FROM", "DISTANCE"). 11 pt, heavy.
    /// Apply `.tracking(0.5).textCase(.uppercase)` at call site.
    static let micro: Font = .system(size: 11, weight: .heavy)

    /// Price display. 22 pt, black. Apply `.tracking(-1.0)` at call site.
    static let price: Font = .system(size: 22, weight: .black)
}

// MARK: - Green glow shadow

/// Reusable green-glow View modifier.
/// Produces: `0 2px 10px rgba(0,185,100,.40)` — matches system.css `.chip-on` / `.btn-primary` glow.
struct GreenGlowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color(hex: 0x00B964, opacity: 0.40), radius: 10, x: 0, y: 2)
    }
}

extension View {
    /// Apply the BWF-court green glow shadow (badges, CTAs, active tab).
    func greenGlow() -> some View {
        modifier(GreenGlowModifier())
    }
}

