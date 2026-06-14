import SwiftUI

/// The List tab. Ports `VenueListScreen.tsx`'s list branch.
///
/// Renders only the list experience — the loading / error / empty states plus
/// the ``FilterBar`` above a card list. The List/Map switch moved to the
/// floating ``TabBar`` (see ``RootTabView``), and the shared ``VenueListModel``
/// is now owned by ``RootTabView`` and passed in here; this screen no longer
/// creates the model or runs the initial load.
///
/// ## @Bindable pattern
///
/// The model is created and owned by ``RootTabView``'s `@State`. This screen
/// holds a non-owning `@Bindable` reference so it can derive `$model.filters`
/// for ``FilterBar`` without changing ownership — the documented Apple pattern
/// for passing an `@Observable` down the hierarchy.
struct VenueListScreen: View {
    @Bindable var model: VenueListModel

    /// Called when a venue is selected (a card tap routed through the host, or a
    /// programmatic push). List rows also push via `NavigationLink(value:)`.
    var onSelectVenue: (String, String) -> Void = { _, _ in }

    var body: some View {
        content
            .navigationTitle("Smash — Find a Court")
            .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .loading:
            ProgressView()
                .controlSize(.large)
                .tint(.green)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case let .failed(message):
            ContentUnavailableView {
                Label("Could not load venues", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            }

        case .loaded:
            loadedBody
        }
    }

    // MARK: - Loaded body

    /// FilterBar + card list (or empty state). Bottom content padding clears the
    /// floating tab bar so the last card isn't hidden behind it.
    @ViewBuilder
    private var loadedBody: some View {
        VStack(spacing: 0) {
            FilterBar(
                filters: $model.filters,
                locationDenied: model.locationDenied
            )
            listContent
        }
    }

    @ViewBuilder
    private var listContent: some View {
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
            // Clear the floating tab bar (floats ~26pt up + its own height) so
            // the last row isn't obscured behind it.
            .safeAreaPadding(.bottom, 96)
        }
    }
}
