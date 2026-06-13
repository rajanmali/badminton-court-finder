import SwiftUI

/// The venue detail screen. Ports `VenueDetailScreen.tsx`.
///
/// Receives the venue `id` and `name` from the navigation route. The nav title
/// is set to `name` immediately from the route param — before the fetch resolves —
/// so the title is always visible. The fetch then populates the rest of the UI.
///
/// ## Loading states
/// - `.loading` → large green spinner centred
/// - `.failed` → `ContentUnavailableView` with the error message (generic; no special 404 UI)
/// - `.loaded` → scroll view with header, rate cards, opening hours, and booking CTA
struct VenueDetailScreen: View {

    let venueId: String
    let venueName: String

    @State private var model = VenueDetailModel()
    @Environment(\.appEnvironment) private var env
    @Environment(\.openURL) private var openURL

    var body: some View {
        content
            .navigationTitle(venueName)
            .navigationBarTitleDisplayMode(.inline)
            .task { await model.load(id: venueId, using: env.venueRepository) }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .loading:
            ProgressView()
                .controlSize(.large)
                .tint(.smashPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case let .failed(message):
            ContentUnavailableView {
                Label("Could not load venue", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            }

        case let .loaded(venue):
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // MARK: Header
                    VenueHeaderView(venue: venue)

                    Divider()
                        .padding(.top, Spacing.sm)

                    // MARK: Court hire rates
                    SectionTitle("Court hire rates")

                    if venue.rateCards.isEmpty {
                        Text("Rates not listed")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.smashTextSecondary)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(venue.rateCards) { card in
                                RateCardView(rateCard: card)
                                if card.id != venue.rateCards.last?.id {
                                    Divider()
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.md)
                    }

                    Divider()
                        .padding(.top, Spacing.sm)

                    // MARK: Opening hours
                    SectionTitle("Opening hours")

                    if venue.openingHours.isEmpty {
                        Text("Hours not listed")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.smashTextSecondary)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                    } else {
                        OpeningHoursView(hours: venue.openingHours)
                            .padding(.horizontal, Spacing.md)
                    }

                    // MARK: Booking CTA
                    BookingCTAView(venue: venue, openURL: openURL)
                        .padding(.top, Spacing.lg)
                        .padding(.bottom, Spacing.xl)
                }
            }
        }
    }
}

// MARK: - VenueHeaderView

private struct VenueHeaderView: View {
    let venue: VenueDetail

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(alignment: .center, spacing: Spacing.sm) {
                Text(venue.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.smashText)

                if venue.dedicatedBadminton {
                    Text("Dedicated")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.smashPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }

            Text(venue.suburb)
                .font(.system(size: 15))
                .foregroundStyle(Color(hex: 0x555555))

            if !venue.address.isEmpty {
                Text(venue.address)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(hex: 0x888888))
            }

            Text(metaLine(venue))
                .font(.system(size: 13))
                .foregroundStyle(Color.smashTextSecondary)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.sm)
    }

    private func metaLine(_ venue: VenueDetail) -> String {
        var parts = ["\(venue.courtCount) court\(venue.courtCount == 1 ? "" : "s")"]
        if let price = venue.priceFrom {
            parts.append("From \(formatPriceCents(price))")
        }
        return parts.joined(separator: "  ·  ")
    }
}

// MARK: - SectionTitle

private struct SectionTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Color.smashTextSecondary)
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.sm)
    }
}

// MARK: - BookingCTAView

private struct BookingCTAView: View {
    let venue: VenueDetail
    let openURL: OpenURLAction

    var body: some View {
        let action = getBookingAction(
            bookingUrl: venue.bookingUrl,
            phone: venue.phone,
            email: venue.email
        )

        switch action {
        case .none:
            EmptyView()

        case let .url(label, href),
             let .phone(label, href),
             let .email(label, href):
            Button {
                guard let url = URL(string: href) else { return }
                openURL(url)
            } label: {
                Text(label)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
            }
            .background(Color.smashPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, Spacing.md)
        }
    }
}
