import SwiftUI

// MARK: - Skeleton card

/// A loading placeholder shaped like a ``VenueRow`` — a regular-glass card with
/// faint rounded-rectangle blocks that carry the ``shimmer()`` sweep.
///
/// Mirrors `SkeletonCard` in `design_handoff_smash/app/cards.jsx`: a 58pt tile
/// placeholder on the left and three text-line placeholders (70% / 40% / 55%
/// width) on the right. Padding (14) and the card radius match `VenueRow` so the
/// loading list shares the same rhythm as the loaded list.
struct SkeletonCard: View {
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            // Court-tile placeholder.
            block(width: 58, height: 58, radius: Radius.tile)

            // Text-line placeholders.
            VStack(alignment: .leading, spacing: 8) {
                line(widthFraction: 0.70, height: 14)
                line(widthFraction: 0.40, height: 10)
                line(widthFraction: 0.55, height: 10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .glass(.regular, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
    }

    // MARK: - Building blocks

    /// A fixed-size faint placeholder block carrying the shimmer.
    private func block(width: CGFloat, height: CGFloat, radius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(Color.chipBackground)
            .frame(width: width, height: height)
            .shimmer()
    }

    /// A flexible-width line placeholder (fraction of available width).
    private func line(widthFraction: CGFloat, height: CGFloat) -> some View {
        GeometryReader { geo in
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.chipBackground)
                .frame(width: geo.size.width * widthFraction, height: height)
                .shimmer()
        }
        .frame(height: height)
    }
}

// MARK: - Previews

#Preview("Skeleton cards — light") {
    ZStack {
        SmashBackdrop()
        VStack(spacing: Spacing.cardGap) {
            ForEach(0..<4, id: \.self) { _ in SkeletonCard() }
        }
        .padding(.horizontal, Spacing.md)
    }
    .preferredColorScheme(.light)
}

#Preview("Skeleton cards — dark") {
    ZStack {
        SmashBackdrop()
        VStack(spacing: Spacing.cardGap) {
            ForEach(0..<4, id: \.self) { _ in SkeletonCard() }
        }
        .padding(.horizontal, Spacing.md)
    }
    .preferredColorScheme(.dark)
}
