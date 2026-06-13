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
struct RootView: View {
    var body: some View {
        NavigationStack {
            VenueListScreen()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case let .venueDetail(id, name):
                        VenueDetailScreen(venueId: id, venueName: name)
                    }
                }
        }
    }
}
