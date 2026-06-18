import Foundation

// MARK: - Load state

/// The three terminal states of the venue detail, mirroring the RN
/// `useQuery` flags (`isPending` / `isError` / loaded data).
enum VenueDetailLoadState {
    case loading
    case loaded(VenueDetail)
    /// The error *message* string (already humanised), not the raw error.
    case failed(String)
}

// MARK: - View model

/// Drives ``VenueDetailScreen``.
///
/// Fetches a single venue by id and exposes the result as a ``VenueDetailLoadState``.
/// Failures become ``VenueDetailLoadState/failed(_:)`` — never re-thrown.
@Observable
@MainActor
final class VenueDetailModel {

    private(set) var state: VenueDetailLoadState = .loading

    /// Fetches the venue with the given id via the injected repository and
    /// folds the result into ``state``. Never throws.
    func load(id: String, using repository: any VenueRepository) async {
        state = .loading
        do {
            let venue = try await repository.fetchVenue(id: id)
            state = .loaded(venue)
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

extension VenueDetailModel {
    /// Builds a model in a fixed ``VenueDetailLoadState`` — for SwiftUI previews
    /// and view-layer tests that need to render a specific state without driving
    /// an async load.
    ///
    /// `state` stays `private(set)` for production callers (the only writer is
    /// ``load(id:using:)``); this factory is the one sanctioned way to seed it
    /// directly, keeping the invariant intact while making previews trivial.
    static func preview(state: VenueDetailLoadState) -> VenueDetailModel {
        let model = VenueDetailModel()
        model.state = state
        return model
    }
}
