# ADR Log

ADRs have been migrated to individual files in `docs/adr/`:

| File | Decision |
|---|---|
| [0001-react-native-expo.md](adr/0001-react-native-expo.md) | React Native (Expo) over native iOS/Android |
| [0002-no-scraping.md](adr/0002-no-scraping.md) | No live scraping of venue booking platforms |
| [0003-normalization-adapter-pattern.md](adr/0003-normalization-adapter-pattern.md) | Normalization adapter pattern for availability data |
| [0004-ios-widget-deferred.md](adr/0004-ios-widget-deferred.md) | iOS widget deferred to its own phase |
| [0005-supabase-sanity.md](adr/0005-supabase-sanity.md) | Supabase (Postgres) + Sanity CMS as primary data stores |
| [0006-monorepo-git-workflow.md](adr/0006-monorepo-git-workflow.md) | Monorepo and git workflow (updated: Turborepo + npm workspaces as task orchestration layer) |
| [0007-react-query-state-management.md](adr/0007-react-query-state-management.md) | React Query (TanStack Query) for server state |
| [0008-nestjs-api-from-day-one.md](adr/0008-nestjs-api-from-day-one.md) | NestJS API layer from day one (not direct Supabase) |
| [0009-maplibre-maptiler.md](adr/0009-maplibre-maptiler.md) | MapLibre + Maptiler for maps (not react-native-maps + Google Maps) |

New ADRs go into `docs/adr/` as individual files. Never edit an existing ADR retroactively — if a decision changes, write a new ADR that supersedes it.
