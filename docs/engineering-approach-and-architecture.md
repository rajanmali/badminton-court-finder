# Badminton Court Finder — Engineering Approach & Architecture Plan

How I'd run this if I were leading a small team (PM/lead, 1-2 mobile engineers,
1-2 backend engineers, 1 designer, 1 QA) at a company like Meta/Apple/Google scale
of process — scaled down sensibly for a project this size. Nothing here requires
a 10-person team forever; it's the *shape* of how a senior team would approach it,
so decisions are made deliberately rather than accumulating as ad-hoc choices.

## 1. Before any code: discovery & alignment (Week 0)

- **Write a one-page project brief**: problem statement, target users (Sydney
  badminton players), success metrics (e.g. "X venues listed, Y% with live
  availability, app installed by Z users in first 3 months"). This is the
  document everything else gets checked against.
- **Define MVP scope explicitly** — and just as importantly, write down what's
  *out of scope* for v1 (e.g. no in-app booking/payments, no user accounts
  initially, no iOS widget in phase 1 if Android-first is faster).
- **Risk log** — the data-access constraints we already found (robots.txt blocks,
  no public APIs, 5+ booking platforms) go here as the #1 risk, with the
  partnership plan as the mitigation. A senior team surfaces this risk on day one
  rather than discovering it mid-build.
- **Design phase kicks off in parallel**: designer produces low-fi wireframes for
  the core flows (venue list, venue detail, map, widget) while engineering does
  technical design — design and architecture should inform each other, not be
  sequential.
- **Technical design doc (RFC)**: 1-2 pages covering architecture below, circulated
  for review before any repo is created. The point isn't bureaucracy — it's that
  a 30-minute review now saves weeks of rework later (e.g. "wait, the widget can't
  call this API directly every 15 minutes").

## 2. Team structure & roles (even if it's just you + Claude initially)

| Role | Responsibility |
|---|---|
| Product/Lead | Scope, prioritization, venue partnership outreach |
| Mobile Eng (RN) | App UI, navigation, state management, widget integration |
| Backend Eng | API, database, availability-sync service, auth |
| Designer | Wireframes → UI kit → widget design (constrained canvas) |
| QA | Test plans, device matrix, manual + automated testing |

If it's just you, these are still useful as **hats you switch between
deliberately** — e.g. don't design the database schema while also designing the
UI in the same sitting; context-switching between "modes" is where mistakes creep in.

## 3. Repo & version control strategy

**Monorepo** (recommended for a solo/small team — easier than juggling cross-repo
PRs):

```
badminton-finder/
├── apps/
│   ├── mobile/          # React Native app (Expo)
│   └── widget/           # Shared widget logic if separated
├── packages/
│   ├── api-client/       # Typed API client, shared types
│   └── ui/                # Shared design tokens/components
├── services/
│   ├── api/              # Backend API (NestJS or similar)
│   └── sync-worker/      # Availability polling/sync jobs
├── docs/                  # ADRs, RFCs, this spec
└── .github/workflows/     # CI/CD
```

- **Branching**: trunk-based with short-lived feature branches (`feat/venue-list`,
  `fix/widget-refresh`), PR review required before merge to `main`. Avoid GitFlow's
  long-lived `develop` branch — overkill for this scale and creates merge debt.
- **Conventional commits** (`feat:`, `fix:`, `chore:`) — makes changelog generation
  and release notes near-automatic.
- **CI on every PR**: lint, typecheck, unit tests, build check. Nothing merges to
  `main` red.
- **ADRs (Architecture Decision Records)**: short markdown files in `docs/adr/`
  for significant decisions ("why Supabase over Firebase", "why polling over
  webhooks for venue X"). Future-you (or a future hire) will thank present-you.

## 4. Architecture overview

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  React Native    │────▶│   Backend API     │────▶│   PostgreSQL     │
│  App (iOS/Android)│     │  (NestJS/TS)      │     │   (Supabase)     │
│  + Home Widgets   │◀────│  REST/GraphQL     │◀────│   + Redis cache  │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                                  ▲
                                  │
                         ┌──────────────────┐
                         │  Sync Worker       │
                         │  (cron / queue)    │
                         │  - iCal feed pulls │
                         │  - Skedda, etc.    │
                         └──────────────────┘
                                  ▲
                                  │
                         ┌──────────────────┐
                         │  Venue data feeds  │
                         │  (per partnership) │
                         └──────────────────┘

CMS (Sanity) ──▶ Venue metadata (rates, hours, descriptions, photos)
                   feeds into PostgreSQL via webhook/sync on publish
```

### Mobile app (React Native)
- **Framework**: Expo (managed workflow) — faster iteration, OTA updates, and
  Expo's config plugins handle a lot of native setup. Drop to bare workflow only
  if a widget library needs it.
- **State/data**: React Query (TanStack Query) for server state + caching —
  better fit than Redux/RTK Query here since most data is server-driven and
  cache-invalidation-heavy (availability changes frequently). Redux Toolkit still
  fine for local UI state if preferred, given your familiarity with it.
- **Navigation**: React Navigation.
- **Offline/widget data**: a small local store (e.g. MMKV or SQLite via
  `expo-sqlite`) that the widget reads from directly — widgets can't make network
  calls on their own refresh cycle, so the app syncs data to this local store
  periodically, and the widget renders from it.
- **Widgets**:
  - Android: `react-native-android-widget` (renders RN components to native
    widget views via a background task + WorkManager-driven refresh).
  - iOS: WidgetKit requires a native Swift extension target — this is the one
    place "not fully RN" is unavoidable. Budget this as a separate, smaller
    native mini-project once the core app is stable. Don't block v1 on it;
    Android widget can ship first.

### Backend API
- **NestJS (TypeScript)** — structured, modular, good fit if you ever add a team;
  or a lighter Fastify/Express setup if you want to move faster solo. Given your
  Node/TS background, NestJS's structure (modules/controllers/services) will feel
  familiar from React component organization.
- **Endpoints**: venues (list/detail), availability (per venue, normalized format
  regardless of source platform), search/filter.
- **Normalization layer**: this is the most important architectural piece — every
  venue's availability data (from iCal feeds, Skedda, etc.) gets transformed into
  one common `AvailabilitySnapshot` shape before hitting the database. This means
  the mobile app and widget never need to know which platform a venue uses.

### Database & cache
- **PostgreSQL via Supabase** — matches your existing toolkit (you're already
  using Supabase for other projects), gives you auth, storage, and realtime if
  needed later for free.
- **Redis** (or Supabase's built-in caching/Upstash) for availability snapshots —
  short TTL cache since this data changes frequently and widgets need fast reads.
- **Sanity CMS** for venue metadata that changes rarely (descriptions, photos,
  amenities, rate cards) — content team (or you) edits here, syncs to Postgres.

### Sync worker
- Separate small service (could even be a Supabase Edge Function on a schedule,
  or a lightweight Node service on Railway/Render) that:
  - Polls each venue's iCal/feed on a schedule appropriate to that source.
  - Normalizes into `AvailabilitySnapshot` records.
  - Writes to Postgres/Redis.
- Keeping this separate from the API means a slow/broken feed from one venue
  can't take down the main API.

### Cloud/hosting recommendations
- **Supabase**: Postgres + Auth + Storage + Edge Functions (generous free tier,
  matches existing familiarity).
- **API hosting**: Railway or Render for the NestJS API + sync worker (simple,
  predictable pricing, good DX) — or Supabase Edge Functions if you want to avoid
  managing a server entirely.
- **Mobile builds**: EAS Build (Expo) for iOS/Android builds and OTA updates.
- **Monitoring**: Sentry (errors, both mobile and backend) — free tier is enough
  at this stage.
- **Analytics**: PostHog (self-hostable or cloud free tier) for usage analytics —
  useful for seeing which venues/features get used, which informs the venue
  partnership priority list.

## 5. Testing strategy

- **Unit tests**: Jest for both RN app and backend logic — especially the
  normalization layer (this is where bugs from format differences will surface).
- **Integration tests**: API endpoints against a test database (Supabase local
  dev or Dockerized Postgres).
- **E2E**: Detox or Maestro for critical mobile flows (search → venue detail →
  deep link to booking) — start with just 2-3 critical paths, not full coverage.
- **Widget testing**: manual device testing is unavoidable here — widget refresh
  behavior varies by OEM (Samsung vs. Pixel battery optimization can affect
  WorkManager timing). Keep a small device test matrix.
- **QA**: a simple beta channel via TestFlight (iOS) and Play Internal Testing
  (Android) — get the app on your own phone + a couple of friends' phones early.

## 6. Things beyond "just the app" this project will need

- **App store accounts**: Apple Developer ($99/yr) and Google Play Console ($25
  one-time) — set these up early since verification can take time.
- **Privacy policy & basic ToS** for the app — required by both stores, and
  relevant since you're aggregating third-party business data and possibly user
  location.
- **Branding**: name, logo, app icon, widget icon — small but blocks store
  submission if left to the end.
- **Legal review of venue partnerships**: even informal, get partnership terms
  (what data is shared, how it's used, that you're not processing payments) in
  writing via email — protects both you and the venue.
- **Budget**: mostly free-tier friendly (Supabase, Sentry, PostHog free tiers,
  Railway/Render hobby tier), but EAS Build and Apple Developer have real costs —
  worth listing out total expected monthly spend before committing.
- **Roadmap/backlog tool**: even a GitHub Projects board is enough — the point is
  having a single place where "venue partnership status" and "feature backlog"
  are both visible, since they're interdependent.

## 7. Suggested first sprint (post-planning)

1. Set up monorepo, CI, and base Expo app shell (empty screens, navigation).
2. Set up Supabase project + schema for `Venue` and `AvailabilitySnapshot`.
3. Seed database with the venue directory data already collected.
4. Build venue list + detail screens against seeded data (no live availability
   yet) — this gets something tappable on a phone fast, which is motivating and
   surfaces UI/UX issues early.
5. Send venue outreach emails (Step 1 from earlier) in parallel — partnerships
   take time to land, so start the clock now even while building the static app.
