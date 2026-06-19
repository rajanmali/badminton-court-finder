import SwiftUI

// MARK: - Loading state

/// The List loading state: a spinner + "Finding courts near you…" caption above
/// four ``SkeletonCard``s. Mirrors `LoadingState` in
/// `design_handoff_smash/app/cards.jsx`.
struct ListLoadingState: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.cardGap) {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(.green)
                    Text("Finding courts near you…")
                        .font(Typography.subhead)
                        .foregroundStyle(Color.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 4)

                ForEach(0..<4, id: \.self) { _ in
                    SkeletonCard()
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.sm)
            // Clear the floating tab bar — keep in sync with TabBar.reservedBottomSpace.
            .padding(.bottom, TabBar.reservedBottomSpace)
        }
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Meta row

/// The "{n} venues · {sort}" row shown above the loaded card list.
///
/// The old inert "Nearest first ⌄" control is gone — sort now lives in the
/// shared Filters sheet. This row instead appends the active sort as a
/// non-interactive hint so the user can see how the list is ordered.
/// Mirrors the meta row in `ListScreen` (`screens.jsx`).
struct ListMetaRow: View {
    let count: Int
    /// The active sort's label, shown as a non-interactive hint after the count.
    let sortLabel: String

    var body: some View {
        Text("\(count) \(count == 1 ? "venue" : "venues") · \(sortLabel)")
            .font(Typography.caption)
            .foregroundStyle(Color.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.md)
    }
}

// MARK: - Empty state

/// The List empty state: a halftone-filled glass icon square, a title, a
/// secondary explanation, and a green "Reset filters" button.
/// Mirrors `EmptyState` in `cards.jsx`.
struct ListEmptyState: View {
    /// Invoked when the user taps "Reset filters".
    let onReset: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            StateIcon(systemImage: "figure.badminton", tint: .green)
                .padding(.bottom, 22)

            Text("No venues match your filters")
                .font(Typography.title)
                .tracking(-0.6)
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)

            Text("Try widening your distance or price filters.")
                .font(Typography.subhead)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 270)
                .padding(.bottom, 22)

            Button("Reset filters", action: onReset)
                .buttonStyle(.primary)
                .frame(width: 220)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 26)
    }
}

// MARK: - Error state

/// The List error state: a halftone-filled glass icon square (red), a title,
/// secondary copy, and a glass "Try again" capsule button.
/// Mirrors `ErrorState` in `cards.jsx`.
struct ListErrorState: View {
    /// Invoked when the user taps "Try again".
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            StateIcon(systemImage: "info.circle", tint: .red)
                .padding(.bottom, 22)

            Text("Couldn't load courts")
                .font(Typography.title)
                .tracking(-0.6)
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)

            Text("Check your connection and try again. Your filters have been saved.")
                .font(Typography.subhead)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 270)
                .padding(.bottom, 22)

            Button(action: onRetry) {
                HStack(spacing: 7) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .bold))
                    Text("Try again")
                        .font(Typography.subhead)
                        .tracking(-0.2)
                }
                .foregroundStyle(Color.textPrimary)
                .padding(.vertical, 14)
                .padding(.horizontal, 22)
                .glass(.regular, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 26)
    }
}

// MARK: - Shared state icon

/// The 96×96 glass rounded-square icon used by the empty and error states — a
/// faint halftone fill behind a large tinted SF Symbol.
private struct StateIcon: View {
    let systemImage: String
    let tint: Color

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)
        ZStack {
            Halftone(color: tint, opacity: 0.45)
                .mask(
                    RadialGradient(
                        colors: [.black, .black.opacity(0.5), .clear],
                        center: .center, startRadius: 0, endRadius: 60
                    )
                )
            Image(systemName: systemImage)
                .font(.system(size: 40, weight: .regular))
                .foregroundStyle(tint)
        }
        .frame(width: 96, height: 96)
        .clipShape(shape)
        .glass(.regular, in: shape)
    }
}

// MARK: - Previews

#Preview("Empty — light") {
    ZStack {
        SmashBackdrop()
        ListEmptyState(onReset: {})
    }
    .preferredColorScheme(.light)
}

#Preview("Error — dark") {
    ZStack {
        SmashBackdrop()
        ListErrorState(onRetry: {})
    }
    .preferredColorScheme(.dark)
}

#Preview("Loading — light") {
    ZStack {
        SmashBackdrop()
        ListLoadingState()
    }
    .preferredColorScheme(.light)
}
