import SwiftUI

@main
struct SmashApp: App {
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
/// The stack carries an explicit `path` binding so non-`NavigationLink`
/// callers (the map's pin-tap handler) can push programmatically. Value-based
/// `NavigationLink(value:)` in the list rows appends to this same path, so the
/// list continues to work unchanged.
struct RootView: View {
    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            VenueListScreen(onSelectVenue: { id, name in
                path.append(.venueDetail(id: id, name: name))
            })
            .navigationDestination(for: Route.self) { route in
                switch route {
                case let .venueDetail(id, name):
                    VenueDetailScreen(venueId: id, venueName: name)
                }
            }
        }
    }
}
