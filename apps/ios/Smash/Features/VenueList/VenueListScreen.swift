import SwiftUI

/// The venue list screen. Ports `VenueListScreen.tsx`.
///
/// Loads venues and requests location concurrently on appear via the injected
/// ``AppEnvironment``. When data is loaded, renders a ``FilterBar`` above the
/// venue list (or the empty-state view) — matching the RN behaviour of showing
/// filters only after the initial load completes.
///
/// ## @Bindable pattern
///
/// `model` lives in `@State`. SwiftUI 5.1+ allows using `$state.property`
/// directly when the wrapped value is `@Observable`, but the most reliable
/// cross-version idiom is to extract a `Bindable` wrapper once in a helper
/// view that receives the model as `@Bindable`. Here we keep it simple:
/// the loaded body is extracted into `LoadedBody`, which holds the model
/// as `@Bindable var model` and creates `$model.filters` for `FilterBar`.
struct VenueListScreen: View {
    @State private var model = VenueListModel()
    @Environment(\.appEnvironment) private var env

    var body: some View {
        content
            .navigationTitle("Smash — Find a Court")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                // Run venue load and location request concurrently — neither
                // depends on the other and displayedVenues reacts to both.
                async let venueLoad: Void = model.load(using: env.venueRepository)
                async let locationLoad: Void = model.loadLocation(using: env.locationService)
                _ = await (venueLoad, locationLoad)
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
            LoadedBody(model: model)
        }
    }
}

// MARK: - LoadedBody

/// Renders the FilterBar + list (or empty state) once data is available.
///
/// Receiving the model as `@Bindable var model` is the documented Apple pattern
/// for deriving bindings from an `@Observable` instance that was created and
/// owned by a parent's `@State`. The parent holds the authoritative instance;
/// this child view simply holds a non-owning `Bindable` wrapper, giving us
/// `$model.filters` without changing ownership.
private struct LoadedBody: View {
    @Bindable var model: VenueListModel

    var body: some View {
        VStack(spacing: 0) {
            FilterBar(
                filters: $model.filters,
                locationDenied: model.locationDenied
            )
            if model.displayedVenues.isEmpty {
                ContentUnavailableView(
                    "No venues match your filters.",
                    systemImage: "magnifyingglass"
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
