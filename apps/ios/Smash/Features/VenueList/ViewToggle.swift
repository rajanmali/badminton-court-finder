import SwiftUI

// MARK: - View mode

/// Which presentation the venue list screen is showing. Ports the RN
/// `'list' | 'map'` union used by `ViewToggle.tsx` / `VenueListScreen.tsx`.
enum ViewMode: Sendable, Equatable {
    case list
    case map
}

// MARK: - ViewToggle

/// A centered, 160pt-wide segmented control with "List" and "Map" segments.
/// Ports `ViewToggle.tsx`.
///
/// The active segment is a white pill with a subtle shadow and bold dark text;
/// the inactive segment is grey text on the light-grey track. Built as a custom
/// two-button `HStack` rather than a `Picker(.segmented)` so the white-pill +
/// shadow look matches the RN spec exactly (the system segmented style cannot
/// reproduce the per-segment shadow).
struct ViewToggle: View {
    @Binding var mode: ViewMode

    var body: some View {
        HStack(spacing: 0) {
            segment(title: "List", value: .list)
            segment(title: "Map", value: .map)
        }
        .padding(3)
        .background(Color(hex: 0xF0F0F0))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .frame(width: 160)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(12)
    }

    @ViewBuilder
    private func segment(title: String, value: ViewMode) -> some View {
        let isActive = mode == value
        Button {
            mode = value
        } label: {
            Text(title)
                .font(.system(size: 14, weight: isActive ? .bold : .medium))
                .foregroundStyle(isActive ? Color(hex: 0x111111) : Color(hex: 0x888888))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background {
                    if isActive {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 1)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var mode: ViewMode = .list
    return ViewToggle(mode: $mode)
}
