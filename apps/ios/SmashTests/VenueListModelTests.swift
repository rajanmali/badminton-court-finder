import Foundation
import Testing
@testable import Smash

// MARK: - Stub repository

/// A `VenueRepository` that returns canned venues or throws a canned error.
private struct StubVenueRepository: VenueRepository {
    var venues: [VenueListItem] = []
    var error: (any Error)? = nil

    func fetchVenues() async throws -> [VenueListItem] {
        if let error { throw error }
        return venues
    }

    func fetchVenue(id: String) async throws -> VenueDetail {
        throw APIError.invalidURL  // unused in these tests
    }
}

// MARK: - Fixtures

private func makeVenue(id: String, name: String) -> VenueListItem {
    VenueListItem(
        id: id, name: name, suburb: "Test",
        lat: -33.8688, lng: 151.2093,
        courtCount: 4, dedicatedBadminton: false,
        distanceKm: nil, priceFrom: 3000,
        hasLiveAvailability: false
    )
}

// MARK: - Tests

@MainActor
struct VenueListModelTests {

    @Test func loadSuccessProducesLoadedStateWithVenues() async {
        let repo = StubVenueRepository(venues: [
            makeVenue(id: "a", name: "Alpha"),
            makeVenue(id: "b", name: "Bravo"),
        ])
        let model = VenueListModel()

        await model.load(using: repo)

        guard case let .loaded(venues) = model.state else {
            Issue.record("Expected .loaded, got \(model.state)")
            return
        }
        #expect(venues.count == 2)
        #expect(model.displayedVenues.count == 2)
    }

    @Test func loadFailureProducesFailedStateWithMessage() async {
        let repo = StubVenueRepository(
            error: APIError.http(statusCode: 404, body: nil)
        )
        let model = VenueListModel()

        await model.load(using: repo)

        guard case let .failed(message) = model.state else {
            Issue.record("Expected .failed, got \(model.state)")
            return
        }
        #expect(!message.isEmpty)
        #expect(model.displayedVenues.isEmpty)
    }

    // MARK: refresh(using:)

    /// `refresh` updates the model to `.loaded` without an intermediate `.loading`
    /// transition — the existing venue list stays intact while the request is in flight.
    @Test func refreshSuccessUpdatesLoadedVenues() async {
        // Start with a loaded state (simulating an already-loaded screen).
        let initial = StubVenueRepository(venues: [makeVenue(id: "a", name: "Alpha")])
        let model = VenueListModel()
        await model.load(using: initial)

        guard case .loaded = model.state else {
            Issue.record("Expected .loaded after initial load")
            return
        }

        // Refresh with a fresh set of venues — should update without touching .loading.
        let refreshed = StubVenueRepository(venues: [
            makeVenue(id: "b", name: "Bravo"),
            makeVenue(id: "c", name: "Charlie"),
        ])
        await model.refresh(using: refreshed)

        guard case let .loaded(venues) = model.state else {
            Issue.record("Expected .loaded after refresh, got \(model.state)")
            return
        }
        #expect(venues.count == 2)
        #expect(model.displayedVenues.map { $0.id }.sorted() == ["b", "c"])
    }

    /// On a network failure, `refresh` surfaces `.failed` — the error banner
    /// replaces the (possibly stale) list, so the user can retry.
    @Test func refreshFailureSurfacesFailedState() async {
        // Start loaded.
        let initial = StubVenueRepository(venues: [makeVenue(id: "a", name: "Alpha")])
        let model = VenueListModel()
        await model.load(using: initial)

        // Refresh with a repo that throws.
        let broken = StubVenueRepository(error: APIError.http(statusCode: 503, body: nil))
        await model.refresh(using: broken)

        guard case let .failed(message) = model.state else {
            Issue.record("Expected .failed after refresh error, got \(model.state)")
            return
        }
        #expect(!message.isEmpty)
    }

    // MARK: allVenues (Saved tab source)

    /// `allVenues` returns the full loaded set sorted A–Z and is *not* narrowed
    /// by the active filters — the Saved tab relies on this so favourites show
    /// regardless of List/Map filtering.
    @Test func allVenuesReturnsFullSetSortedAndIgnoresFilters() async {
        let repo = StubVenueRepository(venues: [
            makeVenue(id: "b", name: "Bravo"),
            makeVenue(id: "a", name: "Alpha"),
        ])
        let model = VenueListModel()
        await model.load(using: repo)

        // A filter that would exclude one venue in `displayedVenues`…
        model.filters = FilterState(radiusKm: nil, maxPriceCents: 1, dedicatedOnly: true)
        #expect(model.displayedVenues.isEmpty)

        // …does not affect `allVenues`, which stays the full set, sorted A–Z.
        #expect(model.allVenues.map { $0.id } == ["a", "b"])
    }

    @Test func allVenuesIsEmptyBeforeLoad() {
        let model = VenueListModel()
        #expect(model.allVenues.isEmpty)
    }

    /// Filtering `allVenues` by `AppPreferences` favourites yields exactly the
    /// favourited subset — the computation the Saved screen performs.
    @Test func savedSubsetMatchesFavourites() async {
        let suiteName = "test-saved-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let repo = StubVenueRepository(venues: [
            makeVenue(id: "a", name: "Alpha"),
            makeVenue(id: "b", name: "Bravo"),
            makeVenue(id: "c", name: "Charlie"),
        ])
        let model = VenueListModel()
        await model.load(using: repo)

        let prefs = AppPreferences(defaults: defaults)
        prefs.toggleFavourite("a")
        prefs.toggleFavourite("c")

        let saved = model.allVenues.filter { prefs.isFavourite($0.id) }
        #expect(saved.map { $0.id } == ["a", "c"])
    }
}
