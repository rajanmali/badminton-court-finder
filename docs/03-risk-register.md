# Risk Register

| ID | Risk | Likelihood | Impact | Mitigation | Owner | Status |
|---|---|---|---|---|---|---|
| R1 | No venues agree to share availability data | Medium | High (live availability is a core differentiator) | Ship directory-only as solid fallback (Phase 1 doesn't depend on partnerships); pilot outreach to 5 venues across different operator types | Rajan | Open |
| R2 | iCal feed represents bookings, not availability — normalization more complex than expected per venue | Medium | Medium | Build adapter interface to isolate complexity per venue; start with one venue end-to-end before scaling to others | Eng | Open |
| R3 | Android widget refresh unreliable due to OEM battery optimization (Samsung etc.) | High | Medium | Set realistic refresh expectations in UI ("updated X min ago"); test on multiple device brands; don't promise true real-time | Eng | Open |
| R4 | iOS widget requires native Swift — adds non-RN skill requirement | High (certain) | Low-Medium | Treat as separate, scoped mini-project after Android ships; budget extra time | Eng | Accepted |
| R5 | Venue rates/hours go stale (manual data) | Medium | Low | Add "last verified" date per venue; consider crowd-sourced correction flow in backlog | Rajan | Open |
| R6 | Scraping temptation re-emerges under time pressure, violating platform ToS | Low (now flagged) | High (legal/reputational, breaks future partnerships) | This RFC + risk register explicitly rule it out; any future "let's just scrape X" proposal should be checked against this doc | Rajan | Mitigated |
| R7 | Venue data accuracy disputes (a venue says rates are wrong) | Low | Low-Medium | Include "report an issue" contact/link on venue pages; respond promptly to maintain partner goodwill | Rajan | Open |
| R8 | Single-person project bandwidth — multiple workstreams (outreach, app, backend) compete for time | High | Medium | Phase plan sequences work so outreach runs in parallel with directory build, not blocking it | Rajan | Open |
| R9 | App store review delays/rejections (location permissions, third-party data display) | Low-Medium | Medium | Review Apple/Google guidelines on location use and business data display before submission; have privacy policy ready early | Rajan | Open |
| R10 | Supabase/Sanity free tier limits hit as data grows | Low | Low | Monitor usage; both have predictable paid tiers if needed — not a blocker at this scale | Eng | Open |

## Review cadence

This register should be revisited at the start of each phase (see roadmap) —
risks get re-rated, closed risks marked, and new risks added as the project
progresses. A stale risk register is worse than no risk register.
