import SwiftUI

// MARK: - FiltersButton

/// A reusable glass "Filters" pill used by both the List and Map tabs to open
/// the shared ``FiltersSheet``.
///
/// Shows a `slider.horizontal.3` glyph, the "Filters" label, and a small green
/// active dot when any filter is engaged. The hit target is ≥44pt tall and it
/// carries a "Filters" VoiceOver label.
struct FiltersButton: View {
    /// Whether any filter is currently engaged — drives the active dot.
    let isActive: Bool
    /// Invoked on tap (the host presents the ``FiltersSheet``).
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.green)
                Text("Filters")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                if isActive {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 7, height: 7)
                        .greenGlow()
                }
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 14)
            .frame(minHeight: 44)
            .glass(.thick, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Filters")
        .accessibilityValue(isActive ? "Active" : "")
    }
}

// MARK: - Previews

#Preview("FiltersButton — inactive, light") {
    ZStack {
        SmashBackdrop()
        FiltersButton(isActive: false, action: {})
    }
    .preferredColorScheme(.light)
}

#Preview("FiltersButton — active, dark") {
    ZStack {
        SmashBackdrop()
        FiltersButton(isActive: true, action: {})
    }
    .preferredColorScheme(.dark)
}
