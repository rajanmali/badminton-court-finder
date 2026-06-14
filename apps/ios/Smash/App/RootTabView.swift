import SwiftUI

// MARK: - RootTabView

/// The navigation root that owns the shared venue model and switches between the
/// List and Map tabs via the floating ``TabBar``.
///
/// ## Single source of truth
/// `model` lives here in `@State` and is passed *by reference* into both
/// ``VenueListScreen`` and ``VenueMapScreen``. Both tabs therefore read the same
/// venues, filters, and location — switching tabs never re-fetches and a filter
/// applied on one tab is already applied on the other. The initial load (venues
/// + location, concurrently) runs once here in `.task`, lifted out of the old
/// `VenueListScreen`.
///
/// ## Tab bar over content (no `TabView`)
/// The body is a `ZStack(alignment: .bottom)`: the active screen fills the space
/// and the `TabBar` floats ~26pt above the bottom safe area. We deliberately do
/// **not** use a system `TabView` — a `NavigationStack` push (Venue Detail) then
/// presents the destination over this whole view, which naturally hides the
/// floating bar while Detail is open, matching the design.
struct RootTabView: View {
    /// Authoritative, shared venue model. Both tab screens hold a non-owning
    /// `@Bindable` reference to this instance.
    @State private var model = VenueListModel()

    @Environment(\.appEnvironment) private var env

    /// The navigation path owned by ``RootView``; tapping a card/pin appends a
    /// `.venueDetail` route to it.
    @Binding var path: [Route]

    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // `$model.viewMode` uses SwiftUI's `@State`-on-`@Observable` binding
            // projection directly — no local `@Bindable` shadow, which would put
            // the model in a non-isolated local and break the `.task` send below.
            TabBar(selection: $model.viewMode)
                // Float ~26pt above the bottom safe area.
                .padding(.bottom, 26)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .task {
            // Run venue load and location request concurrently — neither depends
            // on the other and displayedVenues reacts to both. Moved here from
            // VenueListScreen so the load happens once for both tabs.
            async let venueLoad: Void = model.load(using: env.venueRepository)
            async let locationLoad: Void = model.loadLocation(using: env.locationService)
            _ = await (venueLoad, locationLoad)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch model.viewMode {
        case .list:
            VenueListScreen(model: model, onSelectVenue: select)
        case .map:
            VenueMapScreen(model: model, onSelectVenue: select)
        }
    }

    /// Push the venue detail onto the shared navigation path.
    private func select(_ id: String, _ name: String) {
        path.append(.venueDetail(id: id, name: name))
    }
}
