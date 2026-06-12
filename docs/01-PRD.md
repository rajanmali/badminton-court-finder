# PRD: Badminton Court Finder (Sydney)

**Status:** Draft v1
**Owner:** Rajan Mali
**Last updated:** 12 June 2026

## 1. Problem statement

Sydney badminton players currently need to know about and individually check
multiple venue websites — each with different booking platforms, rates, and
availability views — to find a court. There is no single place to compare venues
by location, price, and availability.

## 2. Goals

- Give players a single app to discover Sydney badminton venues (location, rates,
  hours, court count, amenities).
- Where possible, surface live or near-live court availability.
- Deep-link to each venue's own booking page for the actual booking/payment
  (no in-app payments in v1).
- Provide a home screen widget (Android first, iOS later) showing nearby
  venue availability at a glance.

## 3. Non-goals (explicitly out of scope for v1)

- In-app booking or payment processing.
- User accounts / login (v1 is read-only, no personalization requiring auth).
- Coverage outside Sydney metro.
- Coaching, socials, equipment hire listings (may be future content, not core).
- Real-time availability for venues that haven't agreed to a data-sharing
  partnership — these show static info + "check on venue site" instead.

## 4. Target users / personas

- **Casual player ("Mei", 28)**: wants to book a court tonight, doesn't know
  which venues are close and have space.
- **Regular club player ("Dave", 35)**: has 2-3 preferred venues, wants to quickly
  compare prices across them for a weekly session.
- **New to the area ("Arjun", 24)**: recently moved to Sydney, has no idea what
  venues exist nearby.

## 5. User stories (MVP)

1. As a player, I can see a list/map of badminton venues near my location.
2. As a player, I can view a venue's rates (peak/off-peak), opening hours, court
   count, and amenities.
3. As a player, I can tap through to the venue's booking page to make a booking.
4. As a player, for partnered venues, I can see an indicator of current/near-term
   availability (e.g. "3 courts free 6-7pm").
5. As a player, I can filter venues by distance, price range, and "dedicated
   badminton" vs. multi-sport.
6. As a player, I can add a home screen widget showing availability for my
   chosen nearby venue(s) without opening the app.

## 6. Success metrics

- Number of Sydney venues listed (target: 20+ at launch).
- Number of venues with live availability partnerships (target: 3+ within first
  3 months post-launch).
- App installs / active users (baseline TBD post-launch — this is a portfolio +
  utility project, not VC-scale, so "useful to a meaningful number of local
  players" is the bar, not hypergrowth).
- Widget add-rate among installed users (signal that the widget delivers value).

## 7. Key constraints (carried over from feasibility research)

- No mandated open data feed exists (unlike NSW FuelCheck for fuel prices).
- Venue booking platforms are fragmented across ~5 different vendors
  (Sport Logic/intennis-style, Skedda, Pitchbooking, yepbooking, council systems).
- The largest cluster of dedicated venues (Sport Logic/intennis-style platform)
  blocks robots.txt — live availability there depends on venue partnerships
  providing iCal feeds, not scraping.
- Android widgets cannot poll live — they read from a locally cached store that
  the app syncs periodically (WorkManager-driven).

## 8. Release plan (high level — see roadmap doc for detail)

- **Phase 1**: Static directory (all venues, no live availability) — Android +
  iOS app.
- **Phase 2**: Live availability for partnered venues (pilot with 2-3).
- **Phase 3**: Android home screen widget.
- **Phase 4**: iOS widget (native Swift extension).
- **Phase 5**: Expand partnerships, refine filters/search based on usage data.

## 9. Open questions

- Should venues without partnerships still show a "freshness" timestamp, or just
  omit availability entirely? (Leaning: omit, to avoid implying staleness is
  acceptable.)
- Do we want a feedback mechanism for players to report incorrect rates/hours
  (crowd-sourced correction)? Could reduce manual maintenance burden.
- Long-term: is there a sustainable model (e.g. affiliate/referral arrangement
  with venues) once partnerships mature, or does this stay a free utility/
  portfolio project?
