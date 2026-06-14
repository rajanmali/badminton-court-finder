import SwiftUI
#if !DEBUG
@preconcurrency import Sentry
#endif

@main
struct SmashApp: App {

    init() {
        #if !DEBUG
        let dsn = AppConfig.sentryDSN
        if !dsn.isEmpty {
            SentrySDK.start { options in
                options.dsn = dsn
                options.environment = "production"
            }
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

// MARK: - Navigation routes

/// Typed navigation destinations for the app's `NavigationStack`.
///
/// Adding a screen = adding a case here + a `.navigationDestination` arm in
/// ``RootView``. Pushing is then `NavigationLink(value: Route.…)`.
enum Route: Hashable {
    case venueDetail(id: String, name: String)
}

// MARK: - Root view

/// Hosts the app-wide `NavigationStack` and maps ``Route`` values to screens.
///
/// The stack's root is ``RootTabView``, which owns the shared venue model and
/// the floating List/Map tab bar. The stack carries an explicit `path` binding
/// so both `NavigationLink(value:)` (list rows) and programmatic callers (the
/// map's pin-tap handler, routed through `RootTabView`) push onto the same path.
/// Pushing the Venue Detail covers the whole tab view, so the floating tab bar
/// is naturally hidden while Detail is open.
struct RootView: View {
    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            RootTabView(path: $path)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case let .venueDetail(id, name):
                        VenueDetailScreen(venueId: id, venueName: name)
                    }
                }
        }
    }
}
