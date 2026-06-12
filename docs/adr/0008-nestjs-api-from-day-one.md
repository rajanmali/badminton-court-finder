# ADR-0008: NestJS API layer from day one (not direct Supabase)

**Status:** Accepted

## Context

Phase 1 is a static directory — no live availability, no auth, no complex business logic. The mobile app only needs to read venues, rate cards, and opening hours. It would be faster to have the Expo app call Supabase directly via `@supabase/supabase-js` for Phase 1 and introduce the NestJS API layer in Phase 2 when the sync worker and availability endpoints are needed.

## Decision

The mobile app calls the NestJS API (`/api/v1/venues`, `/api/v1/venues/:id`) from day one. It never calls Supabase directly.

## Rationale

The `GET /venues` and `GET /venues/:id` endpoint shapes are already defined in the technical design doc and are the same shapes Phase 2 builds on. Implementing them in NestJS in Phase 1 means Phase 2 is purely additive (new endpoints, new tables) rather than a disruptive re-routing of all data fetching from Supabase-direct to API-mediated.

The alternative — direct Supabase in Phase 1, NestJS in Phase 2 — requires rewriting every data access call in the mobile app and `packages/api-client` mid-stream, while simultaneously building availability features. That's two large changes at once with no isolation between them.

## Consequences

- Phase 1 scope includes scaffolding the NestJS service and deploying it to Railway, not just the Expo app.
- The mobile app and `packages/api-client` are permanently decoupled from Supabase's client SDK — they only know about the REST API contract.
- Supabase is an implementation detail of the backend; swapping it later (unlikely, but possible) requires no mobile changes.
