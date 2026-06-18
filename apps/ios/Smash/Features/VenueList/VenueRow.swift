import SwiftUI

// MARK: - Card press button style

/// Wraps the glass card content to provide a spring press-scale (0.96×) that
/// works correctly inside a NavigationLink, which normally swallows
/// configuration.isPressed.  By making the VenueRow content into a ButtonStyle
/// body we hook directly into the link's interaction — the NavigationLink(value:)
/// uses `.buttonStyle(.venueCard)` so SwiftUI routes the press state here.
struct VenueCardButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let pressSpring = Animation.spring(response: 0.42, dampingFraction: 0.7)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(reduceMotion ? nil : pressSpring, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == VenueCardButtonStyle {
    static var venueCard: VenueCardButtonStyle { VenueCardButtonStyle() }
}

// MARK: - Venue row (glass V1 card)

/// A single venue card in the list — the glass "V1" design from the handoff.
///
/// Matches the `VenueCard` component in `design_handoff_smash/app/cards.jsx`:
/// - Container: `.glass(.regular)` with radius 26 and 14 pt padding.
/// - Left thumbnail: `CourtTile` (58 × 58).
/// - Middle: name + `DedicatedBadge`; suburb with pin icon; courts + optional distance.
/// - Right: "FROM" micro label + price in green; or "Rates not listed" when nil; chevron.
///
/// Press-scale (0.96, spring) is applied via `VenueCardButtonStyle` so it works
/// correctly when this view is the label of a `NavigationLink(value:)`.
struct VenueRow: View {
    let venue: VenueListItem

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            // ── Left: court tile ────────────────────────────────────────
            CourtTile(
                initial: String(venue.name.prefix(1)).uppercased(),
                dedicated: venue.dedicatedBadminton,
                size: 58
            )

            // ── Middle: name / suburb / meta ────────────────────────────
            VStack(alignment: .leading, spacing: 4) {
                // Name + badge row
                HStack(spacing: 6) {
                    Text(venue.name)
                        .font(Typography.cardTitle)
                        .tracking(-0.4)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    if venue.dedicatedBadminton {
                        DedicatedBadge()
                            .fixedSize()
                    }
                }

                // Suburb row
                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.textTertiary)
                    Text(venue.suburb)
                        .font(Typography.caption)
                        .foregroundStyle(Color.textSecondary)
                }

                // Meta row: courts + optional distance
                HStack(spacing: 10) {
                    HStack(spacing: 4) {
                        Image(systemName: "sportscourt.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.textTertiary)
                        Text(courtCountText)
                            .font(Typography.caption)
                            .foregroundStyle(Color.textSecondary)
                    }
                    if let distanceKm = venue.distanceKm {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color.textTertiary)
                            Text(String(format: "%.1f km", distanceKm))
                                .font(Typography.caption)
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // ── Right: price / chevron ──────────────────────────────────
            VStack(alignment: .trailing, spacing: 2) {
                if let cents = venue.priceFrom {
                    // "FROM" micro label
                    Text("FROM")
                        .font(Typography.micro)
                        .tracking(0.5)
                        .foregroundStyle(Color.textTertiary)

                    // Price + /hr
                    HStack(alignment: .lastTextBaseline, spacing: 1) {
                        Text("$\(priceDollars(cents))")
                            .font(Typography.price)
                            .tracking(-1.0)
                            .foregroundStyle(Color.green)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text("/hr")
                            .font(Typography.caption)
                            .foregroundStyle(Color.textTertiary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                } else {
                    MissingDataPill("Rates not listed")
                }

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.textTertiary)
                    .padding(.top, 6)
            }
        }
        .padding(14)
        .glass(.regular, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
    }

    // MARK: - Helpers

    private var courtCountText: String {
        "\(venue.courtCount) " + (venue.courtCount == 1 ? "court" : "courts")
    }

    /// Converts cents to whole dollars (rounding).
    private func priceDollars(_ cents: Int) -> Int {
        Int((Double(cents) / 100).rounded())
    }
}

// MARK: - Preview

#Preview("Venue cards — light") {
    ZStack {
        SmashBackdrop()
        ScrollView {
            VStack(spacing: 13) {
                // Dedicated venue with price and distance
                VenueRow(venue: VenueListItem(
                    id: "1",
                    name: "Sydney Olympic Park Badminton Centre",
                    suburb: "Olympic Park",
                    lat: -33.85, lng: 151.07,
                    courtCount: 12,
                    dedicatedBadminton: true,
                    distanceKm: 3.4,
                    priceFrom: 2900,
                    hasLiveAvailability: true
                ))
                // Multi-sport, with price
                VenueRow(venue: VenueListItem(
                    id: "2",
                    name: "Auburn Basketball Stadium",
                    suburb: "Auburn",
                    lat: -33.85, lng: 151.02,
                    courtCount: 4,
                    dedicatedBadminton: false,
                    distanceKm: 7.1,
                    priceFrom: 3400,
                    hasLiveAvailability: false
                ))
                // No price, no distance
                VenueRow(venue: VenueListItem(
                    id: "3",
                    name: "Parramatta Community Hall",
                    suburb: "Parramatta",
                    lat: -33.81, lng: 151.00,
                    courtCount: 2,
                    dedicatedBadminton: false,
                    distanceKm: nil,
                    priceFrom: nil,
                    hasLiveAvailability: false
                ))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }
    .preferredColorScheme(.light)
}

#Preview("Venue cards — dark") {
    ZStack {
        SmashBackdrop()
        ScrollView {
            VStack(spacing: 13) {
                VenueRow(venue: VenueListItem(
                    id: "1",
                    name: "Sydney Olympic Park Badminton Centre",
                    suburb: "Olympic Park",
                    lat: -33.85, lng: 151.07,
                    courtCount: 12,
                    dedicatedBadminton: true,
                    distanceKm: 3.4,
                    priceFrom: 2900,
                    hasLiveAvailability: true
                ))
                VenueRow(venue: VenueListItem(
                    id: "2",
                    name: "Auburn Basketball Stadium",
                    suburb: "Auburn",
                    lat: -33.85, lng: 151.02,
                    courtCount: 4,
                    dedicatedBadminton: false,
                    distanceKm: 7.1,
                    priceFrom: 3400,
                    hasLiveAvailability: false
                ))
                VenueRow(venue: VenueListItem(
                    id: "3",
                    name: "Parramatta Community Hall",
                    suburb: "Parramatta",
                    lat: -33.81, lng: 151.00,
                    courtCount: 2,
                    dedicatedBadminton: false,
                    distanceKm: nil,
                    priceFrom: nil,
                    hasLiveAvailability: false
                ))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }
    .preferredColorScheme(.dark)
}
