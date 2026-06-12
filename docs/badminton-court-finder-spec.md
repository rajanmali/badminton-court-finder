# Badminton Court Finder — Feasibility Plan & v1 Spec (Sydney Metro)

## 1. The core constraint vs. FuelCheck

NSW FuelCheck works because the **Fair Trading Act** legally requires every fuel retailer
to push live prices to a government API every 30 minutes. There is no equivalent
mandate for sports venues. Badminton centres run on a scattering of third-party
booking platforms, each with its own data shape:

| Venue (Sydney examples)                          | Platform                  | Public availability view? |
|---------------------------------------------------|---------------------------|----------------------------|
| The Badminton Club (Wetherill Park, Prestons)      | Custom booking system      | Yes, behind their own UI   |
| Pro1 Badminton (Bankstown)                         | Custom portal              | Yes                         |
| Badminton Zone, Home of Badminton, DTBA, Game Court| **Skedda** (`*.skedda.com`) | Yes, public booking grid    |
| Sydney Olympic Park Sports Centre                  | Council booking system     | Partial (rates known, live availability unclear) |
| Five Dock / YMCA Ryde leisure centres              | Council/YMCA booking portals | Varies                    |
| Sydney Sports Club (Kings Park, Rouse Hill)        | Custom "Book Online"       | Yes                         |

So the data exists, but it's spread across maybe 5–8 different platform types, each
needing its own integration logic. There's no single switch to flip.

## 2. Three possible approaches

**A. Curated directory (no live data)**
List venues, hours, indicative rates, number of courts, and a "Book here" deep link
to each venue's own booking page. Low effort, low maintenance, but it's basically a
nicer Google Maps — doesn't solve "do they have a court free at 7pm tonight".

**B. Live scraping per venue**
For Skedda venues specifically, the public `/booking` calendar page renders an
availability grid that *can* be read programmatically (no login required to view).
For custom platforms (The Badminton Club, Pro1, Sydney Sports Club), this would
require a headless browser per venue, reverse-engineering each site's calendar
widget, and ongoing maintenance every time a venue changes its website.
This is the FuelCheck-like experience, but it's a many-to-one integration problem,
not a one-to-many API call.

**C. Hybrid (recommended for v1)**
- Skedda venues: pull semi-live availability (Skedda's grid is the most consistent
  and scrape-friendly of the platforms found).
- All other venues: directory info (rates, hours, courts, location, deep link),
  refreshed manually/periodically — and clearly labelled as "check live availability
  on venue site" rather than implying real-time accuracy.
- This gets you a genuinely useful app without overcommitting to fragile scrapers
  for every custom site on day one.

## 3. Legal / ToS considerations (important)

- Scraping a public booking page that requires no login is generally lower-risk
  than scraping behind a login wall, but most booking platforms' ToS prohibit
  automated access. Skedda in particular has historically required venues to
  opt into a paid API for third-party integrations.
- Recommended path: where possible, **email venues** and ask if they're open to
  sharing availability (some will happily give you read access if it drives
  bookings to them). Frame the app as referral traffic, not a competitor booking
  system — always deep-link to *their* checkout, never process payments yourself.
- Treat this as "directory + best-effort availability hints", not "authoritative
  real-time source", in your UI copy and ToS.

## 4. Recommended v1 scope (Sydney metro)

**Goal:** A web app listing ~15–25 Sydney badminton venues with location, rates,
hours, court count, and a "freshness-labelled" availability indicator.

**Feature set:**
1. Map/list view of venues (you've already got `places_search` / map tooling
   patterns from other projects — reusable here).
2. Venue detail page: rates table (peak/off-peak), courts, surface type, amenities,
   opening hours, deep link to book.
3. Availability indicator:
   - Skedda venues: "X courts free in next 2 hrs" pulled from their public grid.
   - Other venues: "Check availability on [venue]" button.
4. Filters: suburb/distance, price range, open now, dedicated badminton vs.
   multi-sport centre.
5. Simple admin/data layer you control directly (so you can update rates/hours
   without redeploying) — Sanity CMS would fit, given your existing setup.

## 5. Suggested tech stack (matches your current toolkit)

- **Frontend:** Next.js 15 + TypeScript, same stack as your portfolio site.
- **CMS/data store:** Sanity for venue metadata (rates, hours, amenities, photos) —
  you already know this well.
- **Availability fetcher:** Node/TypeScript service (could reuse your n8n +
  Playwright pipeline pattern from the job-application project) that polls Skedda
  venue calendars on a schedule (e.g. every 15 min) and writes a normalized
  "slots free" summary to a small Postgres/Supabase table.
- **Map:** Google Places/Maps, consistent with the places tooling pattern.

## 6. Data model sketch

```
Venue {
  id, name, suburb, address, lat, lng,
  courtCount, dedicatedBadminton: bool,
  rates: [{ label, priceRange, daysApply, timeRange }],
  openingHours: [{ day, open, close }],
  bookingUrl, platform: "skedda" | "custom" | "council" | "other",
  skeddaSubdomain?: string
}

AvailabilitySnapshot {
  venueId, fetchedAt,
  slots: [{ date, startTime, courtsAvailable, courtsTotal }]
}
```

## 7. Phased roadmap

- **Phase 0 (now):** Compile venue list for Sydney metro (~20 venues), confirm
  which run on Skedda vs. custom platforms.
- **Phase 1:** Build directory app (Approach A) — Next.js + Sanity, no live data.
  This alone is a usable, shippable product.
- **Phase 2:** Add Skedda availability fetcher for the subset of venues on that
  platform; display "freshness timestamp" alongside availability.
- **Phase 3:** Reach out to non-Skedda venues about data access; add scrapers
  case-by-case only where it's maintainable.

## 8. Open questions for next session

- Do you want to start with the directory build (Phase 1) as the prototype?
- Should I start compiling the actual Sydney venue list (names, suburbs, platforms)
  as structured data to seed Sanity?
