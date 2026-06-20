You are a senior product designer redesigning an iOS app called **Smash** — a
Sydney badminton court finder. I've attached two sets of images: (1) screenshots
of the CURRENT app (functional but visually plain — a minimal port, not a designed
look), and (2) REFERENCE images of the visual style I want. Treat the reference
images as the source of truth for mood, palette, materials, and typography;
treat the current screenshots only as the information architecture to preserve.

## Goal
Redesign every screen to feel modern, premium, and tactile — the kind of app that
wins an Apple Design Award. Lead with **glassmorphism**: layered translucent
"glass" surfaces (iOS Materials — ultraThin/regular/thick), real-time background
blur, soft vibrancy, depth through stacking and shadow, and gentle light/refraction
on edges. Glass should sit over a rich, slightly colorful backdrop (gradients,
blurred map, or photographic court imagery) so the translucency actually reads.

## Apple Design Award bar — hold to all of these
- **Clarity first:** glass must never cost legibility. Maintain strong text
  contrast (WCAG AA+) with scrims/vibrancy behind text on glass. Beautiful but
  readable in bright sun and dark room.
- **Depth & deference:** content is the hero; chrome is quiet, translucent, and
  recedes. Use layering, parallax, and material hierarchy to express structure.
- **Native & alive:** SF Pro typography (with a confident display weight for
  headers), SF Symbols, fluid spring animations, haptics on key actions,
  buttery transitions between list↔map↔detail.
- **Systematic:** deliver a cohesive design system — color tokens, type scale,
  spacing, corner radii, elevation/material levels, iconography.
- **Inclusive:** full **Dark Mode**, Dynamic Type support, reduced-transparency
  fallback (solid surfaces when the user disables transparency), large tap targets.

## The app — screens & exact content to keep

**1. Venue list (home).** Title "Smash — Find a Court". A list/map segmented
toggle. A filter bar: distance chips (Any / 5 / 10 / 20 km), max-price chips
(Any / ≤$30 / ≤$35 / ≤$40), and a "Dedicated courts only" toggle. Scrolling list
of venue cards; each card shows: venue name, suburb, a green "Dedicated" badge
(for badminton-only venues), "From $XX/hr", court count (e.g. "7 courts"), and
distance ("28.5 km"). Real examples to use in mockups: "The Badminton Club —
Wetherill Park · Wetherill Park · Dedicated · From $29/hr · 7 courts · 28.5 km";
"Sydney Olympic Park Sports Halls · From $28/hr · 12 courts · 13.0 km"; "Five
Dock Leisure Centre · From $29/hr · 8 courts · 7.4 km". Reimagine the rows as
elegant glass cards. Also design the loading, empty ("No venues match your
filters"), and error states.

**2. Map view.** Full-screen MapLibre map of Sydney with venue pins — currently
green dots for dedicated venues, blue for multi-sport, with the venue's first
letter. Redesign the pins, selected/cluster states, and a glass floating filter/
toggle bar and a glass venue preview card that slides up when a pin is tapped.

**3. Venue detail.** Header (name, suburb, address, Dedicated badge, "N courts ·
From $X/hr"). A "Court hire rates" section (rate cards: label, days, time range,
price in green, optional notes). An "Opening hours" section (Mon→Sun rows with
times or "Closed"). A prominent primary booking CTA ("Book a court") that deep-
links out. Reimagine as a layered, scrollable detail with a hero treatment,
glass info sections, and a floating glass CTA.

## Brand & art direction
- The current brand accent is a vivid green (#00C853). Keep an energetic,
  sporty green as the signature accent, but evolve the exact hue/gradient to
  match the attached references. Pull the broader palette, gradient/backdrop
  approach, and material feel from the reference images.
- Sport-forward energy: motion, speed, precision — without clutter. Badminton =
  light, fast, airy; let the design feel that way.

## Deliverables
- High-fidelity mockups of all screens above (light + dark), at iPhone scale.
- The filter bar, a venue card, map pins, and the detail CTA shown as reusable
  components.
- A one-screen style tile: color tokens, type scale, material/elevation levels,
  corner radii, and iconography.
- Short notes on the glass material levels used and the reduced-transparency
  fallback.

Match the attached reference images' aesthetic closely while keeping every piece
of information and every control from the current app. Prioritize a design that
is striking on first open AND effortless to use.
