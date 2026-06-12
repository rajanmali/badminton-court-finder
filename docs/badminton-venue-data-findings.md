# Sydney Badminton Venue Data — Collection Findings

Goal of this pass: pull real rate/availability data from venue websites and test
whether their booking systems can actually be scraped. Findings below.

## 1. Rates collected so far

| Venue | Suburb | Courts | Off-Peak | Peak | Notes |
|---|---|---|---|---|---|
| The Badminton Club — Wetherill Park | Wetherill Park | 7 | $29/hr (Mon–Fri 5am–4pm) | $36/hr (all other times) | $29/hr special 10pm–midnight daily. Open 5am–midnight every day. Bulk discounts: 10% over $560, 15% over $1000. |
| The Badminton Club — Prestons | Prestons | 10 | ~$29/hr (likely same structure) | ~$36/hr | Same operator/platform as Wetherill Park — page not yet pulled in detail. |
| Pro1 Badminton — Bankstown Aerodrome | Bankstown | 14 | $29/hr (Mon–Fri 6am–4pm) | $34/hr (all other times + public holidays) | Racquet hire available staffed hours 4–10pm. |
| Sydney Sports Club — Kings Park / Rouse Hill / Hawkesbury | Kings Park, Rouse Hill | not stated | $21/hr (Weekdays 5am–5pm, Weekends 9pm–12am) | $32/hr weekend offer 12pm–9pm; $42/hr weekdays 5pm–10pm | Note on site: rates shown may differ slightly from checkout — checkout is authoritative. |
| Sydney Olympic Park Sports Halls | Sydney Olympic Park | 12 | n/a | ~$26–30/hr badminton (per third-party source) | Pickleball confirmed at $36/court/hr on official site. Open Tue–Thu 12–10pm, Mon/Fri 4–10pm, weekends 8am–9pm, closed public holidays. |
| Five Dock Leisure Centre | Five Dock | 8 (non-dedicated) | ~$19–27/hr (third-party estimate) | — | Not yet verified on primary site. |
| YMCA Ryde Community Sports Centre | Ryde | non-dedicated | ~$35/hr per court (third-party estimate) | — | Not yet verified on primary site. |
| Alpha Badminton Centre | Silverwater | 22 (one listing) / 13 (another listing) | not yet collected | — | Conflicting court counts across sources — needs verification directly with venue. |
| NBC Silverwater | Silverwater | 6 | not yet collected | — | |

**Takeaway:** rates *are* publicly available for most dedicated badminton centres —
usually on a "Court Hire" or "Pricing" page as static text. This part of the data
(rates, hours, court counts, locations) is straightforward to collect, mostly
manually or via simple static-page fetches. The harder problem, as below, is live
availability.

## 2. Booking platform landscape (this is the key finding)

Testing actual booking pages revealed something useful: **most of these venues run
on a small number of shared third-party booking platforms**, not bespoke systems.
That's good news for "one integration covers many venues" — but each platform has
its own access barriers.

| Platform | Venues observed using it | Scrape test result |
|---|---|---|
| **"Sport Logic" style white-label** (`*.sportlogic.net.au`, `*.intennis.com.au`, and what looks like the same backend powering `wetherillpark.thebadmintonclub.com.au` and `booking.pro1badminton.com.au` — all share the URL pattern `/secure/customer/booking/v1/public/show`) | The Badminton Club (Wetherill Park, Prestons), Pro1 Badminton, Sydney Sports Club (Kings Park, Rouse Hill, Hawkesbury) | **Blocked by robots.txt** on every domain tested. This is a strong "do not scrape" signal from the platform vendor across all venues using it. |
| **Skedda** (`*.skedda.com`) | Badminton Zone, Home of Badminton, DTBA Badminton Club, Game Court, South Suburban Badminton Association, Queensland Badminton Centre, Orange County Badminton Club | Booking page is a fully **JavaScript-rendered single-page app** (Ember.js) — a basic fetch returns an empty shell. Reading availability would require a real browser (Playwright). Robots.txt not yet confirmed for these, but Skedda has historically gated third-party API access behind a paid integration tier. |
| **Pitchbooking** | Sydney Olympic Park Sports Halls | Not yet tested directly — different vendor again, worth checking. |
| Council/leisure centre systems | Five Dock, YMCA Ryde | Not yet tested — likely each council runs its own booking portal (e.g. via YourVenue, Tempo, ActiveNet-type systems). |

So instead of "20 venues = 20 scraping problems", it's closer to **"20 venues =
4–5 platform integrations"** — which is a much more tractable shape for a project.
But the one platform covering the *most* dedicated badminton venues
(Sport Logic/intennis-style) has explicitly blocked automated access via robots.txt
on every instance tested.

## 3. What this means for viability

- **Directory data (rates, hours, courts, locations, amenities):** highly viable.
  This is publicly published, static, and easy to collect — either by hand or with
  simple page fetches. No legal/technical barriers found.
- **Live availability via scraping:** viable in principle for Skedda venues (with a
  headless browser), but:
  - Blocked outright (per robots.txt) for the Sport Logic/intennis-style platform,
    which covers several of the biggest dedicated centres (The Badminton Club,
    Pro1, Sydney Sports Club).
  - Not yet tested for Pitchbooking (Sydney Olympic Park) or council systems —
    these need checking before drawing conclusions.
- **A directory app with rates, hours, and "book here" deep links is solid and
  low-risk.** A live-availability layer is only realistic for a subset of venues
  (Skedda-based ones, pending a robots check), and only behind-the-scenes via
  headless browser — not a simple API call.

## 4. Next data-collection steps (still planning phase, no build)

1. Confirm robots.txt status for `*.skedda.com` and `pitchbooking.com` booking pages.
2. Pull rates/hours for the remaining venues on the shortlist (Prestons, Five Dock,
   YMCA Ryde, Alpha Badminton, NBC Silverwater, Badminton Zone, Home of Badminton,
   Game Court, DTBA).
3. Identify which platform Sydney Olympic Park's Pitchbooking integration and
   council leisure centres actually run, and whether they expose any public
   availability view at all.
4. Decide, based on the above, whether to email the Sport Logic/intennis platform
   operator and/or individual venues about data-sharing access — since their
   robots.txt is the main hard blocker for the biggest cluster of venues.
