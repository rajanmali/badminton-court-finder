import Testing
@testable import Smash

// MARK: - Stub repository (minimal, for filter integration tests)

private struct StubVenueRepository2: VenueRepository {
    var venues: [VenueListItem]

    func fetchVenues() async throws -> [VenueListItem] { venues }

    func fetchVenue(id: String) async throws -> VenueDetail {
        throw APIError.invalidURL
    }
}

// MARK: - Fixtures

private let SYDNEY_CBD = UserCoords(latitude: -33.8688, longitude: 151.2093)

private func makeVenue(
    id: String,
    name: String,
    dedicated: Bool = false,
    priceFrom: Int? = 3000
) -> VenueListItem {
    VenueListItem(
        id: id, name: name, suburb: "Test",
        lat: -33.8688, lng: 151.2093,
        courtCount: 4, dedicatedBadminton: dedicated,
        distanceKm: nil, priceFrom: priceFrom,
        hasLiveAvailability: false
    )
}

// MARK: - Location outcome → model state mapping

@MainActor
struct VenueListLocationTests {

    // MARK: loadLocation outcomes

    @Test func loadLocationLocated_setsUserCoordsAndClearsDenied() async {
        let model = VenueListModel()
        let service = MockLocationService(outcome: .located(SYDNEY_CBD))

        await model.loadLocation(using: service)

        #expect(model.userCoords == SYDNEY_CBD)
        #expect(model.locationDenied == false)
    }

    @Test func loadLocationDenied_clearsUserCoordsAndSetsDenied() async {
        let model = VenueListModel()
        let service = MockLocationService(outcome: .denied)

        await model.loadLocation(using: service)

        #expect(model.userCoords == nil)
        #expect(model.locationDenied == true)
    }

    @Test func loadLocationUnavailable_clearsUserCoordsAndDoesNotSetDenied() async {
        let model = VenueListModel()
        let service = MockLocationService(outcome: .unavailable)

        await model.loadLocation(using: service)

        #expect(model.userCoords == nil)
        #expect(model.locationDenied == false)
    }

    // MARK: Filter integration — dedicated filter

    @Test func dedicatedFilterReducesDisplayedVenues() async {
        let venues = [
            makeVenue(id: "1", name: "Alpha Court", dedicated: true),
            makeVenue(id: "2", name: "Beta Sports", dedicated: false),
        ]
        let repo = StubVenueRepository2(venues: venues)
        let model = VenueListModel()

        await model.load(using: repo)
        // Baseline: both venues visible with default filters
        #expect(model.displayedVenues.count == 2)

        // Apply dedicated filter
        model.filters.dedicatedOnly = true
        #expect(model.displayedVenues.count == 1)
        #expect(model.displayedVenues.first?.id == "1")
    }

    @Test func clearingDedicatedFilterRestoresAllVenues() async {
        let venues = [
            makeVenue(id: "1", name: "Alpha Court", dedicated: true),
            makeVenue(id: "2", name: "Beta Sports", dedicated: false),
        ]
        let repo = StubVenueRepository2(venues: venues)
        let model = VenueListModel()

        await model.load(using: repo)
        model.filters.dedicatedOnly = true
        #expect(model.displayedVenues.count == 1)

        model.filters.dedicatedOnly = false
        #expect(model.displayedVenues.count == 2)
    }

    // MARK: Sort fallback (UX fix #4 / spec c)

    /// When location is denied and the sort was .nearest, loadLocation must
    /// replace it with .priceLowToHigh (the non-location default).
    @Test func loadLocationDenied_withNearestSort_fallsBackToPriceLowToHigh() async {
        let model = VenueListModel()
        model.sortOption = .nearest
        let service = MockLocationService(outcome: .denied)

        await model.loadLocation(using: service)

        #expect(model.locationDenied == true)
        #expect(model.userCoords == nil)
        #expect(model.sortOption == .priceLowToHigh,
                "Nearest sort must fall back to priceLowToHigh when location is denied")
    }

    /// When location is unavailable (not a permission problem) and the sort was
    /// .nearest, the fallback still applies — there are no coordinates either way.
    @Test func loadLocationUnavailable_withNearestSort_fallsBackToPriceLowToHigh() async {
        let model = VenueListModel()
        model.sortOption = .nearest
        let service = MockLocationService(outcome: .unavailable)

        await model.loadLocation(using: service)

        #expect(model.locationDenied == false)
        #expect(model.userCoords == nil)
        #expect(model.sortOption == .priceLowToHigh,
                "Nearest sort must fall back to priceLowToHigh when location is unavailable")
    }

    /// When location IS granted, the sort must NOT be changed — the user's
    /// .nearest preference should remain intact.
    @Test func loadLocationLocated_withNearestSort_doesNotChangeSortOption() async {
        let model = VenueListModel()
        model.sortOption = .nearest
        let service = MockLocationService(outcome: .located(SYDNEY_CBD))

        await model.loadLocation(using: service)

        #expect(model.userCoords == SYDNEY_CBD)
        #expect(model.sortOption == .nearest,
                "Nearest sort must not be replaced when location is available")
    }

    /// A user who explicitly chose a non-nearest sort before denial must not have
    /// their preference silently replaced.
    @Test func loadLocationDenied_withExplicitNonNearestSort_doesNotChangeSortOption() async {
        let model = VenueListModel()
        model.sortOption = .alphabetical
        let service = MockLocationService(outcome: .denied)

        await model.loadLocation(using: service)

        #expect(model.sortOption == .alphabetical,
                "Explicit non-nearest sort must not be overridden by location denial")
    }
}
