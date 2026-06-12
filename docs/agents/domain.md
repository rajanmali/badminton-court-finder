# Domain Docs

How engineering skills should consume this repo's domain documentation.

## Before exploring, read these

- **`CONTEXT.md`** at the repo root — domain vocabulary, invariants, and phase definitions.
- **`docs/adr/`** — read ADRs that touch the area you're about to work in.

If either is missing, proceed silently.

## File structure

Single-context repo:

```
/
├── CONTEXT.md
├── docs/adr/
│   ├── 0001-react-native-expo.md
│   ├── 0002-no-scraping.md
│   ├── 0003-normalization-adapter-pattern.md
│   ├── 0004-ios-widget-deferred.md
│   ├── 0005-supabase-sanity.md
│   ├── 0006-monorepo-git-workflow.md        ← updated: Turborepo + npm workspaces
│   ├── 0007-react-query-state-management.md
│   ├── 0008-nestjs-api-from-day-one.md
│   └── 0009-maplibre-maptiler.md
└── docs/
    └── agents/   ← this directory
```

## Use the glossary's vocabulary

When your output names a domain concept (issue title, refactor proposal, test name), use the term as defined in `CONTEXT.md`. Key terms: Venue, Rate card, Partnership, Feed, AvailabilityAdapter, AvailabilitySnapshot, Sync worker, Widget, Booking platform.

Don't use synonyms the glossary avoids — e.g. say "AvailabilitySnapshot", not "availability record" or "slot data".

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly:

> _Contradicts ADR-0002 (no scraping) — but worth reopening because…_
