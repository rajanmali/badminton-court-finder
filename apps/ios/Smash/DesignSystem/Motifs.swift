// Smash brand motifs — halftone dot field, badminton court lines, court tile,
// and the screen backdrop. Mirror the primitives in
// design_handoff_smash/app/glass.jsx (`Halftone`, `CourtLines`, `CourtTile`,
// `Backdrop`) and the `.halftone` rule in system.css.

import SwiftUI

// MARK: - Halftone

/// A field of evenly spaced dots — the Smash halftone motif. Used in court
/// tiles, the backdrop, and empty/error states.
///
/// Mirrors `.halftone` in system.css: `radial-gradient(currentColor 1.5px,
/// transparent 1.8px)` on a 13×13 grid. Rendered here with `Canvas` so it tiles
/// crisply at any size.
struct Halftone: View {
    /// Dot radius in points (default ~1.5, matching the CSS dot size).
    var dotSize: CGFloat = 1.5
    /// Grid spacing in points (default 13, matching `.halftone`).
    var spacing: CGFloat = 13
    /// Dot tint.
    var color: Color = .primary
    /// Overall opacity.
    var opacity: Double = 1

    var body: some View {
        Canvas { context, size in
            let diameter = dotSize * 2
            var y = spacing / 2
            while y < size.height + spacing {
                var x = spacing / 2
                while x < size.width + spacing {
                    let rect = CGRect(x: x - dotSize, y: y - dotSize,
                                      width: diameter, height: diameter)
                    context.fill(Path(ellipseIn: rect), with: .color(color))
                    x += spacing
                }
                y += spacing
            }
        }
        .opacity(opacity)
        .allowsHitTesting(false)
    }
}

// MARK: - Court lines

/// A simplified badminton court drawn as thin strokes: outer box, side tram
/// lines, service lines, center line, and the net as a dashed line.
///
/// Mirrors `CourtLines` in glass.jsx (viewBox 100×220). Drawn with `Canvas` and
/// scaled to fill its frame.
struct CourtLines: View {
    /// Stroke color.
    var color: Color = .white.opacity(0.5)
    /// Stroke width, expressed in the 100×220 design space.
    var lineWidth: CGFloat = 1.4
    /// Overall opacity.
    var opacity: Double = 1

    // Design coordinate space (matches the JSX viewBox).
    private let designW: CGFloat = 100
    private let designH: CGFloat = 220

    var body: some View {
        Canvas { context, size in
            let sx = size.width / designW
            let sy = size.height / designH
            // Use the smaller scale for the stroke so it stays even.
            let strokeScale = min(sx, sy)

            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
                CGPoint(x: x * sx, y: y * sy)
            }

            var solid = Path()
            // Outer box.
            solid.addRect(CGRect(x: 6 * sx, y: 6 * sy,
                                 width: 88 * sx, height: 208 * sy))
            // Side tram lines.
            solid.move(to: p(14, 6));  solid.addLine(to: p(14, 214))
            solid.move(to: p(86, 6));  solid.addLine(to: p(86, 214))
            // Long service / doubles lines.
            solid.move(to: p(6, 40));  solid.addLine(to: p(94, 40))
            solid.move(to: p(6, 180)); solid.addLine(to: p(94, 180))
            // Short service lines.
            solid.move(to: p(6, 92));  solid.addLine(to: p(94, 92))
            solid.move(to: p(6, 128)); solid.addLine(to: p(94, 128))
            // Center lines (service court split).
            solid.move(to: p(50, 40));  solid.addLine(to: p(50, 92))
            solid.move(to: p(50, 128)); solid.addLine(to: p(50, 180))

            context.stroke(solid, with: .color(color),
                           lineWidth: lineWidth * strokeScale)

            // Net — dashed center line.
            var net = Path()
            net.move(to: p(6, 110)); net.addLine(to: p(94, 110))
            context.stroke(net, with: .color(color),
                           style: StrokeStyle(lineWidth: lineWidth * strokeScale,
                                              dash: [3 * strokeScale, 4 * strokeScale]))
        }
        .opacity(opacity)
        .allowsHitTesting(false)
    }
}

// MARK: - Court tile

/// A venue thumbnail: a rounded gradient square overlaid with faint court
/// lines, a small halftone, and the venue's initial letter.
///
/// Mirrors `CourtTile` in glass.jsx. Dedicated venues use a green gradient;
/// multi-sport venues use grey.
struct CourtTile: View {
    /// The initial letter(s) to render (e.g. first character of the venue name).
    var initial: String
    /// Whether this is a dedicated badminton venue (drives the gradient color).
    var dedicated: Bool
    /// Tile edge length in points (default 58).
    var size: CGFloat = 58

    private var gradient: LinearGradient {
        dedicated
            ? LinearGradient(colors: [.greenBright, .greenDeep],
                             startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(colors: [Color(hex: 0x3A4046), Color(hex: 0x1D2125)],
                             startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Radius.tile, style: .continuous)
        ZStack {
            shape.fill(gradient)
            CourtLines(color: .white.opacity(0.30), lineWidth: 1.2)
            Halftone(dotSize: 1.0, spacing: 9, color: .white.opacity(0.5), opacity: 0.35)
            Text(initial)
                .font(.system(size: size * 0.4, weight: .black))
                .tracking(-1)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 1)
        }
        .frame(width: size, height: size)
        .clipShape(shape)
        // inset top highlight + soft drop shadow, from the CSS boxShadow.
        .overlay {
            shape.strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                .mask(LinearGradient(colors: [.white, .clear],
                                     startPoint: .top, endPoint: .center))
        }
        .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 4)
    }
}

// MARK: - Smash backdrop

/// A full-screen background that glass surfaces read against: the page base,
/// a soft green radial tint in the top corner, and a faint large halftone.
///
/// Mirrors `Backdrop` in glass.jsx — kept deliberately subtle.
struct SmashBackdrop: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Color.pageBackground

            // Soft green radial tint, anchored toward the top-right corner.
            RadialGradient(
                colors: [
                    Color(hex: 0x2BB183, opacity: colorScheme == .dark ? 0.22 : 0.24),
                    .clear
                ],
                center: UnitPoint(x: 0.86, y: -0.02),
                startRadius: 0,
                endRadius: 420
            )

            // Faint BWF-red counter-tint on the opposite corner (subtle warmth).
            RadialGradient(
                colors: [
                    Color(hex: 0xE5392B, opacity: colorScheme == .dark ? 0.14 : 0.10),
                    .clear
                ],
                center: UnitPoint(x: -0.10, y: 0.07),
                startRadius: 0,
                endRadius: 360
            )

            // Large faint halftone in the top-right, faded by a radial mask.
            Halftone(
                dotSize: 1.6,
                spacing: 20,
                color: colorScheme == .dark
                    ? Color(hex: 0x2BB183, opacity: 0.30)
                    : Color(hex: 0x075E40, opacity: 0.38),
                opacity: colorScheme == .dark ? 0.5 : 0.45
            )
            .mask(
                RadialGradient(
                    colors: [.black, .black.opacity(0.5), .clear],
                    center: UnitPoint(x: 0.88, y: 0.04),
                    startRadius: 0,
                    endRadius: 380
                )
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Previews

#Preview("Halftone + court lines") {
    ZStack {
        Color.pageBackground.ignoresSafeArea()
        VStack(spacing: 28) {
            Halftone(color: .green, opacity: 0.6)
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            CourtLines(color: .green, lineWidth: 1.6)
                .frame(width: 120, height: 220)
        }
        .padding()
    }
}

#Preview("Court tiles") {
    ZStack {
        SmashBackdrop()
        HStack(spacing: 20) {
            CourtTile(initial: "S", dedicated: true)
            CourtTile(initial: "M", dedicated: false)
            CourtTile(initial: "B", dedicated: true, size: 80)
        }
    }
}

#Preview("Backdrop — dark") {
    SmashBackdrop()
        .preferredColorScheme(.dark)
}
