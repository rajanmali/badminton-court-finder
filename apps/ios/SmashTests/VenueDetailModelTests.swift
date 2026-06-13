import Testing
@testable import Smash

// MARK: - Stub repository

/// A `VenueRepository` that returns a canned `VenueDetail` or throws a canned error.
private struct StubVenueDetailRepository: VenueRepository {
    var venueDetail: VenueDetail? = nil
    var error: (any Error)? = nil

    func fetchVenues() async throws -> [VenueListItem] {
        return []
    }

    func fetchVenue(id: String) async throws -> VenueDetail {
        if let error { throw error }
        return venueDetail!
    }
}

// MARK: - Fixtures

private func makeVenueDetail(id: String = "venue-1") -> VenueDetail {
    VenueDetail(
        id: id,
        name: "Smash Courts",
        suburb: "Sydney",
        lat: -33.8688,
        lng: 151.2093,
        courtCount: 6,
        dedicatedBadminton: true,
        distanceKm: 2.4,
        priceFrom: 2800,
        hasLiveAvailability: false,
        slug: "smash-courts",
        address: "123 Court St, Sydney NSW 2000",
        phone: "02 9000 1234",
        email: "info@smashcourts.com.au",
        bookingUrl: "https://smashcourts.com.au/book",
        platform: .other,
        rateCards: [
            RateCard(
                id: "rc-1",
                label: "Peak hour",
                priceCents: 3500,
                daysApply: ["mon", "tue", "wed", "thu", "fri"],
                timeRangeStart: "17:00",
                timeRangeEnd: "21:00",
                notes: "Booking required"
            ),
            RateCard(
                id: "rc-2",
                label: "Off-peak",
                priceCents: 2800,
                daysApply: [],
                timeRangeStart: nil,
                timeRangeEnd: nil,
                notes: nil
            ),
        ],
        openingHours: [
            OpeningHours(dayOfWeek: 1, openTime: "06:00", closeTime: "22:00", isClosed: false),
            OpeningHours(dayOfWeek: 2, openTime: "06:00", closeTime: "22:00", isClosed: false),
            OpeningHours(dayOfWeek: 3, openTime: "06:00", closeTime: "22:00", isClosed: false),
            OpeningHours(dayOfWeek: 4, openTime: "06:00", closeTime: "22:00", isClosed: false),
            OpeningHours(dayOfWeek: 5, openTime: "06:00", closeTime: "22:00", isClosed: false),
            OpeningHours(dayOfWeek: 6, openTime: "08:00", closeTime: "20:00", isClosed: false),
            OpeningHours(dayOfWeek: 0, openTime: nil, closeTime: nil, isClosed: true),
        ]
    )
}

// MARK: - Tests

@MainActor
struct VenueDetailModelTests {

    @Test func loadSuccessProducesLoadedStateWithExpectedVenueId() async {
        let expectedVenue = makeVenueDetail(id: "venue-abc")
        let repo = StubVenueDetailRepository(venueDetail: expectedVenue)
        let model = VenueDetailModel()

        await model.load(id: "venue-abc", using: repo)

        guard case let .loaded(venue) = model.state else {
            Issue.record("Expected .loaded, got \(model.state)")
            return
        }
        #expect(venue.id == "venue-abc")
        #expect(venue.name == "Smash Courts")
        #expect(venue.rateCards.count == 2)
        #expect(venue.openingHours.count == 7)
    }

    @Test func loadFailureProducesFailedStateWithNonEmptyMessage() async {
        let repo = StubVenueDetailRepository(
            error: APIError.http(statusCode: 404, body: nil)
        )
        let model = VenueDetailModel()

        await model.load(id: "venue-missing", using: repo)

        guard case let .failed(message) = model.state else {
            Issue.record("Expected .failed, got \(model.state)")
            return
        }
        #expect(!message.isEmpty)
    }
}
