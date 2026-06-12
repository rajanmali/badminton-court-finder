# CONTEXT.md — Badminton Court Finder (Sydney)

Domain vocabulary and invariants for this codebase. Engineering skills read this before exploring code. Use these terms exactly — don't drift to synonyms.

## Core domain concepts

**Venue** — a physical location in Sydney where badminton courts can be booked. A venue is either *dedicated* or *multi-sport*. **Dedicated** means its badminton courts are permanently configured for badminton: fixed nets, badminton-specific flooring or lines, not shared with other sports on a schedule rotation. A sports complex with a permanently set-up badminton hall qualifies as dedicated even if the broader premises has other facilities. A council hall that rotates between badminton and basketball nights is multi-sport. Every venue has a `booking_url` that deep-links to its own booking platform — the app never handles booking or payment.

**Rate card** — a pricing rule for a venue. One venue has many rate cards (e.g. "Off-Peak Mon–Fri before 5pm", "Peak evenings and weekends"). Prices are always stored in **cents** (integer), never as floats. A rate card with no `time_range_start`/`time_range_end` is a valid flat/all-day rate. **Price-from** is the lowest `price_cents` across all of a venue's rate cards, formatted as AUD/hr. A venue with no rate cards is described as "Rates not listed" — this is the canonical phrase; do not use "free", "—", or a blank.

**Opening hours** — per-day open/close times for a venue. Stored per day-of-week (0=Sunday…6=Saturday). Separate from rate cards.

**Partnership** — a formal data-sharing agreement between the app and a venue. Without a partnership, a venue appears in the directory with static info only ("check availability on venue site"). With a partnership, the venue provides a feed (iCal, webhook, etc.) that the sync worker polls.

**Feed** — the raw data source from a partnered venue. Currently expected formats: iCal (most common), webhook, manual upload. A feed represents *bookings* (busy blocks), not availability directly — see Availability Snapshot below.

**AvailabilityAdapter** — a per-platform module (one per booking platform: `sportlogic`, `skedda`, `pitchbooking`, `yepbooking`, `council`, `other`) that transforms raw feed data into normalized `AvailabilitySnapshot` records. The interface is fixed; adding a new platform = writing one new adapter, no changes to API/app/widget.

**AvailabilitySnapshot** — the normalized, platform-agnostic record of court availability for one time slot at one venue. Shape: `{ venueId, date, timeSlotStart, courtsAvailable, courtsTotal, fetchedAt }`. This is the **only** availability shape the API, app, and widget ever read — never raw feed data.

**Sync worker** — the background service that polls feeds on a per-partnership schedule, runs each feed through its `AvailabilityAdapter`, and writes `AvailabilitySnapshot` rows to Postgres. Isolated from the API so a broken feed can't affect unrelated venues.

**Widget** — home screen widget (Android first, iOS later) showing court availability for user-selected venues without opening the app. The widget reads from a **local sync store** (MMKV or SQLite) — it cannot make network calls directly. The app populates the local store via a WorkManager background task.

**Booking platform** — the third-party SaaS a venue uses for court reservations (Sport Logic/intennis-style, Skedda, Pitchbooking, yepbooking, council systems). The app does not integrate with these for booking — only for availability data via partnerships.

**Distance** — straight-line distance (haversine) between the user's location and a venue's `lat`/`lng`. Always labelled "X km away" in the UI — never "X km drive". Road distance is explicitly out of scope for Phase 1. Distance filter steps: 5 km / 10 km / 25 km / Any. Default is **Any** (all venues shown).

**Default sort order** — dedicated venues first, then alphabetical within each group. When a distance filter is active, sort switches to distance ascending. This ordering is stable regardless of location permission state.

## Invariants

- **No scraping** — live availability is only sourced via explicit venue partnerships. This is ADR-0002 and is not negotiable. See `docs/adr/0002-no-scraping.md`.
- **Prices in cents** — all monetary values are integers representing AUD cents.
- **Times in UTC** — all times stored UTC, converted to `Australia/Sydney` at the API/app layer. DST transitions (AEST/AEDT) require test coverage.
- **iCal = bookings, not availability** — iCal feeds represent busy blocks. The adapter computes `courtsAvailable` by subtracting bookings from total capacity per slot, using opening hours + court count.
- **Sanity is editorial-only** — Sanity CMS stores descriptions, photos, and amenities. It never stores availability data. Availability never touches Sanity.

## Phases

- **Phase 1**: Static directory (all venues, no live availability).
- **Phase 2**: Live availability for 2–3 partnered venues.
- **Phase 3**: Android home screen widget.
- **Phase 4**: iOS widget (native Swift WidgetKit extension).
- **Phase 5**: Expand partnerships, usage-driven refinements.
