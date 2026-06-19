import SwiftUI

/// The List tab — the full redesigned List experience.
///
/// Assembles the screen top → bottom over a ``SmashBackdrop``: a custom glass
/// ``ListHeader`` (wordmark + status dot + a ``FiltersButton`` + locate pill) in
/// place of the system nav bar, then state content that switches on
/// `model.state` — the loading skeleton (``ListLoadingState``), the loaded
/// ``ListMetaRow`` + glass ``VenueRow`` cards (or ``ListEmptyState`` when
/// filtered to zero), and the ``ListErrorState`` on failure.
///
/// Filters and Sort live in the shared ``FiltersSheet`` (the same sheet the Map
/// tab presents), opened from the header's ``FiltersButton`` — so the list
/// scrolls cleanly under the header with no always-open inline panel.
///
/// Mirrors `ListScreen` in `design_handoff_smash/app/screens.jsx`.
///
/// ## @Bindable pattern
///
/// The model is created and owned by ``RootTabView``'s `@State`. This screen
/// holds a non-owning `@Bindable` reference so it can derive `$model.filters`
/// and `$model.sortOption` for the ``FiltersSheet`` without changing ownership —
/// the documented Apple pattern for passing an `@Observable` down the hierarchy.
struct VenueListScreen: View {
    @Bindable var model: VenueListModel

    /// Collaborators (location service, venue repository) for the locate pill
    /// and the error-state retry.
    @Environment(\.appEnvironment) private var env

    /// Called when a venue is selected (a card tap routed through the host, or a
    /// programmatic push). List rows also push via `NavigationLink(value:)`.
    var onSelectVenue: (String, String) -> Void = { _, _ in }

    /// Whether the shared Filters sheet is presented.
    @State private var showFilters = false

    var body: some View {
        VStack(spacing: 14) {
            ListHeader(
                onLocate: locate,
                onOpenFilters: { showFilters = true },
                filtersActive: filtersAreActive(model.filters)
            )
            content
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SmashBackdrop())
        // We draw a custom header, so hide the system navigation bar.
        .toolbar(.hidden, for: .navigationBar)
        // The shared Filters + Sort sheet — same component the Map tab presents.
        // Bound straight to the model so edits update the list live behind it.
        .sheet(isPresented: $showFilters) {
            FiltersSheet(
                filters: $model.filters,
                sort: $model.sortOption,
                locationDenied: model.locationDenied
            )
        }
    }

    // MARK: - State content

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .loading:
            ListLoadingState()

        case .failed:
            ListErrorState(onRetry: retry)

        case .loaded:
            loadedBody
        }
    }

    // MARK: - Loaded body

    /// Meta row + card list — or the empty state when filters match nothing.
    /// Filters now live in the shared sheet (opened from the header), so the
    /// list scrolls cleanly under the header with no inline panel. Bottom
    /// content padding clears the floating tab bar so the last card isn't hidden
    /// behind it.
    @ViewBuilder
    private var loadedBody: some View {
        if model.displayedVenues.isEmpty {
            ListEmptyState(onReset: resetFilters)
        } else {
            VStack(spacing: 10) {
                ListMetaRow(
                    count: model.displayedVenues.count,
                    sortLabel: model.sortOption.label
                )
                cardList
            }
        }
    }

    private var cardList: some View {
        // ScrollView + LazyVStack so the glass cards float on the backdrop
        // without a List's white row chrome or cell separators.
        // NavigationLink(value:) with .buttonStyle(.venueCard) routes press
        // state into VenueCardButtonStyle, enabling the 0.96× spring scale.
        ScrollView {
            LazyVStack(spacing: Spacing.cardGap) {
                ForEach(model.displayedVenues) { venue in
                    NavigationLink(
                        value: Route.venueDetail(id: venue.id, name: venue.name)
                    ) {
                        VenueRow(venue: venue)
                    }
                    .buttonStyle(.venueCard)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            // Clear the floating tab bar — use the shared constant so this
            // stays in sync with the tab bar's actual float height.
            .padding(.bottom, TabBar.reservedBottomSpace)
        }
        .scrollContentBackground(.hidden)
        // Pull-to-refresh: uses refresh() instead of load() so the current
        // venue list stays visible under the system spinner (no skeleton flash).
        // The underlying live VenueRepository performs the real fetch.
        .refreshable {
            await model.refresh(using: env.venueRepository)
        }
    }

    // MARK: - Actions

    private func locate() {
        Task { await model.loadLocation(using: env.locationService) }
    }

    private func retry() {
        Task { await model.load(using: env.venueRepository) }
    }

    private func resetFilters() {
        model.filters = .default
    }
}

// MARK: - Previews

private func previewVenues() -> [VenueListItem] {
    [
        VenueListItem(
            id: "1", name: "Sydney Olympic Park Badminton Centre",
            suburb: "Olympic Park", lat: -33.85, lng: 151.07,
            courtCount: 12, dedicatedBadminton: true,
            distanceKm: 3.4, priceFrom: 2900, hasLiveAvailability: true
        ),
        VenueListItem(
            id: "2", name: "Auburn Basketball Stadium",
            suburb: "Auburn", lat: -33.85, lng: 151.02,
            courtCount: 4, dedicatedBadminton: false,
            distanceKm: 7.1, priceFrom: 3400, hasLiveAvailability: false
        ),
        VenueListItem(
            id: "3", name: "Parramatta Community Hall",
            suburb: "Parramatta", lat: -33.81, lng: 151.00,
            courtCount: 2, dedicatedBadminton: false,
            distanceKm: nil, priceFrom: nil, hasLiveAvailability: false
        ),
    ]
}

#Preview("List — loaded, light") {
    NavigationStack {
        VenueListScreen(model: .preview(state: .loaded(previewVenues())))
    }
    .preferredColorScheme(.light)
}

#Preview("List — loaded, A–Z, dark") {
    NavigationStack {
        VenueListScreen(model: .preview(
            state: .loaded(previewVenues()),
            sortOption: .alphabetical
        ))
    }
    .preferredColorScheme(.dark)
}

#Preview("List — loading, light") {
    NavigationStack {
        VenueListScreen(model: .preview(state: .loading))
    }
    .preferredColorScheme(.light)
}

#Preview("List — empty, dark") {
    NavigationStack {
        VenueListScreen(model: .preview(
            state: .loaded([]),
            filters: FilterState(radiusKm: 5, maxPriceCents: 3000, dedicatedOnly: true)
        ))
    }
    .preferredColorScheme(.dark)
}

#Preview("List — error, light") {
    NavigationStack {
        VenueListScreen(model: .preview(state: .failed("The network connection was lost.")))
    }
    .preferredColorScheme(.light)
}
