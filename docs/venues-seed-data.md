# Venue Seed Data (Phase 1)

Consolidated from all research to date. "Verified" = rates/hours pulled directly
from the venue's own site. "Needs verification" = name/location/court count known
but rates/hours not yet collected — fine to launch without these, add once
verified.

## Fully/mostly verified venues (good launch-set candidates)

### The Badminton Club — Wetherill Park
- Suburb: Wetherill Park
- Courts: 7, dedicated badminton
- Hours: 5am–midnight, every day
- Rates: $29/hr off-peak (Mon–Fri 5am–4pm), $36/hr all other times, $29/hr
  special 10pm–midnight daily
- Bulk discounts: 10% over $560, 15% over $1000
- Platform: Sport Logic/intennis-style
- Booking URL: wetherillpark.thebadmintonclub.com.au
- Contact: wetherillpark@thebadmintonclub.com.au, 1300 754 078

### The Badminton Club — Prestons
- Suburb: Prestons
- Courts: 10, dedicated badminton
- Hours: likely same as Wetherill Park (5am–midnight) — verify
- Rates: same structure as Wetherill Park (~$29 off-peak / $36 peak) — verify
  exact figures on Prestons' own page
- Platform: Sport Logic/intennis-style
- Contact: prestons@thebadmintonclub.com.au, 1300 754 078

### Pro1 Badminton — Bankstown Aerodrome
- Suburb: Bankstown
- Courts: 14, dedicated badminton
- Rates: $29/hr off-peak (Mon–Fri 6am–4pm), $34/hr all other times + public
  holidays
- Notes: racquet hire available during staffed hours (4–10pm)
- Platform: Sport Logic/intennis-style
- Contact: info@pro1badminton.com.au

### Sydney Sports Club — Kings Park / Rouse Hill
- Suburbs: Kings Park, Rouse Hill (also Hawkesbury mentioned — verify if active)
- Courts: not stated — verify
- Rates: $21/hr off-peak (weekdays 5am–5pm, weekends 9pm–12am); $32/hr weekend
  12pm–9pm; $42/hr weekdays 5pm–10pm
- Note: site states checkout rates are authoritative if different
- Platform: Sport Logic/intennis-style
- Contact: info@sydneysportsclub.com.au, 0423 227 477

### Sydney Olympic Park — Sports Halls
- Suburb: Sydney Olympic Park
- Courts: 12, multi-sport (badminton + pickleball + others)
- Hours: Tue–Thu 12pm–10pm, Mon/Fri 4pm–10pm, Sat/Sun 8am–9pm, closed public
  holidays
- Rates: badminton ~$26–30/hr (third-party estimate, verify); pickleball
  confirmed $36/court/hr on official site
- Platform: Pitchbooking
- Contact: sportshalls@sopa.nsw.gov.au, 02 9714 7600

### Five Dock Leisure Centre
- Suburb: Five Dock
- Courts: 8, multi-sport (council)
- Rates: $38/hr peak (Mon–Fri 4–10pm, Sat/Sun), $28.50/hr off-peak (Mon–Fri
  6am–4pm)
- Notes: 48-hour cancellation policy, payment required at booking
- Platform: Council booking system
- Contact: info@fdlc.com.au, (02) 9911 6300

### Concord Oval Recreation Centre
- Suburb: Concord
- Courts: 8, multi-sport (council, same operator/rates as Five Dock per their
  shared badminton page)
- Rates: same as Five Dock — $38/hr peak, $28.50/hr off-peak
- Platform: Council booking system
- Contact: contact form at concordrec.com.au/about/contact-us

## Venues needing rates/hours verification before launch-set inclusion

| Venue | Suburb(s) | Courts | Platform | Contact |
|---|---|---|---|---|
| Alpha Badminton Centre | Silverwater (x2 locations), Auburn | 13 / 28 / 22 | yepbooking | info@alphabadminton.com.au |
| NBC Badminton (multi-venue) | Silverwater, Seven Hills, Granville, Castle Hill, Alexandria, Macquarie Park, Olympic Park | varies (e.g. 6 at Silverwater, 18 at Alexandria) | yepbooking | info@nbcbadminton.com.au |
| BadmintonWorx — Botany | Botany | 14 | yepbooking | botany@badmintonworx.com.au |
| BadmintonWorx — Norwest | Baulkham Hills | 9 | yepbooking | norwest@badmintonworx.com.au |
| ATC Badminton Centre | Five Dock | 8 | yepbooking | info@atcbadminton.com.au |
| Perry Park Recreation Centre | Alexandria | 4 (multipurpose) | Council | pprcadmin@cityofsydney.nsw.gov.au |
| YMCA Epping | Epping | not stated | YMCA portal | admin.epping@ymcansw.org.au |
| PCYC Northern Beaches | Northern Beaches | not stated | PCYC portal | northernbeaches@pcycnsw.org.au |
| UNSW Fitness & Aquatic Centre | Kensington | not stated | Custom portal | info@unswfac.com.au |

## Suggested Phase 1 launch set

The 7 "fully/mostly verified" venues above give good geographic spread (Inner
West, South-West, North-West, Sydney Olympic Park) and cover 3 of the 5
platforms. Recommend launching with these 7, then adding the remaining 9 as
their data gets verified (a quick pass per venue: visit rates page, confirm
courts/hours, update this doc, then add to DB).

## Example seed record shape (for `venues` + `rate_cards` + `opening_hours` tables per RFC-0001)

```json
{
  "name": "The Badminton Club - Wetherill Park",
  "slug": "the-badminton-club-wetherill-park",
  "suburb": "Wetherill Park",
  "courtCount": 7,
  "dedicatedBadminton": true,
  "platform": "sportlogic",
  "bookingUrl": "https://wetherillpark.thebadmintonclub.com.au",
  "email": "wetherillpark@thebadmintonclub.com.au",
  "phone": "1300 754 078",
  "rateCards": [
    { "label": "Off-Peak", "priceCents": 2900, "daysApply": ["mon","tue","wed","thu","fri"], "timeRangeStart": "05:00", "timeRangeEnd": "16:00" },
    { "label": "Peak", "priceCents": 3600, "daysApply": ["mon","tue","wed","thu","fri","sat","sun"], "timeRangeStart": null, "timeRangeEnd": null, "notes": "Applies all times not covered by Off-Peak or Late Night" },
    { "label": "Late Night Special", "priceCents": 2900, "daysApply": ["mon","tue","wed","thu","fri","sat","sun"], "timeRangeStart": "22:00", "timeRangeEnd": "00:00" }
  ],
  "openingHours": [
    { "dayOfWeek": 0, "openTime": "05:00", "closeTime": "00:00" },
    { "dayOfWeek": 1, "openTime": "05:00", "closeTime": "00:00" },
    { "dayOfWeek": 2, "openTime": "05:00", "closeTime": "00:00" },
    { "dayOfWeek": 3, "openTime": "05:00", "closeTime": "00:00" },
    { "dayOfWeek": 4, "openTime": "05:00", "closeTime": "00:00" },
    { "dayOfWeek": 5, "openTime": "05:00", "closeTime": "00:00" },
    { "dayOfWeek": 6, "openTime": "05:00", "closeTime": "00:00" }
  ],
  "_dataQuality": "verified from venue's court hire page"
}
```

Lat/lng for each venue aren't included here — these are straightforward to
geocode from suburb/address during Phase 1 setup (e.g. via Google Geocoding API
once the Maps/Places API key exists).
