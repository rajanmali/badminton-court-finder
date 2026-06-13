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
                    case let .venueDetail(_, name):
                        // TODO(PR9): replace with VenueDetailScreen
                        VenueDetailPlaceholder(name: name)
                    }
                }
        }
    }
}

// MARK: - Temporary detail placeholder

/// Temporary stand-in for the real venue detail screen (PR 9).
///
/// Keeps tap-navigation working and establishes the nav-title pattern
/// (title = venue name) that ``VenueDetailScreen`` will inherit.
private struct VenueDetailPlaceholder: View {
    let name: String

    var body: some View {
        ContentUnavailableView(
            "Venue detail coming soon",
            systemImage: "hammer",
            description: Text(name)
        )
        .navigationTitle(name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
