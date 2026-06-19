import SwiftUI

// MARK: - AppEnvironment

/// A lightweight dependency container injected through the SwiftUI environment.
///
/// This is the **dependency-injection pattern** every screen reuses: a view
/// reads `@Environment(\.appEnvironment)` to get its collaborators, and tests /
/// previews override the environment with stubs. The repository and location
/// service are protocols, so swapping in mocks needs no view changes.
struct AppEnvironment: Sendable {
    var venueRepository: any VenueRepository
    var locationService: any LocationService

    /// The production environment, wired to the live implementations.
    static let live = AppEnvironment(
        venueRepository: LiveVenueRepository(),
        locationService: LiveLocationService()
    )
}

// MARK: - Environment plumbing

extension EnvironmentValues {
    /// The app-wide dependency container. Defaults to ``AppEnvironment/live``.
    @Entry var appEnvironment: AppEnvironment = .live

    /// The window's safe-area insets, injected from ``RootView`` via a
    /// `GeometryReader` before any `.ignoresSafeArea` modifier is applied.
    ///
    /// Use this instead of `proxy.safeAreaInsets` when reading inside a view
    /// whose parent (or an ancestor) has consumed the safe area with
    /// `.ignoresSafeArea(edges:)` — in that context the environment-level
    /// safe area would otherwise be reported as 0.
    @Entry var windowSafeAreaInsets: EdgeInsets = EdgeInsets()
}
