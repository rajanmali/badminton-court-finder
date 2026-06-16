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

    /// Which presentation is shown — list or map. Defaults to `.list`,
    /// matching the RN screen's initial `useState('list')`.
    var viewMode: ViewMode = .list

    /// Active filters. Defaults to `.default`; PR 8 makes these live.
    var filters: FilterState = .default

    /// How the venue list is ordered. Defaults to `.nearest`; seeded from the
    /// user's saved `defaultSort` in ``RootTabView`` and made live via the
    /// shared Filters sheet's Sort section.
    var sortOption: SortOption = .nearest

    /// The user's coordinates, when known. Populated by ``loadLocation(using:)``.
    var userCoords: UserCoords? = nil

    /// `true` when location permission was denied or restricted.
    /// Drives the distance-chip disabled state and the orange hint in FilterBar.
    var locationDenied: Bool = false

    /// Venues to render: filtered then sorted by ``sortOption`` when loaded,
    /// empty otherwise. ``applyFilters`` does the AND-logic filtering (and a
    /// default ordering); the trailing ``sortVenues`` is the authoritative sort
    /// that the user's chosen ``SortOption`` controls.
    var displayedVenues: [VenueListItem] {
        guard case let .loaded(venues) = state else { return [] }
        let filtered = applyFilters(venues, filters, userCoords)
        return sortVenues(filtered, by: sortOption)
    }

    /// Requests the user's location via the injected service and folds the
    /// outcome into ``userCoords`` and ``locationDenied``.
    ///
    /// Uses `LocationOutcome.locationState` — the same helper that the
    /// `LocationOutcomeMappingTests` exercise — so outcome → model mapping
    /// stays in one place.
    func loadLocation(using service: any LocationService) async {
        let outcome = await service.requestLocation()
        let state = outcome.locationState
        self.userCoords = state.coords
        self.locationDenied = state.permissionDenied
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

// MARK: - Preview / test seam

extension VenueListModel {
    /// Builds a model in a fixed ``LoadState`` with optional filters — for
    /// SwiftUI previews and view-layer tests that need to render a specific
    /// state without driving an async load.
    ///
    /// `state` stays `private(set)` for production callers (the only writers are
    /// ``load(using:)``); this factory is the one sanctioned way to seed it
    /// directly, keeping the invariant intact while making previews trivial.
    static func preview(
        state: LoadState,
        filters: FilterState = .default,
        sortOption: SortOption = .nearest,
        locationDenied: Bool = false
    ) -> VenueListModel {
        let model = VenueListModel()
        model.state = state
        model.filters = filters
        model.sortOption = sortOption
        model.locationDenied = locationDenied
        return model
    }
}
