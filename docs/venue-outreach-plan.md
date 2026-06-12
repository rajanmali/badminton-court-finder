# Venue Outreach Plan (Steps 1–3)

## Step 1: Outreach email template

Short, low-pressure, framed as referral traffic rather than competition. Tailor
the bracketed bits per venue.

---

**Subject: Quick question about sharing court availability — [Venue Name]**

Hi [Venue Name] team,

I'm building a directory app for badminton players in Sydney that lists venues,
rates, hours, and links straight through to each venue's own booking page — the
goal is to send more players your way, not to compete with your booking system.

I'd love to also show live court availability where possible, so players can see
at a glance when courts are free before they click through to book with you.

Would you be open to sharing a read-only availability feed (e.g. an iCal/calendar
export link, if your booking platform supports one)? It would only be used to
display general availability — all actual bookings and payments would stay on
your site.

Happy to share a preview of how [Venue Name] would look in the app, or jump on a
quick call if useful. Either way, thanks for considering it — and no worries at
all if it's not something you're able to do right now.

Cheers,
Rajan

---

**Suggested first targets (most likely to respond quickly):**
- Pro1 Badminton (Bankstown) — independent operator, active socials/community
  presence, direct WhatsApp contact already listed.
- The Badminton Club (Wetherill Park / Prestons) — has a direct contact email
  per location.
- Sydney Sports Club (Kings Park / Rouse Hill) — has direct phone/email contacts.

**For Skedda-based venues** (Badminton Zone, Home of Badminton, Game Court, DTBA),
the ask is slightly different — request the **iCal export link** from their Skedda
dashboard specifically, since Skedda supports this natively without needing any
custom development on their end.

## Step 2: Embedded widget / platform check on venue sites

Checked whether Skedda-based venues embed their live scheduler directly on their
own marketing sites (a sign they're comfortable surfacing live availability
publicly, and a possible source of an embeddable feed):

- Searches for Badminton Zone, Home of Badminton, Game Court, DTBA didn't surface
  separate marketing sites distinct from their `*.skedda.com` booking pages —
  these appear to operate primarily through the Skedda-hosted page itself rather
  than a separate branded website with an embedded widget. This makes the iCal
  route (Step 1, Skedda-specific ask) the more relevant path for these venues
  rather than scraping an embed.

**New platform discovered:** BadmintonWorx (Botany) uses yet another booking
platform — `yepbooking.com.au`. This confirms the earlier picture: Sydney
badminton venues are spread across at least 5 different booking platforms
(Sport Logic/intennis-style, Skedda, Pitchbooking, yepbooking, and bespoke council
systems). No single integration covers more than a handful of venues, which
reinforces that **venue-by-venue partnership (Step 1) is the right model**, not a
platform-wide technical integration.

## Step 3: Pilot rollout plan

Rather than waiting for all venues to respond before building anything:

1. **Send outreach (Step 1) to ~5 venues** spanning different platforms — this
   tests response rates across operator types (independent vs. multi-location vs.
   council) and platforms simultaneously.
2. **Build the directory for all ~20 venues regardless** (rates, hours, courts,
   location, deep link) — this doesn't depend on anyone responding and is the
   foundation either way.
3. **Add a "Live availability" badge per venue**, which only appears once a venue
   has provided a feed. Early on, most venues will show "Check availability on
   [venue site]" — that's fine and expected.
4. **Use the first 1–2 "yes" responses as social proof** when following up with
   remaining venues ("Pro1 and Sydney Sports Club already share their availability
   with us — would you like [Venue] to appear too?").

This means the project moves forward immediately on the directory while
partnerships build in parallel — no blocked dependency on venue responses.
