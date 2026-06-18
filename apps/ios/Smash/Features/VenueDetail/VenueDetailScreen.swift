import SwiftUI

/// The Venue Detail screen — the full glass-redesign port of `DetailScreen`.
///
/// Receives the venue `id` and `name` from the navigation route, then fetches
/// the full detail via ``VenueDetailModel``. The model owns the load lifecycle;
/// this view only renders its ``VenueDetailLoadState``.
///
/// ## States
/// - `.loading` → a large green spinner, centred.
/// - `.failed` → a generic `ContentUnavailableView`.
/// - `.loaded` → a full-bleed gradient hero, an overlapping thick-glass title
///   card with stat tiles, glass rate + opening-hours cards, and a floating
///   thick-glass "Book a court" CTA pinned to the bottom safe-area inset.
///
/// The system nav bar is hidden (`.toolbar(.hidden, …)`); a custom glass back
/// pill drives ``dismiss``.
///
/// Mirrors `DetailScreen` in `design_handoff_smash/app/screens.jsx`. Uses only
/// real model data — there is no rating, review count, or distance on Detail, so
/// those mockup elements are intentionally omitted.
struct VenueDetailScreen: View {

    let venueId: String
    let venueName: String

    @State private var model = VenueDetailModel()
    @Environment(\.appEnvironment) private var env
    @Environment(\.openURL) private var openURL

    var body: some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            .task { await model.load(id: venueId, using: env.venueRepository) }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .loading:
            ProgressView()
                .controlSize(.large)
                .tint(.green)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(SmashBackdrop())

        case let .failed(message):
            ContentUnavailableView {
                Label("Could not load venue", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            }
            .background(SmashBackdrop())

        case let .loaded(venue):
            LoadedDetail(venue: venue, openURL: openURL)
        }
    }
}

// MARK: - Loaded detail

/// The full loaded layout: scrolling hero + title card + sections, with the
/// booking CTA pinned via a bottom safe-area inset and the Back/Favourite/Share
/// chrome pinned as a constant glass top bar (UX fix #6).
private struct LoadedDetail: View {
    let venue: VenueDetail
    let openURL: OpenURLAction

    /// Vertical scroll offset (points scrolled down from rest). Drives the top
    /// bar's background fade so the pills stay legible once the hero scrolls away.
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        // The chrome is pinned OUTSIDE the ScrollView so it stays fixed at the
        // top while the hero + content scroll underneath it (UX fix #6).
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HeroView(venue: venue)

                // Title card overlaps the hero bottom by ~56pt.
                TitleCard(venue: venue)
                    .padding(.horizontal, Spacing.md)
                    .offset(y: -56)
                    .padding(.bottom, -56)

                RatesSection(rateCards: venue.rateCards)
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, 20)

                GoodToKnowSection(rateCards: venue.rateCards)
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, 20)

                OpeningHoursSection(hours: venue.openingHours)
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, 20)
            }
        }
        .onScrollGeometryChange(for: CGFloat.self) { geo in
            geo.contentOffset.y + geo.contentInsets.top
        } action: { _, newValue in
            scrollOffset = newValue
        }
        .scrollContentBackground(.hidden)
        .background(Color.pageBackground.ignoresSafeArea())
        .ignoresSafeArea(edges: .top)
        // Pinned, always-visible top bar with a scroll-offset background fade.
        .overlay(alignment: .top) {
            PinnedTopBar(venue: venue, scrollOffset: scrollOffset)
        }
        // Floating CTA pinned to the bottom; the inset reserves space so scroll
        // content clears it.
        .safeAreaInset(edge: .bottom) {
            BookingCTA(venue: venue, openURL: openURL)
        }
    }
}

// MARK: - Pinned top bar

/// The constant glass top bar that pins the Back / Favourite / Share chrome to
/// the top of the screen, staying visible at every scroll position (UX fix #6).
///
/// A subtle glass background bar fades in behind the controls once the user has
/// scrolled past the hero, so the white pill icons stay legible over the light
/// page content beneath them. The fade is driven by `scrollOffset`.
private struct PinnedTopBar: View {
    let venue: VenueDetail
    let scrollOffset: CGFloat

    /// The hero is 330pt; start fading the background in shortly before its
    /// bottom edge passes the top bar and reach full opacity once well past it.
    private var backgroundOpacity: Double {
        let start: CGFloat = 230
        let end: CGFloat = 300
        let clamped = min(max(scrollOffset, start), end)
        return Double((clamped - start) / (end - start))
    }

    var body: some View {
        HeroChrome(venue: venue)
            .background(alignment: .top) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .top)
                    .overlay(alignment: .bottom) {
                        Divider().overlay(Color.hairline)
                    }
                    .opacity(backgroundOpacity)
                    .allowsHitTesting(false)
            }
    }
}

// MARK: - Hero

/// The full-bleed gradient hero: a green (dedicated) or grey (multi-sport)
/// gradient layered with faint court lines, halftone, an oversized initial
/// watermark, and top + bottom scrims. The glass chrome (back / star / share)
/// is no longer drawn here — it is pinned by ``PinnedTopBar`` so it stays
/// visible while the hero scrolls away (UX fix #6).
private struct HeroView: View {
    let venue: VenueDetail

    private var heroGradient: LinearGradient {
        if venue.dedicatedBadminton {
            return LinearGradient(colors: [.greenBright, .greenDeep],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        return LinearGradient(colors: [Color(hex: 0x3A4046), Color(hex: 0x15181B)],
                              startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var initial: String {
        String(venue.name.prefix(1)).uppercased()
    }

    var body: some View {
        ZStack(alignment: .top) {
            heroGradient

            // Faint court-line + halftone motifs.
            CourtLines(color: .white.opacity(0.28), lineWidth: 1.6)
                .scaleEffect(1.1)
            Halftone(dotSize: 1.4, spacing: 11, color: .white.opacity(0.55), opacity: 0.4)

            // Oversized faint initial watermark, anchored bottom-right.
            Text(initial)
                .font(.system(size: 240, weight: .black))
                .tracking(-12)
                .foregroundStyle(.white.opacity(0.10))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .offset(x: 30, y: 60)
                .clipped()

            // Top scrim for status-bar legibility.
            LinearGradient(
                stops: [
                    .init(color: .black.opacity(0.28), location: 0.0),
                    .init(color: .clear, location: 0.30),
                ],
                startPoint: .top, endPoint: .bottom
            )

            // Bottom scrim fading into the page background.
            VStack {
                Spacer()
                LinearGradient(colors: [.clear, .pageBackground],
                               startPoint: .top, endPoint: .bottom)
                    .frame(height: 90)
            }
        }
        .frame(height: 330)
        .clipped()
    }
}

/// The top chrome — a glass back pill (left) and star + share glass pills
/// (right), all with white icons. Pinned by ``PinnedTopBar`` so it stays at the
/// top while content scrolls (UX fix #6). The back pill dismisses; the star
/// toggles this venue's persisted favourite (UX fix #7); share offers the
/// booking URL when present.
private struct HeroChrome: View {
    let venue: VenueDetail
    @Environment(\.dismiss) private var dismiss
    @Environment(\.preferences) private var preferences
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack {
            // Back.
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .glass(.ultraThin, in: Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            HStack(spacing: 9) {
                // Favourite — toggles this venue's saved state (UX fix #7).
                favouriteButton

                // Share the booking URL when there is one.
                if let url = URL(string: venue.bookingUrl), !venue.bookingUrl.isEmpty {
                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .glass(.ultraThin, in: Circle())
                    }
                    .buttonStyle(.plain)
                } else {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .glass(.ultraThin, in: Circle())
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .frame(maxHeight: .infinity, alignment: .top)
        // Push below the status bar.
        .padding(.top, 50)
    }

    /// The favourite (star) pill. Filled yellow star when saved, outline white
    /// when not; toggling persists via ``AppPreferences`` with a light haptic and
    /// a reduce-motion-safe spring. The 40×40 glass circle gives a ≥44pt target.
    private var favouriteButton: some View {
        let isFavourite = preferences.isFavourite(venue.id)
        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            if reduceMotion {
                preferences.toggleFavourite(venue.id)
            } else {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                    preferences.toggleFavourite(venue.id)
                }
            }
        } label: {
            Image(systemName: isFavourite ? "star.fill" : "star")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(isFavourite ? Color.yellow : .white)
                .frame(width: 40, height: 40)
                .glass(.ultraThin, in: Circle())
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Saved")
        .accessibilityValue(isFavourite ? "Saved" : "Not saved")
        .accessibilityHint(isFavourite ? "Remove from saved" : "Add to saved")
        .accessibilityAddTraits(isFavourite ? [.isButton, .isSelected] : .isButton)
    }
}

// MARK: - Title card

/// The thick-glass title card overlapping the hero: dedicated badge (if any),
/// venue name, address row, and three stat tiles built only from real data.
private struct TitleCard: View {
    let venue: VenueDetail

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if venue.dedicatedBadminton {
                DedicatedBadge()
                    .padding(.bottom, 8)
            }

            Text(venue.name)
                .font(Typography.title)
                .tracking(-1.0)
                .foregroundStyle(Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .padding(.bottom, 7)

            if !venue.address.isEmpty {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "mappin")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.textSecondary)
                        .padding(.top, 2)
                    Text(venue.address)
                        .font(Typography.body)
                        .tracking(-0.2)
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(.bottom, 14)
            }

            HStack(spacing: 10) {
                ForEach(statTiles) { tile in
                    StatTile(icon: tile.icon, label: tile.label)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glass(.thick, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
    }

    /// Stat tiles built from real model data only — no fabricated rating or
    /// distance. Courts + price, plus a venue-type tile.
    private var statTiles: [StatTileData] {
        [
            StatTileData(
                id: "courts",
                icon: "sportscourt.fill",
                label: "\(venue.courtCount) court\(venue.courtCount == 1 ? "" : "s")"
            ),
            StatTileData(
                id: "price",
                icon: "dollarsign",
                label: venue.priceFrom != nil ? "From \(formatPriceCents(venue.priceFrom))" : "Rates n/a"
            ),
            StatTileData(
                id: "type",
                icon: "sportscourt.fill",
                label: venue.dedicatedBadminton ? "Dedicated" : "Multi-sport"
            ),
        ]
    }
}

private struct StatTileData: Identifiable {
    let id: String
    let icon: String
    let label: String
}

/// A single stat tile: a green icon above a small label on a chip-background
/// rounded rect.
private struct StatTile: View {
    let icon: String
    let label: String

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.green)
            Text(label)
                .font(.system(size: 12.5, weight: .bold))
                .tracking(-0.2)
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(Color.chipBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Section title

/// A section header — a green SF Symbol icon beside a headline title.
private struct DetailSectionTitle: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.green)
            Text(title)
                .font(Typography.headline)
                .tracking(-0.5)
                .foregroundStyle(Color.textPrimary)
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 11)
    }
}

// MARK: - Rates section

/// "Court hire rates" — a regular-glass card of rate rows, or a "Rates not
/// listed" placeholder when there are none.
private struct RatesSection: View {
    let rateCards: [RateCard]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            DetailSectionTitle(icon: "dollarsign", title: "Court hire rates")

            Group {
                if rateCards.isEmpty {
                    MissingDataPill("Rates not listed")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 13)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(rateCards.enumerated()), id: \.element.id) { index, card in
                            if index > 0 {
                                Divider().overlay(Color.hairline)
                            }
                            RateCardView(rateCard: card)
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .glass(.regular, in: RoundedRectangle(cornerRadius: Radius.section, style: .continuous))
        }
    }
}

// MARK: - Good to know section

/// "Good to know" — the long policy notes that no longer fit the inline rate
/// pills (UX fix #5). Shown only when at least one rate card has a
/// ``RateCard/policyNote``. Each entry pairs the rate's `label` with its policy
/// text (wrapping freely), separated by hairlines; identical notes are deduped
/// so a shared policy (e.g. one cancellation policy on three rates) reads once.
private struct GoodToKnowSection: View {
    let rateCards: [RateCard]

    /// One row per distinct policy note, keyed by the note text so identical
    /// policies collapse. Each row keeps the *first* rate label that carries it.
    private var entries: [PolicyEntry] {
        var seen = Set<String>()
        var result: [PolicyEntry] = []
        for card in rateCards {
            guard let note = card.policyNote else { continue }
            guard seen.insert(note).inserted else { continue }
            result.append(PolicyEntry(id: card.id, label: card.label, note: note))
        }
        return result
    }

    var body: some View {
        let entries = entries
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                DetailSectionTitle(icon: "info.circle", title: "Good to know")

                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                        if index > 0 {
                            Divider().overlay(Color.hairline)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(entry.label)
                                .font(Typography.body)
                                .tracking(-0.3)
                                .foregroundStyle(Color.textPrimary)
                            Text(entry.note)
                                .font(Typography.caption)
                                .foregroundStyle(Color.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 13)
                    }
                }
                .padding(.horizontal, Spacing.md)
                .glass(.regular, in: RoundedRectangle(cornerRadius: Radius.section, style: .continuous))
            }
        }
    }
}

/// A single "Good to know" row: a rate `label` and its long policy `note`.
private struct PolicyEntry: Identifiable {
    let id: String
    let label: String
    let note: String
}

// MARK: - Opening hours section

/// "Opening hours" — a regular-glass card, or a placeholder when no hours exist.
private struct OpeningHoursSection: View {
    let hours: [OpeningHours]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            DetailSectionTitle(icon: "clock", title: "Opening hours")

            Group {
                if hours.isEmpty {
                    MissingDataPill("Hours not listed")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 13)
                } else {
                    OpeningHoursView(hours: hours)
                }
            }
            .padding(.horizontal, Spacing.md)
            .glass(.regular, in: RoundedRectangle(cornerRadius: Radius.section, style: .continuous))
        }
    }
}

// MARK: - Booking CTA

/// The floating thick-glass CTA bar: a "FROM / $price" block beside a green
/// Book button. The button label and target come from ``getBookingAction``;
/// when there is no contact action, the button is hidden. Tapping fires a medium
/// impact haptic and opens the action URL.
private struct BookingCTA: View {
    let venue: VenueDetail
    let openURL: OpenURLAction

    var body: some View {
        let action = getBookingAction(
            bookingUrl: venue.bookingUrl,
            phone: venue.phone,
            email: venue.email
        )

        HStack(spacing: 12) {
            // FROM / price block.
            VStack(alignment: .leading, spacing: 0) {
                Text("From")
                    .font(Typography.micro)
                    .tracking(0.4)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.textTertiary)
                priceLabel
            }
            .padding(.leading, 8)

            if let label = actionLabel(action), let href = actionHref(action) {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    if let url = URL(string: href) {
                        openURL(url)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(label)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .heavy))
                    }
                }
                .buttonStyle(.primary)
            }
        }
        .padding(10)
        .glass(.thick, in: RoundedRectangle(cornerRadius: Radius.section, style: .continuous))
        .padding(.horizontal, Spacing.md)
        .padding(.top, 8)
    }

    /// `$29/hr` with the amount in the primary text color and `/hr` in tertiary.
    private var priceLabel: some View {
        let full = formatPriceCents(venue.priceFrom)
        if let slash = full.firstIndex(of: "/") {
            let amount = String(full[full.startIndex..<slash])
            let suffix = String(full[slash...])
            return Text(amount)
                .font(.system(size: 22, weight: .black))
                .tracking(-1.0)
                .foregroundStyle(Color.textPrimary)
                + Text(suffix)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.textTertiary)
        }
        return Text(full)
            .font(.system(size: 17, weight: .black))
            .foregroundStyle(Color.textPrimary)
            + Text("")
    }

    private func actionLabel(_ action: BookingAction) -> String? {
        switch action {
        case let .url(label, _), let .phone(label, _), let .email(label, _):
            return label
        case .none:
            return nil
        }
    }

    private func actionHref(_ action: BookingAction) -> String? {
        switch action {
        case let .url(_, href), let .phone(_, href), let .email(_, href):
            return href
        case .none:
            return nil
        }
    }
}

// MARK: - Previews

private func previewVenue(dedicated: Bool) -> VenueDetail {
    VenueDetail(
        id: "1",
        name: dedicated ? "Sydney Olympic Park Badminton Centre" : "Auburn Basketball Stadium",
        suburb: dedicated ? "Olympic Park" : "Auburn",
        lat: -33.85, lng: 151.07,
        courtCount: dedicated ? 12 : 4,
        dedicatedBadminton: dedicated,
        distanceKm: nil,
        priceFrom: dedicated ? 2900 : 3400,
        hasLiveAvailability: dedicated,
        slug: "preview",
        address: "1 Olympic Blvd, Sydney Olympic Park NSW 2127",
        phone: "02 9000 1234",
        email: "info@example.com",
        bookingUrl: "https://example.com/book",
        platform: .other,
        rateCards: [
            // Short tag → inline pill on the rate row.
            RateCard(
                id: "rc-1", label: "Peak hour", priceCents: 3500,
                daysApply: ["mon", "tue", "wed", "thu", "fri"],
                timeRangeStart: "17:00", timeRangeEnd: "21:00",
                notes: "Most popular"
            ),
            // Long policy note → no pill; appears in "Good to know".
            RateCard(
                id: "rc-2", label: "Off-peak", priceCents: 2900,
                daysApply: [], timeRangeStart: nil, timeRangeEnd: nil,
                notes: "Includes public holidays. Racquet hire available during staffed hours 4–10pm."
            ),
        ],
        openingHours: [
            OpeningHours(dayOfWeek: 1, openTime: "06:00", closeTime: "22:00", isClosed: false),
            OpeningHours(dayOfWeek: 2, openTime: "06:00", closeTime: "22:00", isClosed: false),
            OpeningHours(dayOfWeek: 3, openTime: "06:00", closeTime: "22:00", isClosed: false),
            OpeningHours(dayOfWeek: 4, openTime: "06:00", closeTime: "22:00", isClosed: false),
            OpeningHours(dayOfWeek: 5, openTime: "06:00", closeTime: "22:00", isClosed: false),
            OpeningHours(dayOfWeek: 6, openTime: "08:00", closeTime: "20:00", isClosed: false),
            OpeningHours(dayOfWeek: 0, openTime: nil, closeTime: nil, isClosed: true),
        ]
    )
}

#Preview("Detail — dedicated, light") {
    NavigationStack {
        LoadedDetailPreview(venue: previewVenue(dedicated: true))
    }
    .preferredColorScheme(.light)
}

#Preview("Detail — dedicated, dark") {
    NavigationStack {
        LoadedDetailPreview(venue: previewVenue(dedicated: true))
    }
    .preferredColorScheme(.dark)
}

#Preview("Detail — multi-sport, light") {
    NavigationStack {
        LoadedDetailPreview(venue: previewVenue(dedicated: false))
    }
    .preferredColorScheme(.light)
}

#Preview("Detail — multi-sport, dark") {
    NavigationStack {
        LoadedDetailPreview(venue: previewVenue(dedicated: false))
    }
    .preferredColorScheme(.dark)
}

/// Renders the loaded layout directly for previews (no async load).
private struct LoadedDetailPreview: View {
    let venue: VenueDetail
    @Environment(\.openURL) private var openURL
    var body: some View {
        LoadedDetail(venue: venue, openURL: openURL)
            .toolbar(.hidden, for: .navigationBar)
    }
}
