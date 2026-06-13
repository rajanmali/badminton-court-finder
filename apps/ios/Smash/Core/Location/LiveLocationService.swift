import CoreLocation
import Foundation

/// The production ``LocationService``, bridging `CLLocationManager`'s
/// delegate-based authorization and one-shot location APIs into a single
/// `async` request that mirrors the RN `useLocation` flow.
///
/// ## Concurrency
/// `CLLocationManager` requires a run loop and delivers its callbacks on the
/// thread it was created on, so this type is `@MainActor` (the project's
/// default actor isolation under Swift 6.2 — ADR-0010). A `@MainActor final
/// class` is `Sendable`, which satisfies the `LocationService: Sendable`
/// requirement, and all `CLLocationManager` access stays on the main actor.
///
/// ## Continuation safety
/// Both the auth-change and location delegate callbacks can fire more than
/// once. Each suspension is backed by an optional continuation property that
/// is `nil`-ed out on first resume, guaranteeing every continuation resumes
/// **exactly once**. If a second `requestLocation()` somehow starts while one
/// is in flight, the prior continuation is resolved as `.unavailable` rather
/// than leaked or double-resumed.
@MainActor
final class LiveLocationService: NSObject, LocationService, CLLocationManagerDelegate {

    // MARK: Properties

    private let manager: CLLocationManager

    /// Resumed by ``locationManagerDidChangeAuthorization(_:)`` once a
    /// definitive authorization status arrives after a request.
    private var authContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?

    /// Resumed by ``locationManager(_:didUpdateLocations:)`` or
    /// ``locationManager(_:didFailWithError:)`` once a fix or failure arrives.
    private var locationContinuation: CheckedContinuation<LocationOutcome, Never>?

    // MARK: Init

    override init() {
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    // MARK: LocationService

    func requestLocation() async -> LocationOutcome {
        let status = await resolvedAuthorizationStatus()

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            return await fetchFix()
        default:
            // .denied, .restricted, or still .notDetermined after a request.
            return .denied
        }
    }

    // MARK: Authorization

    /// Returns a definitive authorization status, requesting when-in-use
    /// permission first if the status is still `.notDetermined`.
    private func resolvedAuthorizationStatus() async -> CLAuthorizationStatus {
        let status = manager.authorizationStatus

        switch status {
        case .denied, .restricted:
            return status
        case .authorizedWhenInUse, .authorizedAlways:
            return status
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                // Guard against a leaked prior continuation.
                resumeAuth(with: status)
                authContinuation = continuation
                manager.requestWhenInUseAuthorization()
            }
        @unknown default:
            return status
        }
    }

    // MARK: One-shot fix

    /// Requests a single location fix, returning `.located` on success or
    /// `.unavailable` on failure.
    private func fetchFix() async -> LocationOutcome {
        await withCheckedContinuation { continuation in
            // Guard against a leaked prior continuation.
            resumeLocation(with: .unavailable)
            locationContinuation = continuation
            manager.requestLocation()
        }
    }

    // MARK: Single-resume helpers

    private func resumeAuth(with status: CLAuthorizationStatus) {
        guard let continuation = authContinuation else { return }
        authContinuation = nil
        continuation.resume(returning: status)
    }

    private func resumeLocation(with outcome: LocationOutcome) {
        guard let continuation = locationContinuation else { return }
        locationContinuation = nil
        continuation.resume(returning: outcome)
    }

    // MARK: CLLocationManagerDelegate

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        MainActor.assumeIsolated {
            // Ignore the transient .notDetermined that can precede the prompt;
            // only resume once a definitive status arrives.
            guard status != .notDetermined else { return }
            resumeAuth(with: status)
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.first else { return }
        let coords = UserCoords(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        MainActor.assumeIsolated {
            resumeLocation(with: .located(coords))
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        MainActor.assumeIsolated {
            resumeLocation(with: .unavailable)
        }
    }
}
