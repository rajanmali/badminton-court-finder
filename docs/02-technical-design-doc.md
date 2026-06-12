# RFC-0001: Technical Design — Badminton Court Finder

**Status:** Draft for review
**Related:** PRD (01-PRD.md), Engineering Approach (engineering-approach-and-architecture.md)

## 1. Summary

This RFC defines the data model, API contract, and availability-normalization
design that underpin the architecture already proposed. It's the document a
backend engineer would implement directly from.

## 2. Data model

### `venues`
| Column | Type | Notes |
|---|---|---|
| id | uuid (PK) | |
| name | text | |
| slug | text (unique) | for deep links |
| suburb | text | |
| address | text | |
| lat | numeric | |
| lng | numeric | |
| court_count | int | |
| dedicated_badminton | boolean | true = dedicated centre, false = multi-sport venue |
| platform | enum | `sportlogic` \| `skedda` \| `pitchbooking` \| `yepbooking` \| `council` \| `other` |
| booking_url | text | deep link to venue's booking page |
| phone | text | nullable |
| email | text | nullable |
| created_at / updated_at | timestamptz | |

### `rate_cards`
| Column | Type | Notes |
|---|---|---|
| id | uuid (PK) | |
| venue_id | uuid (FK → venues) | |
| label | text | e.g. "Off-Peak", "Peak", "Weekend Offer" |
| price_cents | int | store as cents to avoid float issues |
| days_apply | text[] | e.g. `['mon','tue','wed','thu','fri']` |
| time_range_start | time | nullable |
| time_range_end | time | nullable |
| notes | text | nullable, e.g. "10% off over $560" |

### `opening_hours`
| Column | Type | Notes |
|---|---|---|
| id | uuid (PK) | |
| venue_id | uuid (FK → venues) | |
| day_of_week | int | 0=Sunday..6=Saturday |
| open_time | time | nullable if closed |
| close_time | time | nullable if closed |
| is_closed | boolean | for public holidays etc. — separate `closures` table if needed later |

### `availability_partnerships`
| Column | Type | Notes |
|---|---|---|
| id | uuid (PK) | |
| venue_id | uuid (FK → venues, unique) | |
| feed_type | enum | `ical` \| `webhook` \| `manual` |
| feed_url | text | nullable, encrypted at rest if it contains tokens |
| sync_frequency_minutes | int | default 15 |
| status | enum | `active` \| `paused` \| `pending` |
| last_synced_at | timestamptz | nullable |

### `availability_snapshots`
| Column | Type | Notes |
|---|---|---|
| id | uuid (PK) | |
| venue_id | uuid (FK → venues) | |
| date | date | |
| time_slot_start | time | |
| courts_available | int | |
| courts_total | int | |
| fetched_at | timestamptz | used for "last updated X min ago" in UI |

This table is the **normalized output** — regardless of whether the source was an
iCal feed from Skedda or a manual update, this is the shape the app and widget
read from. Old rows can be pruned/archived after the slot has passed.

## 3. API specification (REST, v1)

Base path: `/api/v1`

### `GET /venues`
Query params: `lat`, `lng`, `radius_km`, `dedicated_only`, `max_price`, `sort`
(`distance` | `price`)

Response:
```json
{
  "venues": [
    {
      "id": "uuid",
      "name": "Pro1 Badminton Centre",
      "suburb": "Bankstown",
      "lat": -33.91,
      "lng": 150.99,
      "courtCount": 14,
      "dedicatedBadminton": true,
      "distanceKm": 4.2,
      "priceFrom": 2900,
      "hasLiveAvailability": true
    }
  ]
}
```

### `GET /venues/:id`
Full detail: rates, opening hours, amenities, booking URL, partnership status.

### `GET /venues/:id/availability`
Query params: `date` (defaults to today)

Response:
```json
{
  "venueId": "uuid",
  "date": "2026-06-12",
  "lastUpdated": "2026-06-12T10:15:00Z",
  "slots": [
    { "start": "18:00", "end": "19:00", "courtsAvailable": 3, "courtsTotal": 7 },
    { "start": "19:00", "end": "20:00", "courtsAvailable": 0, "courtsTotal": 7 }
  ]
}
```
If no partnership exists, returns `slots: []` and a `liveAvailability: false`
flag — the app shows "Check availability on venue site" in this case.

### `GET /widget/summary`
Lightweight endpoint specifically for the widget sync — returns a compact payload
for a user's saved/nearby venues only, optimized for minimal payload size since
this is fetched by a background sync task, not interactively.

```json
{
  "venues": [
    { "id": "uuid", "name": "Pro1 Badminton", "nextAvailable": "18:00", "courtsAvailable": 3 }
  ],
  "syncedAt": "2026-06-12T10:15:00Z"
}
```

## 4. Availability normalization layer

The sync worker's core responsibility: take whatever shape each platform's feed
returns and produce `availability_snapshots` rows. Each platform gets its own
small adapter module implementing a common interface:

```ts
interface AvailabilityAdapter {
  platform: VenuePlatform;
  fetchAvailability(partnership: AvailabilityPartnership): Promise<NormalizedSlot[]>;
}
```

This means adding a 6th platform later is "write one new adapter", not "redesign
the system" — the API, database, app, and widget are all insulated from
platform-specific formats.

## 5. Sync scheduling

- Each `availability_partnerships` row has its own `sync_frequency_minutes` —
  not all venues need the same cadence (a quiet suburban venue might be fine at
  30 min; a busy CBD venue might warrant 10 min).
- Sync worker runs as a scheduled job (cron via Supabase Edge Functions or a
  simple `node-cron` process) that iterates due partnerships, calls the
  appropriate adapter, and upserts `availability_snapshots`.
- Failures are logged (Sentry) but don't block other venues' syncs — each
  partnership syncs independently.

## 6. Open technical questions

- iCal feeds typically represent *bookings* (busy blocks), not *availability*
  directly — the adapter needs venue opening hours + court count to compute
  "courts available" by subtracting bookings from total capacity per slot. This
  needs to be modeled carefully per venue (e.g. does each iCal event correspond
  to one court, or could one event block multiple courts?).
- Timezone handling: all times stored UTC, converted to `Australia/Sydney` at
  the API/app layer — daylight saving transitions need test coverage.
