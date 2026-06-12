# ADR-0005: Supabase (Postgres) + Sanity CMS as primary data stores

**Status:** Accepted

## Context

Need a relational database for venues and availability data, plus a content-management layer for editorial metadata (descriptions, photos, amenities) that non-engineers might eventually update. Owner already uses Supabase on other projects.

## Decision

- **Supabase Postgres** for all transactional and structured data: venues, rate cards, opening hours, availability snapshots, and partnership configs.
- **Sanity CMS** for editorial content only (descriptions, photos, amenities). Sanity is the source of truth for these fields; it syncs into Postgres via webhook on publish.

## Consequences

- Matches existing familiarity — faster development.
- Two systems to keep in sync, mitigated by Sanity's scope being strictly limited to rarely-changing editorial fields. Availability data never touches Sanity.
- Supabase also provides Auth and Storage for future use, and realtime subscriptions if needed.
- Free tiers cover expected scale at launch; both have predictable paid upgrade paths.
