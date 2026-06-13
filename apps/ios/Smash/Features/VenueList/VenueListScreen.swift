import SwiftUI

/// The venue list screen. Ports `VenueListScreen.tsx`.
///
/// Loads venues once on appear via the injected ``VenueRepository``, then
/// renders loading / error / empty / list states. Tapping a row pushes
/// ``Route/venueDetail(id:name:)``.
struct VenueListScreen: View {
    @State private var model = VenueListModel()
    @Environment(\.appEnvironment) private var env

    var body: some View {
        content
            .navigationTitle("Smash — Find a Court")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await model.load(using: env.venueRepository)
            }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .loading:
            ProgressView()
                .controlSize(.large)
                .tint(.smashPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case let .failed(message):
            ContentUnavailableView {
                Label("Could not load venues", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            }

        case .loaded:
            if model.displayedVenues.isEmpty {
                ContentUnavailableView(
                    "No venues match your filters.",
                    systemImage: "magnifyingglass"
                )
            } else {
                List(model.displayedVenues) { venue in
                    NavigationLink(value: Route.venueDetail(id: venue.id, name: venue.name)) {
                        VenueRow(venue: venue)
                    }
                }
            }
        }
    }
}
