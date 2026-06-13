import Foundation

// MARK: - Protocol

/// Abstracts venue data fetching so view models and tests can swap
/// implementations without depending on `APIClient` directly.
protocol VenueRepository: Sendable {

    /// Returns the full list of venues (no filter params — filtering happens
    /// on the server by default; client-side filtering is applied in the VM).
    func fetchVenues() async throws -> [VenueListItem]

    /// Returns the detail record for a single venue.
    ///
    /// - Parameter id: The venue UUID string.
    func fetchVenue(id: String) async throws -> VenueDetail
}

// MARK: - Live Implementation

/// Production `VenueRepository` backed by ``APIClient``.
struct LiveVenueRepository: VenueRepository {

    private let apiClient: APIClient

    /// Creates a `LiveVenueRepository`.
    ///
    /// - Parameter apiClient: The underlying HTTP client. Defaults to a
    ///   client configured from ``AppConfig``.
    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    func fetchVenues() async throws -> [VenueListItem] {
        let response: VenueListResponse = try await apiClient.get("/venues")
        return response.venues
    }

    func fetchVenue(id: String) async throws -> VenueDetail {
        let response: VenueDetailResponse = try await apiClient.get("/venues/\(id)")
        return response.venue
    }
}
