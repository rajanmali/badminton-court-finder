# ADR-0003: Normalization adapter pattern for availability data

**Status:** Accepted

## Context

Venue availability data arrives in at least 4–5 different shapes depending on platform (iCal, custom JSON, webhooks, etc.), and venue partnerships will be onboarded incrementally. The mobile app and widget must not need platform-specific knowledge.

## Decision

All availability data passes through a per-platform `AvailabilityAdapter` implementing a common interface, producing a single normalized `availability_snapshots` table that the API, app, and widget consume.

```ts
interface AvailabilityAdapter {
  platform: VenuePlatform;
  fetchAvailability(partnership: AvailabilityPartnership): Promise<NormalizedSlot[]>;
}
```

## Consequences

- Adding a new venue platform = writing one adapter; no changes needed to the API, app, or widget.
- Slightly more upfront design work for the interface definition.
- The `availability_snapshots` table is the single source of truth for all availability reads — never query raw feed data from the app.
