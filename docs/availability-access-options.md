# Getting Access to Live Availability Data — Realistic Options

Short version: there's no technical shortcut that gets around the access controls
found so far. The robots.txt blocks on the Sport Logic/intennis platform and
Skedda's lack of a public read API aren't oversights — they're deliberate. Scraping
past them would mean violating each platform's Terms of Service, which is a real
risk (account/IP bans, legal exposure for the app, and reputational risk with
venues you'd want as partners later). So "find a way" here means finding the
*legitimate* way in, not a workaround.

Here are the actual options, ranked by realism.

## Option 1: Direct venue partnerships (most realistic)

This is how most "availability aggregator" apps actually start. Concretely:

- Email venues directly (most are small operators — The Badminton Club, Pro1,
  Sydney Sports Club all have direct contact emails/phones already collected).
- Pitch it as **referral traffic, not competition**: "I'm building a directory
  that shows your rates/hours and links straight to your booking page — would you
  be open to sharing a read-only availability feed so users can see live slots
  before clicking through?"
- Ask specifically for either:
  - A **Skedda iCal/calendar feed link** (Skedda supports read-only iCal export —
    venue admins can generate this in their dashboard and just hand you the URL).
  - Or, for Sport Logic/intennis-based venues, ask if their platform vendor offers
    any partner/reporting API — worth a direct email to the platform operator too,
    since one "yes" could unlock multiple venues at once.
- Start with **2–3 venues** as a pilot rather than trying to get all 20 at once.
  A small working pilot is also a much stronger thing to show other venues later
  ("here's what it looks like for Venue X, want in?").

This is slower than scraping, but it's the only path that gives you *stable*,
ToS-compliant access — scrapers break constantly when sites update, whereas a
feed link a venue gives you deliberately tends to be maintained.

## Option 2: Skedda embedded scheduler (per-venue, opt-in)

Skedda explicitly supports venues embedding their live scheduler on **the venue's
own website** via an iframe/snippet. This doesn't directly give *you* an API, but
if a venue is willing to partner, they could either:
- Share the same embed snippet with you to show inside your app (still subject to
  Skedda's venue ToS — would need the venue to confirm this is fine), or
- Generate the iCal feed mentioned above, which is the cleaner option.

## Option 3: Partner with an existing aggregator

`badmintoncourt.au` already lists Alpha Badminton, NBC Silverwater, Sydney Olympic
Park and others with venue info. Worth checking whether they have an API, or
whether they'd be open to a data-sharing arrangement — they may have already done
some of the venue outreach legwork you'd otherwise repeat.

## Option 4: Static/manual data + "last updated" model (fallback for non-cooperating venues)

For venues that don't respond or can't offer a feed, fall back to the directory
model: rates, hours, courts, deep link — refreshed manually every few weeks. Label
clearly as "see live availability on venue site." Not as flashy, but it's honest
and doesn't carry ToS risk.

## What I'd actually do first

1. Draft a short, friendly outreach email/template (happy to write this) for the
   2–3 venues most likely to say yes — independent operators like Pro1 or The
   Badminton Club tend to be more responsive than council-run centres.
2. In parallel, check whether any Skedda venues already have embed/booking widgets
   live on their own sites (a sign they're comfortable with this kind of sharing).
3. Treat "live availability" as a per-venue badge that lights up as partnerships
   land — ship the directory now, add live data venue-by-venue.

This keeps the project realistic, legal, and — importantly — keeps the door open
with venues you'll eventually want driving bookings through your app anyway.
