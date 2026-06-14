// Smash glass material system — BWF-court glass redesign.
// Mirrors the `.glass` material in design_handoff_smash/app/system.css.
//
// On iOS we map directly to SwiftUI's system Materials
// (.ultraThinMaterial / .regularMaterial / .thickMaterial) rather than
// re-implementing the CSS rgba()+backdrop-filter blur by hand. When the user
// enables Reduce Transparency we drop the material for an opaque solid fill.

import SwiftUI

// MARK: - Glass material tokens
// Source: system.css [data-theme="light"] / [data-theme="dark"] glass + solid vars.

extension Color {
    /// Glass border stroke. Light #FFFFFF @0.70 / Dark #FFFFFF @0.16.
    static let glassBorder = Color(light: 0xFFFFFF, lightAlpha: 0.70,
                                   dark:  0xFFFFFF, darkAlpha:  0.16)

    /// Inner top-edge sheen highlight. Light #FFFFFF @0.90 / Dark #FFFFFF @0.20.
    static let glassSheen = Color(light: 0xFFFFFF, lightAlpha: 0.90,
                                  dark:  0xFFFFFF, darkAlpha:  0.20)

    // ── Reduced-transparency solid fills ──────────────────────────────
    // Used in place of the blurred material when Reduce Transparency is on.

    /// Solid fill for ultra-thin glass. Light #F0EEE7 / Dark #1B1F21.
    static let solidUltraThin = Color(light: 0xF0EEE7, dark: 0x1B1F21)

    /// Solid fill for regular glass. Light #F6F4EF / Dark #1E2325.
    static let solidRegular = Color(light: 0xF6F4EF, dark: 0x1E2325)

    /// Solid fill for thick glass. Light #FBFAF7 / Dark #14181A.
    static let solidThick = Color(light: 0xFBFAF7, dark: 0x14181A)

    // ── Glass drop-shadow color (dynamic) ─────────────────────────────
    // Light: warm near-black #14120F. Dark: pure black (heavier in dark mode).
    static let glassShadow = Color(light: 0x14120F, dark: 0x000000)
}

// MARK: - Glass level

/// The three glass material levels from the design system.
///
/// | Level     | iOS Material         | Used for                                   |
/// |-----------|----------------------|--------------------------------------------|
/// | ultraThin | `.ultraThinMaterial` | chips, pills, compact rows, locate button  |
/// | regular   | `.regularMaterial`   | venue cards, detail sections               |
/// | thick     | `.thickMaterial`     | filter bar, tab bar, CTA, preview, title   |
enum GlassLevel {
    case ultraThin
    case regular
    case thick

    /// The SwiftUI system material for this level (used when transparency is on).
    var material: Material {
        switch self {
        case .ultraThin: return .ultraThinMaterial
        case .regular:   return .regularMaterial
        case .thick:     return .thickMaterial
        }
    }

    /// The opaque solid fill for this level (used when Reduce Transparency is on).
    var solid: Color {
        switch self {
        case .ultraThin: return .solidUltraThin
        case .regular:   return .solidRegular
        case .thick:     return .solidThick
        }
    }
}

// MARK: - Glass modifier

/// Renders a glass surface: a material (or solid) fill, a hairline border, a
/// subtle top-edge sheen, and a two-layer drop shadow — approximating the CSS
/// `.glass` rule. Honours `accessibilityReduceTransparency`.
private struct GlassModifier<S: InsettableShape>: ViewModifier {
    let level: GlassLevel
    let shape: S

    /// SwiftUI's reactive Reduce-Transparency flag. Using the environment value
    /// (not a hand-rolled NotificationCenter observer) means the view rebuilds
    /// automatically when the system setting changes.
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background {
                if reduceTransparency {
                    shape.fill(level.solid)
                } else {
                    shape.fill(level.material)
                }
            }
            // Top inner sheen — approximates the CSS `inset 0 .75px 0` highlight
            // by overlaying a thin light gradient that fades out from the top
            // edge, masked to the shape. Dropped under Reduce Transparency.
            .overlay {
                if !reduceTransparency {
                    shape
                        .fill(
                            LinearGradient(
                                colors: [Color.glassSheen, .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .opacity(0.6)
                        .frame(height: 18)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .mask(shape)
                        .allowsHitTesting(false)
                }
            }
            // Hairline glass border.
            .overlay {
                shape.strokeBorder(Color.glassBorder, lineWidth: 0.5)
            }
            // Two-layer drop shadow approximating the CSS box-shadow. The dark
            // mode CSS shadow is heavier; we approximate with a dynamic shadow
            // color and a slightly larger blur. Under Reduce Transparency we
            // keep a single, lighter shadow.
            .modifier(GlassShadow(reduceTransparency: reduceTransparency,
                                  colorScheme: colorScheme))
    }
}

/// The two-layer drop shadow. Light values come straight from system.css; the
/// dark scheme uses heavier opacity to mirror the heavier dark CSS shadow.
private struct GlassShadow: ViewModifier {
    let reduceTransparency: Bool
    let colorScheme: ColorScheme

    func body(content: Content) -> some View {
        if reduceTransparency {
            // Simpler single shadow when transparency is reduced.
            content.shadow(color: .glassShadow.opacity(colorScheme == .dark ? 0.40 : 0.08),
                           radius: colorScheme == .dark ? 14 : 10, x: 0, y: 6)
        } else if colorScheme == .dark {
            // Dark: 0 2px 6px rgba(0,0,0,.40), 0 18px 44px rgba(0,0,0,.40)
            content
                .shadow(color: .black.opacity(0.40), radius: 3, x: 0, y: 2)
                .shadow(color: .black.opacity(0.40), radius: 22, x: 0, y: 18)
        } else {
            // Light: 0 1px 2px rgba(20,18,15,.05), 0 12px 34px rgba(20,18,15,.10)
            content
                .shadow(color: Color(hex: 0x14120F, opacity: 0.05), radius: 1, x: 0, y: 1)
                .shadow(color: Color(hex: 0x14120F, opacity: 0.10), radius: 17, x: 0, y: 12)
        }
    }
}

// MARK: - View extension

extension View {
    /// Render `self` as a glass surface clipped to `shape`.
    ///
    /// - Parameters:
    ///   - level: the material level (default `.regular`).
    ///   - shape: the surface shape (default a continuous card-radius rounded rect).
    ///
    /// Applies a material (or opaque solid under Reduce Transparency) fill, a
    /// 0.5pt glass border, a subtle top sheen, and a two-layer drop shadow.
    func glass<S: InsettableShape>(
        _ level: GlassLevel = .regular,
        in shape: S = RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
    ) -> some View {
        modifier(GlassModifier(level: level, shape: shape))
    }
}

// MARK: - Convenience card

/// A ready-made glass card container for the most common use — a regular-glass
/// rounded rectangle with comfortable padding. Wrap content in this for simple
/// card surfaces; reach for `.glass(_:in:)` directly when you need control.
struct GlassCard<Content: View>: View {
    var level: GlassLevel = .regular
    var cornerRadius: CGFloat = Radius.card
    var padding: CGFloat = 14
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glass(level, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: - Previews

#Preview("Glass levels — light") {
    ZStack {
        SmashBackdrop()
        VStack(spacing: 20) {
            glassSample("Ultra-thin", .ultraThin)
            glassSample("Regular", .regular)
            glassSample("Thick", .thick)
        }
        .padding(28)
    }
    .preferredColorScheme(.light)
}

#Preview("Glass levels — dark") {
    ZStack {
        SmashBackdrop()
        VStack(spacing: 20) {
            glassSample("Ultra-thin", .ultraThin)
            glassSample("Regular", .regular)
            glassSample("Thick", .thick)
        }
        .padding(28)
    }
    .preferredColorScheme(.dark)
}

@ViewBuilder
private func glassSample(_ title: String, _ level: GlassLevel) -> some View {
    Text(title)
        .font(.headline)
        .foregroundStyle(Color.textPrimary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .glass(level)
}
