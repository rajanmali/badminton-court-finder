import SwiftUI

/// The List tab — the full redesigned List experience.
///
/// Assembles the screen as a ZStack: the backdrop, a scrollable content area, and
/// a sticky ``ListHeader`` overlay at the top. The header is positioned OUTSIDE
/// the scroll content so venues scroll underneath it, enabling a scroll-driven
/// progressive glass effect on the header background.
///
/// The ``ListHeader`` background is invisible at `scrollY = 0` and fades to
/// a thick-glass material as the content scrolls ~40pt under it, driven by
/// `onScrollGeometryChange` + `withAnimation`.
///
/// Mirrors `ListScreen` in `design_handoff_smash/app/screens.jsx`.
struct VenueListScreen: View {
    @Bindable var model: VenueListModel

    @Environment(\.appEnvironment) private var env

    var onSelectVenue: (String, String) -> Void = { _, _ in }

    @State private var showFilters = false
    /// Scroll distance from the top of the content (0 at rest).
    @State private var scrollOffset: CGFloat = 0

    // MARK: - Header glass progress

    /// 0→1 as the first 40pt of content scrolls under the header.
    private var headerGlassProgress: CGFloat {
        min(max(scrollOffset / 40, 0), 1)
    }

    var body: some View {
        ZStack(alignment: .top) {
            SmashBackdrop()
                .ignoresSafeArea()

            // Scrollable content — top padding clears the sticky header.
            scrollableContent

            // Sticky header — sits on top; glass background fades in on scroll.
            stickyHeader
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // We draw a custom header, so hide the system navigation bar.
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showFilters) {
            FiltersSheet(
                filters: $model.filters,
                sort: $model.sortOption,
                locationDenied: model.locationDenied
            )
        }
    }

    // MARK: - Sticky header

    private var stickyHeader: some View {
        ListHeader(
            onLocate: locate,
            onOpenFilters: { showFilters = true },
            filtersActive: filtersAreActive(model.filters),
            glassProgress: headerGlassProgress
        )
    }

    // MARK: - Scrollable content

    @ViewBuilder
    private var scrollableContent: some View {
        switch model.state {
        case .loading:
            ListLoadingState()

        case .failed:
            ListErrorState(onRetry: retry)

        case .loaded:
            loadedScrollContent
        }
    }

    @ViewBuilder
    private var loadedScrollContent: some View {
        if model.displayedVenues.isEmpty {
            ListEmptyState(onReset: resetFilters)
        } else {
            ScrollView {
                LazyVStack(spacing: Spacing.cardGap) {
                    // Invisible top spacer so content starts BELOW the sticky
                    // header. Height is approximate; the header auto-sizes.
                    Color.clear.frame(height: 80)

                    ListMetaRow(
                        count: model.displayedVenues.count,
                        sortLabel: model.sortOption.label
                    )

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
                // Clear the floating tab bar — use the shared constant.
                .padding(.bottom, TabBar.reservedBottomSpace)
            }
            .scrollContentBackground(.hidden)
            .onScrollGeometryChange(for: CGFloat.self) { geo in
                geo.contentOffset.y + geo.contentInsets.top
            } action: { _, newValue in
                withAnimation(.easeOut(duration: 0.15)) {
                    scrollOffset = newValue
                }
            }
            .refreshable {
                await model.refresh(using: env.venueRepository)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            // Clear the floating tab bar (floats ~26pt up + its own height).
            .padding(.bottom, 88)
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
