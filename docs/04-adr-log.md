# Architecture Decision Records (ADR Log)

Short-form ADRs — context, decision, consequences. New ADRs get appended, never
edited retroactively (if a decision changes, write a new ADR that supersedes it).

---

## ADR-001: React Native (Expo) over native iOS/Android

**Context:** Need cross-platform mobile app with home screen widget support;
team has strong React/TypeScript background, limited native iOS/Android
experience.

**Decision:** Use React Native with Expo managed workflow.

**Consequences:** Faster iteration and shared codebase for ~90% of the app.
Android widget achievable via `react-native-android-widget`. iOS widget requires
a native Swift extension regardless (WidgetKit constraint, not an RN limitation) —
scoped as a separate task (see ADR-004).

---

## ADR-002: No live scraping of venue booking platforms

**Context:** Several venue booking platforms (Sport Logic/intennis-style) block
robots.txt; Skedda has no public read API.

**Decision:** Do not scrape. Live availability is only sourced via explicit
venue partnerships (iCal feeds or similar opt-in mechanisms).

**Consequences:** Live availability rollout is slower and partnership-dependent.
In exchange: no ToS violations, no fragile scrapers breaking on site updates, and
better long-term relationships with venues (who are also potential future
partners for referral/booking integrations).

---

## ADR-003: Normalization layer (adapter pattern) for availability data

**Context:** Venue availability data will arrive in at least 4-5 different
shapes depending on platform (iCal, custom JSON, etc.), and partnerships will be
onboarded incrementally over time.

**Decision:** All availability data passes through a per-platform adapter
implementing a common `AvailabilityAdapter` interface, producing a single
normalized `availability_snapshots` table that the API/app/widget consume.

**Consequences:** Adding a new venue/platform = writing one adapter, with no
changes needed to API, app, or widget. Slightly more upfront design work for the
interface, but pays off after the 2nd or 3rd partnership.

---

## ADR-004: iOS widget deferred to its own phase

**Context:** iOS WidgetKit requires a native Swift extension target; this is true
regardless of RN vs. native and can't be avoided with any cross-platform tooling.

**Decision:** Ship Android widget first (Phase 3). iOS widget is Phase 4, treated
as a small standalone native sub-project with its own scoped timeline.

**Consequences:** Android users get the widget experience sooner. iOS app users
get full app functionality from Phase 1 — only the widget is delayed, not the
app itself.

---

## ADR-005: Supabase (Postgres) + Sanity CMS as primary data stores

**Context:** Need a relational database for venues/availability, plus a
content-management layer for editorial metadata (descriptions, photos) that
non-engineers might eventually update.

**Decision:** Supabase Postgres for transactional/structured data (venues, rates,
availability snapshots, partnerships). Sanity CMS for editorial content, synced
into Postgres on publish.

**Consequences:** Matches existing familiarity (faster development). Two systems
to keep in sync — mitigated by Sanity being the source of truth only for
rarely-changing editorial fields, not for availability data (which never touches
Sanity).

---

## ADR-006: Monorepo with trunk-based development

**Context:** Small team/solo developer, multiple deployable units (mobile app,
API, sync worker, shared packages).

**Decision:** Single monorepo (`apps/`, `services/`, `packages/`), trunk-based
development with short-lived feature branches and required CI checks before
merge to `main`.

**Consequences:** Simpler dependency management between shared types/clients and
consumers. Requires CI to be fast enough not to bottleneck (keep test suites
scoped per workspace).
