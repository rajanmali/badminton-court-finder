import SwiftUI

// MARK: - Shared wordmark

/// The "Smash" wordmark used by both the List and Map top-chrome headers.
/// Parameterised so each caller controls font scale and dot size independently.
struct SmashWordmark: View {
    var titleFont: Font = .system(size: 32, weight: .black)
    var titleTracking: CGFloat = -1.5
    var dotSize: CGFloat = 9
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(alignment: .center, spacing: 8) {
                Text("Smash")
                    .font(titleFont)
                    .tracking(titleTracking)
                    .foregroundStyle(Color.textPrimary)
                Circle()
                    .fill(Color.green)
                    .frame(width: dotSize, height: dotSize)
                    .greenGlow()
            }
            if let subtitle {
                Text(subtitle)
                    .font(Typography.caption)
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }
}

// MARK: - List header

/// The custom List-screen header — drawn in place of the system navigation bar.
///
/// Mirrors `AppHeader` in `design_handoff_smash/app/screens.jsx`:
/// - **Left**: the "Smash" wordmark (Display weight) with a small glowing green
///   status dot, and a "Find a court" subtitle.
/// - **Right**: a ``FiltersButton`` and a 42×42 circular ultra-thin glass
///   "locate" pill.
///
/// The header background is invisible when the list is at rest and fades in as
/// a thick-glass material as `glassProgress` rises from 0 → 1 (driven by the
/// scroll position in ``VenueListScreen``). A `LinearGradient` masks the bottom
/// edge of the glass so it dissolves smoothly into the content below.
struct ListHeader: View {
    /// Invoked when the locate pill is tapped.
    let onLocate: () -> Void
    /// Invoked when the Filters pill is tapped.
    let onOpenFilters: () -> Void
    /// Whether any filter is engaged — drives the Filters pill's active dot.
    let filtersActive: Bool
    /// 0 = fully transparent (at rest); 1 = fully opaque glass (content scrolled under).
    var glassProgress: CGFloat = 0

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        HStack(alignment: .bottom) {
            SmashWordmark(subtitle: "Find a court")

            Spacer(minLength: Spacing.md)

            HStack(spacing: 8) {
                FiltersButton(isActive: filtersActive, action: onOpenFilters)
                locateButton
            }
        }
        .padding(.horizontal, Spacing.screen)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.sm)
        // Scroll-driven glass background: invisible at rest, fades in as the
        // user scrolls content under the header. A gradient mask dissolves the
        // bottom edge so there is no hard cut-off line.
        .background {
            if glassProgress > 0 {
                glassBackground
                    .opacity(Double(glassProgress))
            }
        }
    }

    // MARK: - Glass background

    private var glassBackground: some View {
        let shape = Rectangle()
        return Group {
            if reduceTransparency {
                shape.fill(Color.solidThick)
            } else {
                shape.fill(.thickMaterial)
            }
        }
        // Gradient mask: fully opaque at the top, dissolving to clear at the
        // bottom so there is no hard edge between the header and the content.
        .mask(
            LinearGradient(
                stops: [
                    .init(color: .black, location: 0.0),
                    .init(color: .black, location: 0.72),
                    .init(color: .clear,  location: 1.0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Locate button

    private var locateButton: some View {
        Button(action: onLocate) {
            Image(systemName: "location.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.green)
                .frame(width: 42, height: 42)
                .glass(.ultraThin, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Use my location")
        .accessibilityHint("Find courts near your current location")
    }
}

// MARK: - Previews

#Preview("List header — at rest, light") {
    ZStack(alignment: .top) {
        SmashBackdrop()
        ListHeader(onLocate: {}, onOpenFilters: {}, filtersActive: false, glassProgress: 0)
            .padding(.top, 60)
    }
    .preferredColorScheme(.light)
}

#Preview("List header — glass faded in, dark") {
    ZStack(alignment: .top) {
        SmashBackdrop()
        ListHeader(onLocate: {}, onOpenFilters: {}, filtersActive: true, glassProgress: 1)
    }
    .preferredColorScheme(.dark)
}
