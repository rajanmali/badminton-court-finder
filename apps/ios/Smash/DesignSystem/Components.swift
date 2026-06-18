// Smash restyled atoms — dedicated badge, filter chip, primary button style,
// and the loading shimmer. Mirror `.badge-ded`, `.chip` / `.chip-on`,
// `.btn-primary`, and `.skeleton` in design_handoff_smash/app/system.css (and
// `Chip` in glass.jsx).

import SwiftUI

// MARK: - Press spring

/// The shared press-feedback spring. Approximates the CSS
/// `cubic-bezier(.34,1.56,.64,1)` ~0.42s used by `.spring` / `.tap:active`.
private let pressSpring = Animation.spring(response: 0.42, dampingFraction: 0.7)

/// The green gradient used by active chips, badges, and the primary button
/// (top→bottom: bright → green).
private let greenAccentGradient = LinearGradient(
    colors: [.greenBright, .green],
    startPoint: .top, endPoint: .bottom
)

// MARK: - Dedicated badge

/// A small green pill marking a dedicated badminton venue.
/// Mirrors `.badge-ded`: green gradient, dark-green text, 11/heavy uppercase.
struct DedicatedBadge: View {
    /// Badge text. Defaults to "Dedicated"; pass a shorter label where space is tight.
    var label: String = "Dedicated"
    /// Whether to show the leading bolt glyph (matches the prototype's icon).
    var showIcon: Bool = true

    var body: some View {
        HStack(spacing: 5) {
            if showIcon {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 9, weight: .black))
            }
            Text(label)
                .font(.system(size: 11, weight: .heavy))
                .tracking(0.3)
                .textCase(.uppercase)
        }
        .foregroundStyle(Color.onAccent)
        .padding(.leading, 7)
        .padding(.trailing, 8)
        .padding(.vertical, 3)
        .background(greenAccentGradient, in: Capsule())
        .greenGlow()
    }
}

// MARK: - Filter chip

/// A selectable capsule filter. Off: chip-background fill + hairline border +
/// primary text. On: green gradient + on-accent text + green glow.
/// Mirrors `.chip` / `.chip-on`.
struct FilterChip: View {
    let title: String
    let isOn: Bool
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            HStack(spacing: 6) {
                if isOn {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                }
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .tracking(-0.2)
                    .lineLimit(1)
            }
            .foregroundStyle(isOn ? Color.onAccent : Color.textPrimary)
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background {
                let shape = Capsule()
                if isOn {
                    shape.fill(greenAccentGradient)
                } else {
                    shape.fill(Color.chipBackground)
                        .overlay(shape.strokeBorder(Color.hairline, lineWidth: 0.5))
                }
            }
            .modifier(ConditionalGreenGlow(active: isOn))
            .fixedSize(horizontal: true, vertical: false)
        }
        .buttonStyle(.plain)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.25), value: isOn)
    }
}

/// Applies the green glow only when `active` (so off-state chips stay flat).
private struct ConditionalGreenGlow: ViewModifier {
    let active: Bool
    func body(content: Content) -> some View {
        if active { content.greenGlow() } else { content }
    }
}

// MARK: - Primary button style

/// Full-width green CTA button. Mirrors `.btn-primary`: 56pt tall, radius 18,
/// vertical green gradient (bright → green → deep), on-accent 18/heavy text,
/// green glow + top sheen, press scale 0.96.
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: Radius.button, style: .continuous)
        return configuration.label
            .font(.system(size: 18, weight: .heavy))
            .tracking(-0.3)
            .foregroundStyle(Color.onAccent)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background {
                shape.fill(
                    LinearGradient(
                        stops: [
                            .init(color: .greenBright, location: 0.0),
                            .init(color: .green,       location: 0.70),
                            .init(color: .greenDeep,   location: 1.0)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
            }
            // Inner top sheen — the CSS `inset 0 1px 0 rgba(255,255,255,.45)`.
            .overlay {
                shape
                    .fill(
                        LinearGradient(colors: [.white.opacity(0.45), .clear],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .frame(height: 14)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .mask(shape)
                    .allowsHitTesting(false)
            }
            .greenGlow()
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(reduceMotion ? nil : pressSpring, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    /// The Smash primary CTA button style.
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

// MARK: - Missing data pill

/// A quiet muted capsule indicating that a data point is not available.
///
/// Reads as an intentional "no data" chip, not an error. Use wherever
/// "Rates not listed" / "Hours not listed" placeholders appear so the
/// treatment is consistent across the app.
///
/// - Parameters:
///   - label: Short description of the missing data (e.g. "Rates not listed").
///   - icon: Optional SF Symbol name shown before the label. Defaults to
///     `"minus.circle"`. Pass `nil` to suppress the icon.
struct MissingDataPill: View {
    private let label: String
    private let icon: String?

    /// - Parameters:
    ///   - label: Short description of the missing data.
    ///   - icon: Optional SF Symbol name shown before the label.
    ///     Defaults to `"minus.circle"`. Pass `nil` to suppress the icon.
    init(_ label: String, icon: String? = "minus.circle") {
        self.label = label
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(label)
                .font(Typography.caption)
                .lineLimit(1)
        }
        .foregroundStyle(Color.textTertiary)
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(Color.textTertiary.opacity(0.12), in: Capsule())
    }
}

// MARK: - Shimmer

/// A loading-skeleton sweep: a moving light gradient that travels across the
/// view (~1.5s linear loop). Mirrors `.skeleton`. The animation is disabled
/// when Reduce Motion is on (the view then renders as a static placeholder).
private struct ShimmerModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geo in
                    let width = geo.size.width
                    LinearGradient(
                        colors: [.clear, Color.glassSheen, .clear],
                        startPoint: .leading, endPoint: .trailing
                    )
                    .frame(width: width * 0.6)
                    .offset(x: reduceMotion ? 0 : phase * width * 1.6)
                    .opacity(reduceMotion ? 0 : 1)
                }
                .allowsHitTesting(false)
            }
            .clipped()
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    /// Apply the loading-skeleton shimmer sweep. Respects Reduce Motion
    /// (renders a static placeholder when motion is reduced).
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Previews

#Preview("Atoms — light") {
    ZStack {
        SmashBackdrop()
        atomsGallery
    }
    .preferredColorScheme(.light)
}

#Preview("Atoms — dark") {
    ZStack {
        SmashBackdrop()
        atomsGallery
    }
    .preferredColorScheme(.dark)
}

private var atomsGallery: some View {
    VStack(spacing: 24) {
        DedicatedBadge()

        HStack(spacing: 8) {
            FilterChip(title: "Any", isOn: true) {}
            FilterChip(title: "5 km", isOn: false) {}
            FilterChip(title: "10 km", isOn: false) {}
        }

        Button("Book a court") {}
            .buttonStyle(.primary)
            .padding(.horizontal, 18)

        // Missing-data pills.
        HStack(spacing: 8) {
            MissingDataPill("Rates not listed")
            MissingDataPill("Hours not listed")
        }

        // Skeleton sample row.
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.chipBackground)
            .frame(height: 56)
            .shimmer()
            .padding(.horizontal, 18)
    }
    .padding(.vertical, 28)
}
