# ADR-0007: React Query (TanStack Query) for server state

**Status:** Accepted

## Context

The mobile app needs a state management approach for fetching, caching, and revalidating server data. Two candidates were considered: React Query (TanStack Query) and RTK Query. The project owner has deep Redux Toolkit / RTK Query experience, making familiarity a genuine factor.

## Decision

Use React Query (TanStack Query) for all server state in `apps/mobile`. Use `useState` / `useReducer` for local UI state (filter values, modal toggles).

## Consequences

- Minimal boilerplate for this app's dominant pattern: fetch venue list, fetch venue detail, invalidate on pull-to-refresh.
- Built-in stale-while-revalidate behaviour is a direct fit for availability data in Phase 2+.
- No Redux store — local UI state stays in component-level hooks. Revisit if Phase 2+ introduces complex cross-screen derived state that warrants a global store.
- RTK Query would be a better fit only if a Redux store were already needed for complex local state; this app has very little of that in Phase 1.
