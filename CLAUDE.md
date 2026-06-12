# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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

## Current status

**No code has been written yet.** All planning documents live in `docs/`. Implementation begins at Phase 1 (see `docs/06-roadmap-and-milestones.md`). Read `docs/00-PROJECT-HANDOFF.md` first — it summarizes what's been done, what decisions are locked, and what still needs owner confirmation before scaffolding.

## Planned monorepo structure

```
badminton-finder/
├── apps/
│   ├── mobile/          # React Native app (Expo managed workflow)
│   └── widget/          # Shared widget logic if separated
├── packages/
│   ├── api-client/      # Typed API client, shared types
│   └── ui/              # Shared design tokens/components
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
| Mobile | React Native, Expo managed workflow |
| Navigation | React Navigation |
| Local storage (widget) | MMKV or `expo-sqlite` |
| Backend API | NestJS (TypeScript) |
| Database | Supabase (Postgres) |
| CMS | Sanity (editorial metadata only; syncs into Postgres on publish) |
| Cache | Redis / Upstash (availability snapshots, short TTL) |
| Sync worker | Supabase Edge Functions (cron) or `node-cron` on Railway/Render |
| Mobile builds | EAS Build (Expo) |
| Error tracking | Sentry (mobile + backend) |
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
- **Android widget cannot poll live**: The widget reads from a locally cached store (MMKV/SQLite) that the app syncs via WorkManager. The `GET /widget/summary` endpoint is optimized for minimal payload since it's fetched by a background task, not interactively.
- **iOS widget requires native Swift** (ADR-004): WidgetKit is unavoidable — it cannot be done in React Native. iOS widget is Phase 4, after Android widget ships in Phase 3.
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

1. **State management**: Architecture doc suggests React Query (TanStack Query) for server state. Owner has deep Redux Toolkit/RTK Query background and wants to confirm this before the data layer is scaffolded. Do not hardcode either choice into early boilerplate.
2. **Branding/design system**: Possibly reusing owner's existing UIForge design system, possibly a fresh design. Focus on functional UI until this is confirmed.
3. **App/package name and bundle ID**: Not yet chosen. Required before finalizing `app.json`/Expo config.
4. **Accounts**: GitHub repo, Supabase project, Expo/EAS account, Google Maps/Places API key — none exist yet. Setting these up is part of Phase 0/1.

## Phase 1 implementation sequence

1. Confirm open decisions above (especially state management — affects data layer structure).
2. Scaffold monorepo, CI skeleton, empty Expo app shell with navigation.
3. Set up Supabase: create `venues`, `rate_cards`, `opening_hours` tables (skip `availability_partnerships`/`availability_snapshots` until Phase 2).
4. Seed database from `docs/venues-seed-data.md`.
5. Build venue list (map view) + detail screens against seeded data.
6. Wire up deep links to venue booking pages.

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

## iCal availability computation note

iCal feeds represent **bookings** (busy blocks), not availability directly. The adapter must compute "courts available" by subtracting booked events from venue capacity per time slot. This requires knowing court count and opening hours per venue, and assumes one iCal event = one court (verify this per venue — some events may block multiple courts).
