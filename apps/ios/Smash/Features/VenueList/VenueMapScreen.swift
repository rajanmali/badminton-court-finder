import SwiftUI

/// The Map tab — the full glass redesign.
///
/// A `ZStack` of overlays over a full-bleed ``VenueMapView``:
/// - a top legibility **scrim** under a "Smash" wordmark (+ green dot) and a
///   thick-glass **"Filters" pill** that reveals the shared ``FilterBar`` and
///   shows a red dot while any filter is active;
/// - an ultra-thin glass **locate** button bottom-right;
/// - a thick-glass **preview card** that rises when a pin is tapped (court tile,
///   name + badge, suburb · dist, From $X/hr + courts, ✕, full-width "View
///   venue ›" → detail).
///
/// Mirrors `MapScreen` in `design_handoff_smash/app/screens.jsx`. The model is
/// passed in (not created) so List and Map share one source of truth for
/// venues / filters / location.
struct VenueMapScreen: View {
    @Bindable var model: VenueListModel

    /// Collaborators (location service) for the locate button.
    @Environment(\.appEnvironment) private var env
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Called when "View venue" is tapped — forwards id + name so the host
    /// pushes the venue detail onto the navigation path.
    var onSelectVenue: (String, String) -> Void = { _, _ in }

    /// Whether the collapsible filter panel is revealed.
    @State private var showFilters = false

    /// The selected pin's venue id, if any. Drives the preview card + the map's
    /// enlarged/ringed selected-pin state.
    @State private var selectedID: String?

    /// The selected venue resolved against the currently displayed venues.
    /// `nil` when nothing is selected or the selection was filtered out.
    private var selectedVenue: VenueListItem? {
        guard let selectedID else { return nil }
        return model.displayedVenues.first { $0.id == selectedID }
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Full-bleed map behind all chrome.
            VenueMapView(
                venues: model.displayedVenues,
                userCoords: model.userCoords,
                selectedID: selectedID,
                onVenueTap: { id, _ in select(id) }
            )
            .ignoresSafeArea()

            topChrome

            locateButton

            if let venue = selectedVenue {
                previewCard(for: venue)
            }
        }
        // Clear the selection whenever the filters change (matches the
        // prototype's `setSel(null)` on filter change) — the venue may no
        // longer be present.
        .onChange(of: model.filters) { _, _ in
            selectedID = nil
        }
        // We draw custom chrome, so hide the system navigation bar.
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Top chrome (scrim + wordmark + Filters pill + filter panel)

    private var topChrome: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                wordmark
                Spacer()
                filtersPill
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            if showFilters {
                FilterBar(
                    filters: $model.filters,
                    locationDenied: model.locationDenied
                )
                .padding(.top, 11)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background(alignment: .top) {
            // Legibility scrim: opaque-ish at the very top, fading to clear
            // ~120pt down. Non-interactive so map gestures pass through.
            LinearGradient(
                colors: [
                    Color.pageBackground.opacity(0.92),
                    Color.pageBackground.opacity(0.5),
                    .clear,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 200)
            .frame(maxWidth: .infinity, alignment: .top)
            .allowsHitTesting(false)
            .ignoresSafeArea(edges: .top)
        }
    }

    private var wordmark: some View {
        HStack(spacing: 7) {
            Text("Smash")
                .font(Typography.headline)
                .tracking(-0.5)
                .foregroundStyle(Color.textPrimary)
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
                .greenGlow()
        }
    }

    private var filtersPill: some View {
        Button {
            toggleFilters()
        } label: {
            HStack(spacing: 7) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.green)
                Text("Filters")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                if filtersAreActive(model.filters) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 7, height: 7)
                }
            }
            .padding(.vertical, 9)
            .padding(.horizontal, 14)
            .glass(.thick, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Locate button

    private var locateButton: some View {
        Button {
            Task { await model.loadLocation(using: env.locationService) }
        } label: {
            Image(systemName: "location.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.green)
                .frame(width: 46, height: 46)
                .glass(.ultraThin, in: Circle())
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(.trailing, 16)
        // Float above the tab bar (~26pt float + bar height + safe area);
        // raise further when a preview card is showing.
        .padding(.bottom, selectedVenue == nil ? 100 : 300)
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8),
                   value: selectedVenue == nil)
    }

    // MARK: - Preview card

    private func previewCard(for venue: VenueListItem) -> some View {
        MapPreviewCard(
            venue: venue,
            onViewVenue: { onSelectVenue(venue.id, venue.name) },
            onClose: { clearSelection() }
        )
        .padding(.horizontal, 14)
        // Sit above the floating tab bar.
        .padding(.bottom, 96)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Actions

    /// Select a pin (show its preview). Switching pins replaces the preview.
    private func select(_ id: String) {
        if reduceMotion {
            selectedID = id
        } else {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                selectedID = id
            }
        }
    }

    private func clearSelection() {
        if reduceMotion {
            selectedID = nil
        } else {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                selectedID = nil
            }
        }
    }

    private func toggleFilters() {
        if reduceMotion {
            showFilters.toggle()
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                showFilters.toggle()
            }
        }
    }
}

// MARK: - MapPreviewCard

/// The thick-glass preview card that rises from the bottom on pin tap.
///
/// Mirrors `PreviewCard` in `design_handoff_smash/app/cards.jsx`: a court tile,
/// the venue name + ``DedicatedBadge``, a "suburb · {dist} km" line, a
/// "From $X/hr" + "{n} courts" meta row, a close ✕ (top-right), and a
/// full-width green "View venue ›" button.
private struct MapPreviewCard: View {
    let venue: VenueListItem
    let onViewVenue: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                CourtTile(
                    initial: String(venue.name.prefix(1)).uppercased(),
                    dedicated: venue.dedicatedBadminton,
                    size: 62
                )

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 7) {
                        Text(venue.name)
                            .font(Typography.cardTitle)
                            .tracking(-0.4)
                            .foregroundStyle(Color.textPrimary)
                            .lineLimit(1)
                        if venue.dedicatedBadminton {
                            DedicatedBadge()
                        }
                    }

                    Text(locationLine)
                        .font(Typography.caption)
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)

                    HStack(spacing: 12) {
                        priceLabel
                        Label {
                            Text("\(venue.courtCount) courts")
                                .font(Typography.caption)
                                .foregroundStyle(Color.textSecondary)
                        } icon: {
                            Image(systemName: "sportscourt.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.textSecondary)
                        }
                        .labelStyle(.titleAndIcon)
                    }
                }

                Spacer(minLength: 0)
            }

            Button(action: onViewVenue) {
                HStack(spacing: 6) {
                    Text("View venue")
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .heavy))
                }
            }
            .buttonStyle(.primary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glass(.thick, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .overlay(alignment: .topTrailing) {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(Color.textSecondary)
                    .frame(width: 28, height: 28)
                    .background(Color.chipBackground, in: Circle())
            }
            .buttonStyle(.plain)
            .padding(12)
        }
    }

    /// "suburb · {dist} km" — distance omitted when unknown.
    private var locationLine: String {
        if let distance = venue.distanceKm {
            return "\(venue.suburb) · \(formatDistance(distance)) km"
        }
        return venue.suburb
    }

    /// One-decimal distance, trimming a trailing ".0".
    private func formatDistance(_ km: Double) -> String {
        let rounded = (km * 10).rounded() / 10
        return rounded == rounded.rounded()
            ? String(Int(rounded))
            : String(format: "%.1f", rounded)
    }

    /// "From $X/hr" in green, or "Rates not listed" when no price is known.
    @ViewBuilder
    private var priceLabel: some View {
        if venue.priceFrom != nil {
            Text("From \(formatPriceCents(venue.priceFrom))")
                .font(.system(size: 16, weight: .heavy))
                .tracking(-0.4)
                .foregroundStyle(Color.green)
        } else {
            Text("Rates not listed")
                .font(Typography.caption)
                .foregroundStyle(Color.textTertiary)
        }
    }
}

// MARK: - Previews

private func mapPreviewVenues() -> [VenueListItem] {
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

#Preview("Map — no selection, light") {
    NavigationStack {
        VenueMapScreen(model: .preview(state: .loaded(mapPreviewVenues())))
    }
    .preferredColorScheme(.light)
}

#Preview("Map — preview card, dark") {
    // Pre-select a venue so the preview card overlay shows over the (key-less)
    // map fallback — focus is the chrome + preview card.
    let model = VenueListModel.preview(state: .loaded(mapPreviewVenues()))
    NavigationStack {
        VenueMapScreenPreviewHarness(model: model, selectedID: "1")
    }
    .preferredColorScheme(.dark)
}

#Preview("Map — filters revealed, light") {
    let model = VenueListModel.preview(
        state: .loaded(mapPreviewVenues()),
        filters: FilterState(radiusKm: 10, maxPriceCents: 3500, dedicatedOnly: true)
    )
    NavigationStack {
        VenueMapScreenPreviewHarness(model: model, showFilters: true)
    }
    .preferredColorScheme(.light)
}

/// A tiny harness that drives ``VenueMapScreen``'s private overlay state for
/// previews (selected pin / revealed filters) without exposing that state in
/// the production API.
private struct VenueMapScreenPreviewHarness: View {
    @Bindable var model: VenueListModel
    var selectedID: String?
    var showFilters: Bool = false

    var body: some View {
        ZStack {
            // Stand-in backdrop so the glass overlays read in previews (the
            // real map needs a MapTiler key, absent in previews).
            SmashBackdrop()
            VenueMapScreenOverlayPreview(
                model: model,
                selectedID: selectedID,
                showFilters: showFilters
            )
        }
    }
}

/// Renders only the overlay chrome (scrim/wordmark/Filters/locate/preview) for
/// previews — the live ``VenueMapScreen`` builds the same overlays atop the
/// MapLibre view, which can't render without a key in a preview.
private struct VenueMapScreenOverlayPreview: View {
    @Bindable var model: VenueListModel
    @State var selectedID: String?
    @State var showFilters: Bool

    init(model: VenueListModel, selectedID: String?, showFilters: Bool) {
        self.model = model
        _selectedID = State(initialValue: selectedID)
        _showFilters = State(initialValue: showFilters)
    }

    private var selectedVenue: VenueListItem? {
        guard let selectedID else { return nil }
        return model.displayedVenues.first { $0.id == selectedID }
    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    HStack(spacing: 7) {
                        Text("Smash")
                            .font(Typography.headline)
                            .tracking(-0.5)
                            .foregroundStyle(Color.textPrimary)
                        Circle().fill(Color.green).frame(width: 8, height: 8).greenGlow()
                    }
                    Spacer()
                    HStack(spacing: 7) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.green)
                        Text("Filters")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.textPrimary)
                        if filtersAreActive(model.filters) {
                            Circle().fill(Color.red).frame(width: 7, height: 7)
                        }
                    }
                    .padding(.vertical, 9)
                    .padding(.horizontal, 14)
                    .glass(.thick, in: Capsule())
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                if showFilters {
                    FilterBar(filters: $model.filters, locationDenied: model.locationDenied)
                        .padding(.top, 11)
                }
            }

            Image(systemName: "location.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.green)
                .frame(width: 46, height: 46)
                .glass(.ultraThin, in: Circle())
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, 16)
                .padding(.bottom, selectedVenue == nil ? 100 : 300)

            if let venue = selectedVenue {
                MapPreviewCard(venue: venue, onViewVenue: {}, onClose: { selectedID = nil })
                    .padding(.horizontal, 14)
                    .padding(.bottom, 96)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
    }
}
