# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Issue & Epic workflow (mandatory — enforced before any code)

All work starts from a GitHub Issue. No coding without a linked issue.

### Epic format

```
Title: [EPIC] <feature name>

Body:
## Goal
## Scope
## Success Criteria
## Sub-issues
- [ ] #<n>
```

### Sub-issue format

```
Title: [type] <short task description>

Body:
## Summary
## Acceptance Criteria
## Test Plan
## Parent Epic
Part of #<epic_number>
```

### Workflow (strict order)

When a feature or change is requested:

1. Check if an Epic exists — if not, create one
2. Break work into sub-issues under the Epic
3. Ask which sub-issue to start (or pick smallest unit)
4. Create branch from `dev`: `type/short-description-issue-<n>`
5. Implement ONLY that sub-issue
6. Open PR referencing the issue (`Closes #<n>`)

### Branch naming

```
feature/booking-ui-issue-123
fix/payment-bug-issue-456
```

### PR title

```
type: description (#issue_number)
```

PR body must include `Closes #<issue_number>` and link to parent Epic.

### Hard rules

- NO direct commits to `dev` or `main`
- NO coding without an issue
- NO PR without passing CI
- NO large unscoped changes — break into sub-issues first
- Every sub-issue references its Epic; every PR closes an issue

---

## Git workflow

| Branch | Rule |
|---|---|
| `main` | Production. GitHub Pages serves from here. **Never commit directly.** |
| `dev` | Default working branch. **Never commit directly.** |

**All changes** branch off `dev` using one of these prefixes, then merge back into `dev` via PR:

```
feature/   fix/   chore/   docs/   refactor/   test/   style/   perf/
```

**Hotfixes** (`hotfix/`) branch off `main` and must merge into **both** `main` and `dev`.

**Releases** (`release/vX.Y.Z`) branch off `dev` and merge into `main` via PR.

### Commit discipline (required on every branch)

Commit after each logical unit of work — not just at the end of a session. Each commit must:

- **Be atomic** — one concern per commit. Don't bundle a DB migration with a UI change.
- **Use conventional commit format**: `type(scope): description`
  - `feat(api): add GET /venues endpoint`
  - `chore(monorepo): init Turborepo with npm workspaces`
  - `fix(mobile): correct distance filter haversine calculation`
  - `docs(adr): add ADR-0008 NestJS API from day one`
- **Have a meaningful message** — describe *what changed and why*, not just "update files" or "WIP".
- **Pass at minimum**: no TypeScript errors, no lint errors. Don't commit broken state.

Commit cadence examples:
- Scaffold a new service → one commit per service (`chore(api): scaffold NestJS service`, `chore(mobile): init Expo app shell`)
- Add an endpoint → one commit per endpoint + one for its tests
- Update a doc or ADR → one commit per doc

Never batch unrelated changes. Never commit with message "misc" or "wip" to a shared branch.

### PR process (required for every merge)

When opening a PR, always populate:
- **Title** — conventional commit format: `type: short description` (e.g. `feat: venue list screen`)
- **Body** — `## Summary` (bullet points), `## Test plan` (checklist)
- **Labels** — at least one of: `feature`, `fix`, `chore`, `docs`, `refactor`, `test`, `style`, `perf`
- **Assignee** — always assign to `rajanmali`

After opening the PR, immediately:
1. Poll CI status with `gh pr checks <number> --watch` until all checks complete.
2. If all checks pass → merge automatically with `gh pr merge <number> --squash --delete-branch`.
3. If any check fails → report the failure, do not merge.

For orchestrated multi-agent work, the orchestrator reviews the PR diff against the spec before merging (review-then-merge replaces auto-merge; solo/direct work keeps auto-merge on green). See `docs/agents/orchestration.md`.

For hotfixes only: after merging into `main`, open a second PR from the same `hotfix/` branch into `dev` and repeat the process.

### Release process

Versioning follows **semver**: `MAJOR.MINOR.PATCH`
- `PATCH` — bug fixes only
- `MINOR` — new backwards-compatible features
- `MAJOR` — breaking changes

Steps to cut a release:

1. **Branch** — create `release/vX.Y.Z` off `dev`.
2. **Prep commit** — bump any version references (e.g. `app.json`, `package.json`) and update `CHANGELOG.md` if maintained. Commit as `chore: bump version to vX.Y.Z`.
3. **PR to `main`** — open with label `release`, assignee `rajanmali`. Follow the standard PR process (CI must pass before merge). Use squash merge.
4. **Tag and publish** — after the PR merges into `main`, run:
   ```bash
   gh release create vX.Y.Z --target main --title "vX.Y.Z" --generate-notes
   ```
   GitHub will auto-categorise the release notes from PR labels using `.github/release.yml`.
5. **Sync back to `dev`** — open a PR from `main` → `dev` (title: `chore: sync vX.Y.Z release back to dev`), label `chore`, and merge it. This keeps `dev` aware of the exact release commit.

The `release` label must exist on GitHub (create with `gh label create release --color 0052cc --description "Release"` if missing).

## Current status

The **native iOS Phase 1 app (Swift/SwiftUI) is implemented on `dev`**: venue list, map, detail, filters, and deep links against the NestJS API/Supabase. The React Native/Expo app and shared mobile packages have been removed (ADR-0010). Planning documents remain in `docs/`. Read `docs/00-PROJECT-HANDOFF.md` first — it summarizes what's been done, what decisions are locked, and what's next (Phase 2: live availability).

## Monorepo structure

```
badminton-finder/
├── apps/
│   └── ios/             # Native iOS app (Swift/SwiftUI, XcodeGen)
├── services/
│   ├── api/             # Backend API (NestJS/TypeScript)
│   └── sync-worker/     # Availability polling/sync jobs
├── docs/                # ADRs, RFCs, planning docs
└── .github/workflows/   # CI: lint, typecheck, test, build check on every PR
```

Conventional commits (`feat:`, `fix:`, `chore:`, etc.) on all branches.

## Tech stack

| Layer | Technology |
|---|---|
| Mobile | Native iOS (Swift/SwiftUI, XcodeGen) — see ADR-0010 |
| Maps | MapLibre Native iOS SDK + Maptiler tiles (OSM data) — see ADR-0009 |
| Backend API | NestJS (TypeScript) |
| Database | Supabase (Postgres) |
| CMS | Sanity (editorial metadata only; syncs into Postgres on publish) |
| Cache | Redis / Upstash (availability snapshots, short TTL) |
| Sync worker | Supabase Edge Functions (cron) or `node-cron` on Railway/Render |
| Mobile builds | Xcode / TestFlight (EAS decommissioned) |
| Error tracking | Sentry (sentry-cocoa on iOS; backend) |
| Analytics | PostHog |

## Architecture: the normalization adapter pattern (ADR-003)

This is the central architectural decision. All venue availability data (from iCal feeds, Skedda, webhooks, etc.) passes through a per-platform adapter implementing a common interface before hitting the database:

```ts
interface AvailabilityAdapter {
  platform: VenuePlatform;
  fetchAvailability(partnership: AvailabilityPartnership): Promise<NormalizedSlot[]>;
}
```

The normalized output lands in a single `availability_snapshots` table. The mobile app, widget, and API **never need platform-specific knowledge** — they only read from this normalized table. Adding a new venue platform = writing one adapter, no other changes.

## Key architectural constraints

- **No scraping** (ADR-002): Live availability comes only from explicit venue partnerships (iCal feeds, webhooks). Sport Logic/intennis-style platforms block robots.txt. This is a firm decision — do not revisit without a strong reason.
- **Android deferred** (ADR-0010): Android development begins only after the iOS app shows traction. The Phase 3 Android widget is deferred accordingly.
- **iOS widget requires native Swift** (ADR-004): WidgetKit is unavoidable. iOS widget is Phase 4 — a natural extension of the `apps/ios` Swift codebase via a shared app group container.
- **All times stored UTC**, converted to `Australia/Sydney` at the API/app layer. Daylight saving transitions need test coverage.
- **Prices stored as cents** (integers), not floats.

## Data model summary

Five tables in Supabase Postgres (full schema in `docs/02-technical-design-doc.md`):
- `venues` — location, court count, platform enum, booking URL
- `rate_cards` — FK to venues, peak/off-peak rates in cents, day/time ranges
- `opening_hours` — FK to venues, per-day open/close times
- `availability_partnerships` — Phase 2+; feed type, URL, sync frequency, status
- `availability_snapshots` — Phase 2+; the normalized output all consumers read from; rows pruned after slot time passes

## API surface (planned, base path `/api/v1`)

- `GET /venues` — list with filters (`lat`, `lng`, `radius_km`, `dedicated_only`, `max_price`, `sort`)
- `GET /venues/:id` — full detail including rates, hours, booking URL, partnership status
- `GET /venues/:id/availability?date=` — returns `slots: []` + `liveAvailability: false` when no partnership exists
- `GET /widget/summary` — compact payload for background widget sync

## Open decisions — confirm with owner before implementing

1. ~~**State management**~~ — **Resolved:** Swift URLSession client with retry-2 logic; SwiftUI `NavigationStack` model lifetime for list state. No React Query equivalent. See ADR-0007/ADR-0010.
2. ~~**Branding/design system**~~ — **Resolved:** fresh design system for Smash; tokens live in `apps/ios/Smash/DesignSystem/Tokens.swift`. Owner to supply expanded tokens/components as needed.
3. ~~**App/package name and bundle ID**~~ — **Resolved: "Smash", bundle ID `com.rajanmali.smash`.**
4. ~~**Accounts**~~ — **Resolved:** Supabase project `sqqymvrqnkypofqlrnjw` active and wired; Maptiler account active and wired (ADR-0009). **Expo/EAS decommissioned.** Google Maps/Places not used — MapLibre/Maptiler per ADR-0009. Apple Developer account active (Xcode/TestFlight). Google Play Console confirmed but inactive until Android work begins.

## Phase 1 — done

Phase 1 (static directory) is implemented: native iOS app (Swift/SwiftUI) with venue list, map, detail, filters, and deep links against the NestJS API/Supabase. Next is Phase 2 (live availability). See `docs/06-roadmap-and-milestones.md`.

Venue outreach (sending emails in `docs/venue-outreach-plan.md`) runs in parallel and has zero dependency on any of the above.

## Testing approach

- **Unit tests** (Jest): especially the normalization adapters — this is where bugs from format differences will surface most.
- **Integration tests**: API endpoints against a real test database (Supabase local dev or Dockerized Postgres). Do not mock the database.
- **E2E** (Detox or Maestro): 2-3 critical paths only (search → venue detail → deep link to booking page).
- **Widget testing**: manual device testing required; WorkManager timing varies by OEM (Samsung vs. Pixel battery optimization).

## Agent skills

### Issue tracker

Issues live in GitHub Issues (`github.com/rajanmali/badminton-court-finder`). See `docs/agents/issue-tracker.md`.

### Triage labels

Default label vocabulary (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context repo. Read `CONTEXT.md` at the root and `docs/adr/` before working in any area. See `docs/agents/domain.md`.

### Agent orchestration

Multi-agent work (orchestrator + per-PR implementation subagents) follows the loop in `docs/agents/orchestration.md`.

## iCal availability computation note

iCal feeds represent **bookings** (busy blocks), not availability directly. The adapter must compute "courts available" by subtracting booked events from venue capacity per time slot. This requires knowing court count and opening hours per venue, and assumes one iCal event = one court (verify this per venue — some events may block multiple courts).
