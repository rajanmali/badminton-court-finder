# Roadmap & Milestones

Each phase ends with a working, demoable increment — no "big bang" integration
at the end.

## Phase 0: Planning (current)

- [x] Feasibility research (booking platform landscape, data access options).
- [x] PRD, technical design, risk register, ADRs, test plan (this set).
- [ ] Repo scaffolded (monorepo structure, CI skeleton).
- [ ] Venue outreach emails sent (runs in parallel with Phase 1, doesn't block it).

## Phase 1: Static directory (MVP)

> **Note (ADR-0010):** The mobile app is being rewritten as a native iOS Swift/SwiftUI app (`apps/ios/`). Android, including the Phase 3 Android widget, is deferred until traction. iOS app functionality is unchanged in scope.

**Goal:** A real app on your phone showing all ~20 Sydney venues with rates,
hours, location, and deep links — no live availability yet.

- Supabase schema for `venues`, `rate_cards`, `opening_hours`.
- Seed data from venue research already collected.
- Expo app: venue list (with map), venue detail screen, filters (distance,
  price, dedicated vs. multi-sport).
- Deep links to each venue's booking page.
- Basic CI/CD, Sentry, TestFlight/Internal Testing set up.

**Demo at end of phase:** Install on your phone, browse all venues, tap through
to a real booking page.

## Phase 2: Live availability (pilot)

**Goal:** 2-3 partnered venues show real availability data.

- `availability_partnerships` + `availability_snapshots` tables.
- First availability adapter built end-to-end against one real venue's feed
  (whichever partnership lands first).
- Sync worker scheduled job.
- `GET /venues/:id/availability` endpoint live.
- App UI: availability indicator on venue list/detail for partnered venues;
  "check on venue site" for others.

**Demo at end of phase:** App shows "3 courts free 6-7pm" for at least one real
venue, updating on a schedule.

## Phase 3: Android home screen widget

**Goal:** Widget showing availability for user's selected/nearby venues.

- `GET /widget/summary` endpoint.
- Local sync store (MMKV/SQLite) populated by background task.
- `react-native-android-widget` integration.
- Widget configuration UI (choose which venue(s) to show).

**Demo at end of phase:** Widget on home screen showing live-ish data without
opening the app.

## Phase 4: iOS widget

**Goal:** Feature parity widget for iOS.

- Native Swift WidgetKit extension consuming the same local sync data (via
  shared app group container).
- Scoped as its own sub-project per ADR-004.

## Phase 5: Expand & refine

- Additional venue partnerships (using Phase 1-4 as proof for outreach).
- Crowd-sourced data correction flow (if validated as needed).
- Usage-driven refinements (PostHog data informs what to prioritize).
- Re-evaluate risk register; revisit non-goals from PRD for possible v2 scope.

## Sequencing notes

- Outreach (Phase 0/1 parallel task) has the longest lead time and least
  predictable timeline — starting it early is the single highest-leverage
  scheduling decision in this plan.
- Phase 1 has zero dependency on Phase 2+ — if partnerships take months, you
  still have a useful, shippable app.
- Phase 3 (Android widget) doesn't require Phase 2 to be "done" for all venues —
  it can launch showing whatever venues have live data plus static info for
  others, same pattern as the main app.
