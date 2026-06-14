import SwiftUI

// MARK: - List header

/// The custom List-screen header — drawn in place of the system navigation bar.
///
/// Mirrors `AppHeader` in `design_handoff_smash/app/screens.jsx`:
/// - **Left**: the "Smash" wordmark (Display weight) with a small glowing green
///   status dot, and a "Find a court · Sydney" subtitle.
/// - **Right**: a 42×42 circular ultra-thin glass "locate" pill with a green
///   `location.fill` icon that requests the user's location.
///
/// Side padding is ~18pt to match `Spacing.screen`.
struct ListHeader: View {
    /// Invoked when the locate pill is tapped (host wires this to the location
    /// service via the app environment).
    let onLocate: () -> Void

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 1) {
                HStack(alignment: .center, spacing: 8) {
                    Text("Smash")
                        .font(.system(size: 32, weight: .black))
                        .tracking(-1.5)
                        .foregroundStyle(Color.textPrimary)

                    Circle()
                        .fill(Color.green)
                        .frame(width: 9, height: 9)
                        .greenGlow()
                }

                Text("Find a court · Sydney")
                    .font(Typography.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer(minLength: Spacing.md)

            locateButton
        }
        .padding(.horizontal, Spacing.screen)
        .padding(.top, 2)
    }

    private var locateButton: some View {
        Button(action: onLocate) {
            Image(systemName: "location.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.green)
                .frame(width: 42, height: 42)
                .glass(.ultraThin, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Find courts near me")
    }
}

// MARK: - Previews

#Preview("List header — light") {
    ZStack(alignment: .top) {
        SmashBackdrop()
        ListHeader(onLocate: {})
            .padding(.top, 60)
    }
    .preferredColorScheme(.light)
}

#Preview("List header — dark") {
    ZStack(alignment: .top) {
        SmashBackdrop()
        ListHeader(onLocate: {})
            .padding(.top, 60)
    }
    .preferredColorScheme(.dark)
}
