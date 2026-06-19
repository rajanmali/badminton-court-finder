import SwiftUI

/// The Saved tab — the user's favourited venues (UX fix #7).
///
/// Reads the *full* loaded venue set from the shared ``VenueListModel`` via
/// ``VenueListModel/allVenues`` (deliberately **unaffected by the List/Map
/// filters**) and shows the subset the user has favourited. Favourites live in
/// the shared, `@Observable` ``AppPreferences`` read from the environment, so
/// toggling the star on Venue Detail updates this list live — when
/// `favouriteIDs` changes, SwiftUI re-runs `body` and `savedVenues` recomputes.
///
/// Layout mirrors the other tabs: a glass ``SavedHeader`` (a "Saved" wordmark in
/// place of the system nav bar — the locate/Filters controls aren't relevant
/// here) over a ``SmashBackdrop``, then either glass ``VenueRow`` cards in a
/// scrolling `LazyVStack` (same rhythm as the List tab, with bottom clearance
/// for the floating tab bar) or a centred empty state.
struct SavedScreen: View {
    @Bindable var model: VenueListModel

    /// Called when a venue card is selected — routed through the host
    /// (``RootTabView``) to push Venue Detail onto the shared path.
    var onSelectVenue: (String, String) -> Void = { _, _ in }

    @Environment(\.preferences) private var preferences

    /// The favourited venues, drawn from the full loaded set (NOT the filtered
    /// list) so Saved is independent of the active List/Map filters. Recomputes
    /// whenever `preferences.favouriteIDs` or the loaded venues change.
    private var savedVenues: [VenueListItem] {
        model.allVenues.filter { preferences.isFavourite($0.id) }
    }

    var body: some View {
        VStack(spacing: 14) {
            SavedHeader()
            content
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SmashBackdrop())
        // We draw a custom header, so hide the system navigation bar.
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if savedVenues.isEmpty {
            SavedEmptyState()
        } else {
            cardList
        }
    }

    private var cardList: some View {
        // Same ScrollView + LazyVStack rhythm as the List tab. NavigationLink with
        // .buttonStyle(.venueCard) routes press state into the card scale effect.
        ScrollView {
            LazyVStack(spacing: Spacing.cardGap) {
                ForEach(savedVenues) { venue in
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
            // Clear the floating tab bar — keep in sync with TabBar.reservedBottomSpace.
            .padding(.bottom, TabBar.reservedBottomSpace)
        }
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Header

/// The Saved-tab header — drawn in place of the system navigation bar, mirroring
/// ``ListHeader``'s wordmark treatment but titled "Saved" and without the
/// locate/Filters controls (they have no meaning on this tab).
private struct SavedHeader: View {
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 1) {
                HStack(alignment: .center, spacing: 8) {
                    Text("Saved")
                        .font(.system(size: 32, weight: .black))
                        .tracking(-1.5)
                        .foregroundStyle(Color.textPrimary)

                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.green)
                }

                Text("Your favourite courts")
                    .font(Typography.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer(minLength: Spacing.md)
        }
        .padding(.horizontal, Spacing.screen)
        .padding(.top, 2)
    }
}

// MARK: - Empty state

/// Shown when there are no favourites: a glass rounded-square bookmark icon, a
/// title, and a one-line hint pointing at the detail star. Consistent with
/// ``ListEmptyState`` (`VenueListStates.swift`).
private struct SavedEmptyState: View {
    var body: some View {
        VStack(spacing: 0) {
            SavedStateIcon()
                .padding(.bottom, 22)

            Text("No saved venues yet")
                .font(Typography.title)
                .tracking(-0.6)
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)

            Text("Tap the bookmark on a venue to save it here.")
                .font(Typography.subhead)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 270)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 26)
    }
}

/// The 96×96 glass rounded-square icon for the empty state — a faint halftone
/// fill behind a large green bookmark. Mirrors the (private) `StateIcon` in
/// `VenueListStates.swift`.
private struct SavedStateIcon: View {
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)
        ZStack {
            Halftone(color: .green, opacity: 0.45)
                .mask(
                    RadialGradient(
                        colors: [.black, .black.opacity(0.5), .clear],
                        center: .center, startRadius: 0, endRadius: 60
                    )
                )
            Image(systemName: "bookmark")
                .font(.system(size: 38, weight: .regular))
                .foregroundStyle(Color.green)
        }
        .frame(width: 96, height: 96)
        .clipShape(shape)
        .glass(.regular, in: shape)
    }
}

// MARK: - Previews

private func savedPreviewVenues() -> [VenueListItem] {
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
    ]
}

/// Builds preferences with the given favourite IDs over an ephemeral defaults
/// suite, so previews don't touch `.standard`.
@MainActor
private func previewPreferences(favourites: [String]) -> AppPreferences {
    let suiteName = "smash.savedscreen.preview.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName) ?? .standard
    defaults.set(favourites, forKey: "smash.favouriteIDs")
    return AppPreferences(defaults: defaults)
}

#Preview("Saved — populated, light") {
    NavigationStack {
        SavedScreen(model: .preview(state: .loaded(savedPreviewVenues())))
    }
    .environment(\.preferences, previewPreferences(favourites: ["1", "2"]))
    .preferredColorScheme(.light)
}

#Preview("Saved — populated, dark") {
    NavigationStack {
        SavedScreen(model: .preview(state: .loaded(savedPreviewVenues())))
    }
    .environment(\.preferences, previewPreferences(favourites: ["1", "2"]))
    .preferredColorScheme(.dark)
}

#Preview("Saved — empty, light") {
    NavigationStack {
        SavedScreen(model: .preview(state: .loaded(savedPreviewVenues())))
    }
    .environment(\.preferences, previewPreferences(favourites: []))
    .preferredColorScheme(.light)
}

#Preview("Saved — empty, dark") {
    NavigationStack {
        SavedScreen(model: .preview(state: .loaded(savedPreviewVenues())))
    }
    .environment(\.preferences, previewPreferences(favourites: []))
    .preferredColorScheme(.dark)
}
