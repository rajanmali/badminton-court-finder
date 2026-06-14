import SwiftUI

/// The Map tab. Extracts the old in-list map branch into a sibling screen.
///
/// Renders the shared ``FilterBar`` above ``VenueMapView``, both driven by the
/// shared ``VenueListModel`` owned by ``RootTabView``. Keeping the FilterBar
/// visible here means filtering works identically on both tabs; the map's own
/// "Filters" pill treatment (a collapsible panel) is a later redesign PR.
///
/// Like ``VenueListScreen``, the model is passed in (not created) so List and
/// Map stay a single source of truth for venues / filters / location.
struct VenueMapScreen: View {
    @Bindable var model: VenueListModel

    /// Called when a pin is tapped — forwards id + name so the host pushes the
    /// venue detail onto the navigation path.
    var onSelectVenue: (String, String) -> Void = { _, _ in }

    var body: some View {
        VStack(spacing: 0) {
            FilterBar(
                filters: $model.filters,
                locationDenied: model.locationDenied
            )
            VenueMapView(
                venues: model.displayedVenues,
                userCoords: model.userCoords,
                onVenueTap: onSelectVenue
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Smash — Find a Court")
        .navigationBarTitleDisplayMode(.inline)
    }
}
