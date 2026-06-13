import Foundation

// MARK: - Load state

/// The three terminal states of the venue list, mirroring the RN
/// `useQuery` flags (`isPending` / `isError` / loaded data).
enum LoadState {
    case loading
    case loaded([VenueListItem])
    /// The error *message* string (already humanised), not the raw error.
    case failed(String)
}

// MARK: - View model

/// Drives ``VenueListScreen``.
///
/// `filters` and `userCoords` exist now (at their defaults) so PR 8 can wire
/// up the filter bar and location without restructuring this model. For this
/// PR they stay at defaults, so ``displayedVenues`` simply returns the list in
/// the order the API + default sort produces.
@Observable
@MainActor
final class VenueListModel {

    private(set) var state: LoadState = .loading

    /// Active filters. Defaults to `.default`; PR 8 makes these live.
    var filters: FilterState = .default

    /// The user's coordinates, when known. PR 8 populates this from the
    /// location service.
    var userCoords: UserCoords? = nil

    /// Venues to render: filtered + sorted when loaded, empty otherwise.
    var displayedVenues: [VenueListItem] {
        guard case let .loaded(venues) = state else { return [] }
        return applyFilters(venues, filters, userCoords)
    }

    /// Fetches venues via the injected repository and folds the result into
    /// ``state``. Never throws — failures become ``LoadState/failed(_:)``.
    func load(using repository: any VenueRepository) async {
        state = .loading
        do {
            let venues = try await repository.fetchVenues()
            state = .loaded(venues)
        } catch {
            state = .failed(errorMessage(from: error))
        }
    }

    /// Extracts the most user-meaningful message from an error, preferring an
    /// `APIError`'s `errorDescription`.
    private func errorMessage(from error: any Error) -> String {
        if let apiError = error as? APIError, let description = apiError.errorDescription {
            return description
        }
        return (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
    }
}
