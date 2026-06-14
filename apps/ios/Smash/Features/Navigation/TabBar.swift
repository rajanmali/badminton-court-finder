import SwiftUI

// MARK: - View mode

/// Which presentation the venue browser is showing — list or map. Ports the RN
/// `'list' | 'map'` union and is the selection driving the bottom ``TabBar``.
///
/// Moved here from the deleted `ViewToggle.swift` (the old top segmented control)
/// so it lives alongside the tab bar that now owns the list/map switch.
enum ViewMode: Sendable, Equatable {
    case list
    case map
}

// MARK: - TabBar

/// A centered, floating glass pill that switches between the List and Map tabs.
/// Ports the `TabBar` component in `design_handoff_smash/app/glass.jsx`.
///
/// Visual spec:
/// - Container: thick-glass capsule (`.glass(.thick, in: Capsule())`), ~200pt
///   wide, centered, padded, floating above the home indicator.
/// - Active segment: a solid green capsule (`LinearGradient(.greenBright →
///   .green)`) with `.onAccent` text/icon and a `.greenGlow()`.
/// - Inactive segment: `.textSecondary` text/icon over the bare glass.
/// - The active capsule slides between segments with a spring, gated behind
///   Reduce Motion.
/// - Selecting a tab fires a light haptic (`UIImpactFeedbackGenerator(.light)`).
///
/// The host (``RootTabView``) places this in a bottom-aligned overlay, so a
/// `NavigationStack` push (Venue Detail) naturally covers it — no manual hide.
struct TabBar: View {
    @Binding var selection: ViewMode

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The capsule width per the design (`width: 200` in the prototype).
    private static let width: CGFloat = 200

    /// `Namespace` for the matched-geometry slide of the active capsule between
    /// segments. Animating a single shared capsule (rather than fading two)
    /// reproduces the prototype's "thumb" motion.
    @Namespace private var activeCapsule

    var body: some View {
        HStack(spacing: 4) {
            segment(.list, title: "List", systemImage: "list.bullet")
            segment(.map, title: "Map", systemImage: "map")
        }
        .padding(5)
        .frame(width: Self.width)
        .glass(.thick, in: Capsule())
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: Segment

    @ViewBuilder
    private func segment(_ value: ViewMode, title: String, systemImage: String) -> some View {
        let isActive = selection == value
        Button {
            select(value)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .tracking(-0.2)
            }
            .foregroundStyle(isActive ? Color.onAccent : Color.textSecondary)
            .frame(maxWidth: .infinity)
            // 44pt+ tap target.
            .frame(height: 44)
            .background {
                if isActive {
                    activeBackground
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    /// The solid green active capsule + glow. Uses `matchedGeometryEffect` so it
    /// visually slides from one segment to the other on selection change.
    private var activeBackground: some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [.greenBright, .green],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .greenGlow()
            .matchedGeometryEffect(id: "activeCapsule", in: activeCapsule)
    }

    // MARK: Selection

    /// Switch tabs with a spring (unless Reduce Motion) and a light haptic.
    private func select(_ value: ViewMode) {
        guard value != selection else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if reduceMotion {
            selection = value
        } else {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.75)) {
                selection = value
            }
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selection: ViewMode = .list
    return ZStack {
        SmashBackdrop()
        VStack {
            Spacer()
            TabBar(selection: $selection)
                .padding(.bottom, 26)
        }
    }
}
