# Project Handoff: Badminton Court Finder (Sydney)

**Status as of:** 12 June 2026
**Stage:** Planning complete. No code written yet. This document is the entry
point for picking up implementation work.

## 1. What this project is

A cross-platform mobile app (React Native/Expo, targeting Android + iOS, with
home screen widget support) that helps Sydney badminton players find venues,
compare rates/hours, and — where partnerships allow — see live court
availability, with deep links to each venue's own booking page. No in-app
booking/payments in v1.

Read `01-PRD.md` first for full scope, goals, and non-goals.

## 2. What's been done so far (all in planning — nothing built)

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

## 3. Key decisions already made (don't re-litigate without reason)

- **No scraping** of venue booking platforms — ADR-002. Live availability is
  partnership-gated only.
- **Monorepo**, trunk-based development, RN/Expo — ADR-001, ADR-006.
- **Normalization adapter pattern** for availability data — ADR-003. Critical:
  the API/app/widget must never need platform-specific knowledge.
- **Android widget first**, iOS WidgetKit (native Swift) deferred to its own
  phase — ADR-004.
- **Supabase (Postgres) + Sanity CMS** as data stores — ADR-005.

## 4. Open decisions (NOT yet made — flag to project owner before assuming)

- ~~**State management**~~ — **Resolved: React Query (TanStack Query).** See ADR-0007.
- ~~**Branding/design direction**~~ — **Resolved: fresh design system for Smash.** Owner will supply design tokens after initial scaffolding. `packages/ui` starts minimal.
- ~~**App name, package name / bundle ID**~~ — **Resolved: "Smash", bundle ID `com.rajanmali.smash`.**
- **Accounts**: GitHub repo, Supabase project, Expo/EAS account, Google
  Maps/Places API key — none of these exist yet. Setting these up is part of
  Phase 0/1 (see roadmap), not assumed to be pre-existing.

## 5. Suggested first steps for implementation

Per `06-roadmap-and-milestones.md`, Phase 1 (static directory) is the starting
point:

1. Confirm the open decisions in section 4 above with the project owner before
   scaffolding (state management especially affects the data layer structure).
2. Scaffold monorepo per structure in `engineering-approach-and-architecture.md`
   section 3.
3. Set up Supabase project, create schema per `02-technical-design-doc.md`
   section 2 (`venues`, `rate_cards`, `opening_hours` tables — skip
   `availability_partnerships`/`availability_snapshots` until Phase 2).
4. Seed database using `venues-seed-data.md`.
5. Build venue list (map) + detail screens in Expo app against seeded data.
6. Set up basic CI (lint, typecheck, test) per ADR-006.

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
