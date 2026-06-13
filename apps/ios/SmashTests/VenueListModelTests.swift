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
}
