# Project Handoff: Smash — Sydney Badminton Finder

**Status as of:** 14 June 2026
**Stage:** Native iOS Phase 1 app implemented on `dev`. This document is the
entry point for picking up Phase 2 work.

## 1. What this project is

A native iOS app (Swift/SwiftUI, iOS-first) that helps Sydney badminton players
find venues, compare rates/hours, and — where partnerships allow — see live
court availability, with deep links to each venue's own booking page. No in-app
booking/payments in v1.

Android is deferred until the product shows traction; if built later it will be
a separate native app, not a shared codebase.

Read `01-PRD.md` first for full scope, goals, and non-goals.

## 2. What's been done so far

- **Feasibility research**: surveyed the Sydney badminton venue landscape,
  identified ~5 different booking platforms in use (Sport Logic/intennis-style,
  Skedda, Pitchbooking, yepbooking, council systems), and tested scraping
  feasibility. Key finding: the largest cluster of dedicated venues blocks
  robots.txt — live availability must come via venue partnerships (iCal feeds
  etc.), not scraping. See `badminton-court-finder-spec.md`,
  `badminton-venue-data-findings.md`, `availability-access-options.md`.
- **Engineering plan**: full architecture, data model, API spec, ADRs, risk
  register, test plan, and phased roadmap written. See
  `engineering-approach-and-architecture.md`, `02-technical-design-doc.md`,
  `03-risk-register.md`, `04-adr-log.md`, `05-test-plan.md`,
  `06-roadmap-and-milestones.md`.
- **Venue outreach**: compiled contact details for 16 Sydney venues
  (`venue-contact-list.md`) and drafted partnership outreach emails for 15 of
  them (saved as Gmail drafts, not yet sent — pending the project owner's review).
  One venue (Concord Oval Recreation Centre) still needs a contact method
  confirmed.
- **Venue data collected**: rates, hours, court counts gathered for several
  venues (see `venues-seed-data.md` — this is the data to seed the database
  with in Phase 1).
- **Phase 1 natively implemented**: venue list, map view with pins, venue detail
  screen, filters (distance/price/dedicated), and deep links to booking pages —
  all consuming the NestJS API (`services/api`) backed by Supabase. The React
  Native/Expo app (`apps/mobile`) and the shared packages (`packages/api-client`,
  `packages/ui`) were removed after native parity was reached (ADR-0010). Design
  tokens now live in `apps/ios/Smash/DesignSystem/Tokens.swift`.

## 3. Key decisions already made (don't re-litigate without reason)

- **No scraping** of venue booking platforms — ADR-002. Live availability is
  partnership-gated only.
- **Monorepo**, trunk-based development — ADR-006.
- **Native iOS rewrite (Swift/SwiftUI)** — ADR-0010, supersedes ADR-0001
  (RN/Expo). Android is deferred until traction.
- **Normalization adapter pattern** for availability data — ADR-003. Critical:
  the API/app/widget must never need platform-specific knowledge.
- **iOS WidgetKit extension (Phase 4)** — extends the native Swift codebase.
  Android widget deferred (ADR-004). The Android-widget-first ordering no longer
  applies.
- **Supabase (Postgres) + Sanity CMS** as data stores — ADR-005.
- **MapLibre Native iOS + Maptiler** for maps — Google Maps not used (ADR-0009).

## 4. Accounts and services

- **Supabase**: project `sqqymvrqnkypofqlrnjw` — active, wired to the API.
- **Maptiler**: account active, API key wired into `apps/ios` via
  `Config/Secrets.xcconfig` (gitignored).
- **Expo/EAS**: **decommissioned** — no longer used.
- **Google Maps/Places**: **not used** — MapLibre/Maptiler per ADR-0009.
- **Apple Developer account**: confirmed active; builds via Xcode / TestFlight.
- **Google Play Console**: confirmed; not active until Android work begins.

## 5. What's next (Phase 2)

Phase 1 (static directory) is done. The next milestone is Phase 2: live
availability for 2–3 partnered venues.

1. Finalise at least one venue partnership (iCal feed or webhook).
2. Create `availability_partnerships` and `availability_snapshots` tables in
   Supabase (schema in `02-technical-design-doc.md`).
3. Build the first availability adapter end-to-end.
4. Wire up the sync worker and `GET /venues/:id/availability` endpoint.
5. Update the iOS app to show the availability indicator for partnered venues.

Outreach is in progress in parallel and shouldn't block other work.

## 6. Important constraints to keep in mind throughout

- This is a solo-developer project (owner switches between PM/eng/design
  "hats") — avoid over-engineering for a team that doesn't exist yet.
- Venue data is partial — some venues in the seed data have incomplete rates.
  Launching with a smaller, fully-verified "launch set" is fine and preferred
  over waiting for 100% completeness (see PRD section 8).
- Partnership outreach is in progress in parallel and shouldn't block
  Phase 1 — Phase 1 has zero dependency on any venue responding.

## 7. Document index (all in `docs/`)

| Doc | Purpose |
|---|---|
| `01-PRD.md` | Product requirements, scope, success metrics |
| `02-technical-design-doc.md` | Data model, API spec, normalization design |
| `03-risk-register.md` | Known risks + mitigations |
| `04-adr-log.md` | Architecture decisions + rationale |
| `05-test-plan.md` | QA/testing strategy |
| `06-roadmap-and-milestones.md` | Phased plan with demoable milestones |
| `engineering-approach-and-architecture.md` | Full architecture/stack writeup |
| `badminton-court-finder-spec.md` | Original feasibility plan |
| `badminton-venue-data-findings.md` | Platform/rate research findings |
| `availability-access-options.md` | Why no scraping; partnership rationale |
| `venue-outreach-plan.md` | Outreach email template + pilot strategy |
| `venue-contact-list.md` | All venue contacts (for reference, not for code) |
| `venues-seed-data.md` | Structured venue data for Phase 1 DB seeding |
