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
    @Environment(\.preferences) private var preferences

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
            // Apply the user's saved default filters before loading so the
            // captured onboarding defaults take effect on first paint. Sort is
            // intentionally NOT wired here — applying `defaultSort` is a later PR;
            // onboarding only persists it.
            model.filters = preferences.defaultFilters

            // Venues load immediately; they don't depend on location.
            await model.load(using: env.venueRepository)
        }
        // Request location only once onboarding is complete. Keying on
        // `hasSeenOnboarding` means: on first run this `.task` is a no-op while
        // the onboarding cover owns the location *priming*, then re-fires the
        // moment onboarding finishes (flipping the flag) to pick up the user's
        // grant. On every subsequent launch the flag is already `true`, so it
        // runs straight away. This keeps the system prompt from firing *behind*
        // the priming step.
        .task(id: preferences.hasSeenOnboarding) {
            guard preferences.hasSeenOnboarding else { return }
            await model.loadLocation(using: env.locationService)
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
