# Badminton Court Finder — Sydney

A cross-platform mobile app (React Native/Expo) that helps Sydney badminton players find venues, compare rates and hours, and — where venue partnerships allow — see live court availability with deep links to each venue's own booking page.

**Current status: planning complete, implementation not yet started.**

---

## What this app does

- Browse all Sydney badminton venues with rates, opening hours, court count, and amenities
- Filter by distance, price range, and venue type (dedicated badminton vs. multi-sport)
- Tap through to each venue's booking page (no in-app payments)
- For partnered venues: live/near-live court availability ("3 courts free 6–7pm")
- Home screen widget (Android first, iOS later) showing availability without opening the app

## Tech stack

| Layer | Technology |
|---|---|
| Mobile | React Native, Expo (managed workflow) |
| Backend API | NestJS (TypeScript) |
| Database | Supabase (PostgreSQL) |
| CMS | Sanity (editorial venue metadata) |
| Cache | Redis / Upstash |
| Sync worker | Scheduled job (Supabase Edge Functions or node-cron) |
| Mobile builds | EAS Build |

## Repository structure

```
apps/mobile/          # React Native app (Expo)
packages/api-client/  # Typed API client + shared types
packages/ui/          # Shared design tokens/components
services/api/         # NestJS backend API
services/sync-worker/ # Availability polling and normalization
docs/                 # All planning documents (start here)
.github/workflows/    # CI: lint, typecheck, tests, build check
```

## Getting started

This repo is at the start of Phase 1 implementation. Read these docs in order:

1. [`docs/00-PROJECT-HANDOFF.md`](docs/00-PROJECT-HANDOFF.md) — entry point; what's done, what's decided, what needs confirming
2. [`docs/01-PRD.md`](docs/01-PRD.md) — product requirements and scope
3. [`docs/02-technical-design-doc.md`](docs/02-technical-design-doc.md) — data model and API spec
4. [`docs/04-adr-log.md`](docs/04-adr-log.md) — architecture decisions and rationale
5. [`docs/06-roadmap-and-milestones.md`](docs/06-roadmap-and-milestones.md) — phased plan

## Key decisions (don't re-litigate without reading the ADRs)

- **No scraping** — live availability only via explicit venue partnerships (ADR-002)
- **Normalization adapter pattern** — all availability data normalized to a single shape before the API/app ever sees it (ADR-003)
- **Monorepo, trunk-based development** (ADR-006)
- **Android widget first**, iOS WidgetKit deferred (ADR-004)
- **Supabase + Sanity** as data stores (ADR-005)

## Open decisions (confirm with owner before implementing)

- State management: React Query vs. RTK Query
- Branding/design system
- App name and bundle ID
- External accounts (GitHub, Supabase project, Expo/EAS, Google Maps API)

See [`docs/00-PROJECT-HANDOFF.md`](docs/00-PROJECT-HANDOFF.md) section 4 for full context.
