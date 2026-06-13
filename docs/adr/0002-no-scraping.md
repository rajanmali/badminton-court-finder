# ADR-0002: No live scraping of venue booking platforms

**Status:** Accepted

## Context

Several venue booking platforms (Sport Logic/intennis-style) block `robots.txt`. Skedda has no public read API. Scraping was considered as a way to source live availability without venue cooperation.

## Decision

Do not scrape. Live availability is sourced only via explicit venue partnerships (iCal feeds or similar opt-in mechanisms).

## Consequences

- Live availability rollout is slower and partnership-dependent.
- No ToS violations, no fragile scrapers breaking on platform updates.
- Better long-term relationships with venues, who are also potential future partners for referral/booking integrations.
- Any future "let's just scrape X" proposal should be checked against this ADR before proceeding.
