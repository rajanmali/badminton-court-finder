# Smash — Sydney Badminton Finder

A native iOS app (Swift/SwiftUI) that helps Sydney badminton players find venues, compare rates and hours, and — where venue partnerships allow — see live court availability with deep links to each venue's own booking page. The UI is a glass-forward design (iOS Materials) on a BWF-court-inspired palette, with light/dark mode and a reduced-transparency fallback.

**Current status: native iOS Phase 1 (static directory) implemented on `dev`, with the glass redesign and a UX polish pass landed. Live availability (Phase 2) and Android are future work.**

---

## What this app does

- First-run onboarding captures default preferences (location, filters, sort), persisted locally
- Browse all Sydney badminton venues (List or Map tab) with rates, opening hours, court count, and amenities
- Filter (distance, price, dedicated-only) and sort (Nearest / Price / Most courts / A–Z) via a shared Filters sheet
- Save favourite venues (star) — a dedicated **Saved** tab lists them
- Location-aware: nearest-first when location is granted; a coherent degraded experience (no distance, Price sort) when denied
- Tap through to each venue's booking page (no in-app payments)
- For partnered venues: live/near-live court availability ("3 courts free 6–7pm") — Phase 2
- Home screen widget — iOS-first (Phase 4, native WidgetKit extension); Android deferred until product shows traction

## Tech stack

| Layer | Technology |
|---|---|
| Mobile | Native iOS (Swift/SwiftUI, XcodeGen) |
| Maps | MapLibre Native iOS SDK + Maptiler tiles (OSM data) |
| Backend API | NestJS (TypeScript) |
| Database | Supabase (PostgreSQL) |
| CMS | Sanity (editorial venue metadata) |
| Cache | Redis / Upstash |
| Sync worker | Scheduled job (Supabase Edge Functions or node-cron) |
| Mobile builds | Xcode / TestFlight |

## Repository structure

```
apps/ios/             # Native iOS app (Swift/SwiftUI, XcodeGen)
services/api/         # NestJS backend API
services/sync-worker/ # Availability polling and normalization
docs/                 # All planning documents (start here)
.github/workflows/    # CI: lint, typecheck, tests, build check
```

## Getting started

### Native iOS app

Prerequisites: **Xcode 26+** and `xcodegen` (`brew install xcodegen`).

```bash
cd apps/ios
cp Config/Secrets.example.xcconfig Config/Secrets.xcconfig
# Fill in MAPTILER_API_KEY and API_BASE_URL in Secrets.xcconfig
xcodegen generate
open Smash.xcodeproj
```

Build and run the `Smash` scheme on a simulator or device from Xcode.

### Read the docs first

1. [`docs/00-PROJECT-HANDOFF.md`](docs/00-PROJECT-HANDOFF.md) — entry point; what's done, what's decided, what's next
2. [`docs/01-PRD.md`](docs/01-PRD.md) — product requirements and scope
3. [`docs/02-technical-design-doc.md`](docs/02-technical-design-doc.md) — data model and API spec
4. [`docs/04-adr-log.md`](docs/04-adr-log.md) — architecture decisions and rationale
5. [`docs/06-roadmap-and-milestones.md`](docs/06-roadmap-and-milestones.md) — phased plan

## Key decisions (don't re-litigate without reading the ADRs)

- **Native iOS rewrite** — ADR-0010 (supersedes ADR-0001); Android deferred until traction
- **No scraping** — live availability only via explicit venue partnerships (ADR-002)
- **Normalization adapter pattern** — all availability data normalized to a single shape before the API/app ever sees it (ADR-003)
- **Monorepo, trunk-based development** (ADR-006)
- **iOS widget (Phase 4)** via native WidgetKit — extends the Swift codebase; Android widget deferred (ADR-004)
- **Supabase + Sanity** as data stores (ADR-005)
- **MapLibre Native iOS + Maptiler** for maps — Google Maps not used (ADR-0009)

## Open decisions

- **Accounts**: Supabase project (`sqqymvrqnkypofqlrnjw`) and Maptiler are active and wired. **Expo/EAS decommissioned.** Google Maps/Places not used (MapLibre/Maptiler, ADR-0009). Apple Developer account and Google Play Console confirmed; Google Play deferred until Android work begins.
- **Design system**: the glass design system (tokens, materials, motifs, atoms) lives in `apps/ios/Smash/DesignSystem/` — `Tokens.swift` (BWF-court palette, type scale), `Glass.swift` (material levels + reduced-transparency fallback), `Motifs.swift`, `Components.swift`. User preferences/favourites persist via `apps/ios/Smash/Core/Preferences/AppPreferences.swift`.

See [`docs/00-PROJECT-HANDOFF.md`](docs/00-PROJECT-HANDOFF.md) for full context.
