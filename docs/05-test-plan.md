# Test Plan & QA Strategy

## 1. Test pyramid

- **Unit tests (most numerous)**: pure functions — especially the availability
  normalization adapters (highest bug risk, per RFC-0001 open questions), rate
  formatting/display logic, distance calculations.
- **Integration tests**: API endpoints against a real (test) Postgres instance —
  cover `GET /venues`, `GET /venues/:id/availability`, filter/sort params.
- **E2E tests (fewest, most valuable)**: 2-3 critical user journeys only:
  1. Open app → see venue list → tap venue → see detail → tap "Book" (opens
     external browser to correct URL).
  2. Filter by distance/price → list updates correctly.
  3. Add widget → widget displays data matching app for the same venue.

## 2. Per-feature test considerations

### Availability normalization adapters
- Test each adapter against **recorded fixture data** (a real iCal export
  snapshot, saved as a test fixture) rather than live network calls — keeps
  tests fast, deterministic, and not dependent on partner uptime.
- Edge cases to cover: venue fully booked, venue fully open, partial-day
  closures, public holidays, daylight saving transitions (Sydney
  AEST/AEDT switch dates).

### Widget
- Manual device test matrix (minimum):
  - Pixel (stock Android) — baseline.
  - Samsung (aggressive battery optimization) — tests WorkManager reliability
    under realistic conditions.
- Verify: widget shows "last updated" timestamp so staleness is visible to users
  rather than silently wrong data.
- Test widget behavior when app hasn't been opened in X days (does sync still
  run via background task, or does data go stale until app reopened?) — document
  actual behavior in the UI copy regardless of which.

### Location/distance features
- Test with mocked location (simulator allows fixed coordinates) across a few
  Sydney suburbs to verify distance sorting is correct.
- Test permission-denied state — app should still be usable (fallback to suburb
  search/manual location) per Apple/Google guidelines (R9 in risk register).

### Data accuracy (manual venue data)
- Spot-check a sample of venues against live venue websites before each release
  — not automatable, but a lightweight checklist (rates, hours, court count)
  takes ~2 min per venue.

## 3. CI gates (per PR)

- Lint + typecheck (must pass).
- Unit tests (must pass, coverage tracked but not gated initially — avoid
  coverage-theater early on).
- Integration tests for API changes.
- Build check for mobile app (Expo prebuild/build doesn't need to fully succeed
  on every PR, but should on `main`).

## 4. Pre-release checklist (each phase)

- [ ] Manual data spot-check (per above).
- [ ] Widget tested on both device types in matrix.
- [ ] Privacy policy / store listing reviewed if data collection changed.
- [ ] Sentry shows no new error spikes in staging.
- [ ] Risk register reviewed for the upcoming phase.

## 5. Beta testing

- TestFlight (iOS) and Play Console Internal Testing (Android) from Phase 1.
- Recruit a small group (5-10 people) from local badminton communities/social
  groups — this also doubles as early user feedback for the directory data
  itself (players will notice if a rate is wrong faster than manual spot-checks
  will).
