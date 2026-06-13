import Foundation

// MARK: - Outcome

/// The terminal outcome of a one-shot location request.
///
/// Maps the three terminal states of the React Native `useLocation` hook
/// (`apps/mobile/src/hooks/useLocation.ts`):
///
/// | RN state                                   | `LocationOutcome` |
/// |--------------------------------------------|-------------------|
/// | granted + got a fix                        | ``located(_:)``   |
/// | permission denied/restricted               | ``denied``        |
/// | granted but the position fetch threw       | ``unavailable``   |
///
/// `.unavailable` is deliberately distinct from `.denied`: the user *did*
/// grant permission, so the UI should not show a "permission denied" message —
/// it simply has no coordinates (matching RN's silent `catch`).
enum LocationOutcome: Sendable, Equatable {
    /// Permission granted and a position fix was obtained.
    case located(UserCoords)
    /// Permission denied or restricted — no coordinates.
    case denied
    /// Permission granted but the position fix failed — no coordinates,
    /// and *not* a permission problem.
    case unavailable
}

extension LocationOutcome {
    /// Folds the outcome into the `(coords, permissionDenied)` pair that mirrors
    /// the RN `LocationState` shape, for use by the view model.
    ///
    /// - `.located(c)` → `(c, false)`
    /// - `.denied`     → `(nil, true)`
    /// - `.unavailable`→ `(nil, false)`
    var locationState: (coords: UserCoords?, permissionDenied: Bool) {
        switch self {
        case .located(let coords): (coords, false)
        case .denied: (nil, true)
        case .unavailable: (nil, false)
        }
    }
}

// MARK: - Protocol

/// Performs a single one-shot location request and returns the terminal outcome.
///
/// The request **never throws** — failures fold into ``LocationOutcome/denied``
/// or ``LocationOutcome/unavailable``, matching the RN hook's silent handling.
/// Loading is a UI concern owned by the view model; the service just performs
/// the request and returns once.
protocol LocationService: Sendable {
    /// Requests when-in-use permission (if needed) and a single position fix.
    func requestLocation() async -> LocationOutcome
}

// MARK: - Mock

/// A `LocationService` that returns a fixed outcome. For previews and tests.
struct MockLocationService: LocationService {
    let outcome: LocationOutcome

    func requestLocation() async -> LocationOutcome { outcome }
}
