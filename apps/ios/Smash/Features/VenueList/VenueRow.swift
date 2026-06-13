import SwiftUI

/// A single venue row in the list. Ports `VenueRow.tsx`.
///
/// Layout: leading column with the name (+ a green "Dedicated" badge) and
/// suburb; trailing column with the price line, court count, and distance.
struct VenueRow: View {
    let venue: VenueListItem

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.sm) {
            // Leading: name (+ badge) and suburb.
            VStack(alignment: .leading, spacing: Spacing.xs / 2) {
                HStack(spacing: Spacing.sm) {
                    Text(venue.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.smashText)
                        .lineLimit(1)

                    if venue.dedicatedBadminton {
                        dedicatedBadge
                    }
                }

                Text(venue.suburb)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.smashTextSecondary)
            }

            Spacer(minLength: Spacing.sm)

            // Trailing: price / courts / distance.
            VStack(alignment: .trailing, spacing: Spacing.xs / 2) {
                Text(priceText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.smashText)

                Text(courtCountText)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.smashTextSecondary)

                if let distanceKm = venue.distanceKm {
                    Text(String(format: "%.1f km", distanceKm))
                        .font(.system(size: 12))
                        .foregroundStyle(Color.smashTextSecondary)
                }
            }
        }
        .padding(.vertical, Spacing.xs)
    }

    // MARK: - Subviews

    private var dedicatedBadge: some View {
        Text("Dedicated")
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.xs + 2)
            .padding(.vertical, Spacing.xs / 2)
            .background(Color.smashPrimary, in: RoundedRectangle(cornerRadius: 4))
    }

    // MARK: - Derived text

    /// Deliberate delta vs RN: when `priceFrom` is nil we show just
    /// "Rates not listed" (no "From " prefix). RN renders "From Rates not
    /// listed" because its template always prepends "From ".
    private var priceText: String {
        venue.priceFrom == nil
            ? "Rates not listed"
            : "From \(formatPriceCents(venue.priceFrom))"
    }

    private var courtCountText: String {
        "\(venue.courtCount) " + (venue.courtCount == 1 ? "court" : "courts")
    }
}

// MARK: - Preview

#Preview {
    List {
        VenueRow(venue: VenueListItem(
            id: "1", name: "Sydney Olympic Park Badminton Centre",
            suburb: "Sydney Olympic Park",
            lat: -33.85, lng: 151.07,
            courtCount: 12, dedicatedBadminton: true,
            distanceKm: 3.4, priceFrom: 2800,
            hasLiveAvailability: true
        ))
        VenueRow(venue: VenueListItem(
            id: "2", name: "Community Sports Hall",
            suburb: "Parramatta",
            lat: -33.81, lng: 151.00,
            courtCount: 1, dedicatedBadminton: false,
            distanceKm: nil, priceFrom: nil,
            hasLiveAvailability: false
        ))
    }
}
