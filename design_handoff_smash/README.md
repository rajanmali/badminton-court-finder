# Handoff: Smash — Badminton Court Finder (Glass Redesign)

## Overview
**Smash** is an iOS app that helps people find badminton courts around Sydney. This package
is a full visual + interaction redesign: a **glass-forward** interface (Apple "Liquid Glass" /
iOS Materials) layered over rich, sporty backdrops, built on a **BWF-court-inspired palette**
(green playing-surface, BWF red, court grey). It covers three core screens — **Venue List**,
**Map**, **Venue Detail** — plus loading / empty / error states, full **light + dark** mode, a
**reduced-transparency** accessibility fallback, and a halftone brand motif.

The information architecture of the original app is preserved exactly; only the look,
materials, motion, and the List/Map control's placement changed.

---

## About the design files
The files in this bundle are **design references created in HTML/React** — prototypes that show
the intended look and behaviour. **They are not production code to ship.** The task is to
**recreate these designs in the target codebase's environment** using its established patterns:

- **Best target for this app: native iOS (SwiftUI).** The glass is the whole point, and SwiftUI
  gives it to you for free with `.ultraThinMaterial` / `.regularMaterial` / `.thickMaterial`,
  `Material` backgrounds, `.background(.ultraThinMaterial, in: RoundedRectangle(...))`, SF Symbols,
  spring animations, and `UIAccessibility.isReduceTransparencyEnabled`. Prefer these natives over
  re-implementing blur by hand.
- If the existing codebase is **React Native / Expo**, use `expo-blur` (`BlurView`) for materials
  and `react-native-reanimated` for motion.
- If it's a **web** app, the HTML here is directly portable (CSS `backdrop-filter`).

Map the HTML approximations to the platform's real materials — don't copy the `rgba()`+`backdrop-filter`
hacks verbatim into a native app.

## Fidelity
**High-fidelity.** Colors, typography, spacing, radii, shadows, and interactions are final and
exact. Recreate the UI pixel-faithfully using the codebase's component library and the native
material system. The only placeholders are **photographic imagery** (hero shots, venue photos),
which are represented by gradient + halftone + court-line graphics — swap in real photos.

---

## Navigation / Information architecture
- **Bottom floating tab bar** (NEW — was a top segmented control) is the primary navigation:
  two tabs, **List** and **Map**. It's a centered, floating glass pill above the home indicator.
  Active tab = solid green capsule with dark-green text; inactive = secondary text. Light haptic
  on change.
- **Venue Detail** is a push/cover presentation opened by tapping a venue card (List) or the
  "View venue" button in the map preview card. It has its own back button; the tab bar is hidden
  while Detail is open.
- Filters live in a panel: always visible on List (under the title), toggled via a "Filters"
  button on Map.

---

## Screens / Views

### 1. Venue List (home) — default screen
**Purpose:** Browse/filter courts as a scrolling list of cards, nearest first.

**Layout (top → bottom), screen width 393–396pt:**
1. **Status bar** (system).
2. **Header** — left: wordmark "Smash" (Display weight) + a 9px green status dot with glow, and a
   subtitle "Find a court · Sydney" (Caption, secondary). Right: a circular ultra-thin glass
   "locate" pill (42×42) containing a green navigation-arrow icon. Padding 18pt sides.
3. **Filter bar** — a **thick-glass** rounded panel (radius 24), 13–14pt padding, containing three
   stacked rows separated by hairlines:
   - **Distance:** label "DISTANCE" (micro) + horizontal chip row: `Any · 5 km · 10 km · 20 km`.
   - **Max price:** label "MAX PRICE" + chips: `Any · ≤$30 · ≤$35 · ≤$40`.
   - **Dedicated courts only:** a bolt icon + label, with an iOS switch on the right.
4. **Meta row:** "{n} venues" (left) and "Nearest first ⌄" (right), both Caption / secondary.
5. **Venue cards** — vertical list, 13pt gap, 16pt side padding, bottom padding 120pt (so the last
   card clears the floating tab bar).
6. **Floating tab bar** (List active).

**Venue card (V1 "Glass standard" — the in-use variant):**
- **Container:** regular-glass, radius 26 (`--r-card`), 14pt padding, `display:flex; align-items:center; gap:14`.
- **Left thumbnail ("court tile"):** 58×58, radius 15. Background = dedicated → green gradient
  (`#19D680 → #0A6E42`), multi-sport → grey gradient (`#3a4046 → #1d2125`). Overlaid with faint
  court-line strokes + small halftone + the venue's initial letter (white, weight 800, ~23px).
- **Middle:** venue name (Headline, 17/800, -0.4 tracking, truncates with ellipsis) + a green
  "Dedicated" pill badge if applicable; suburb row with a pin icon (Caption, secondary); a meta row
  with courts count (grid icon) and distance (nav icon).
- **Right:** "FROM" micro-label, then price `$29` (22/850, color `--green`) with `/hr` (12, tertiary),
  and a chevron-right below (tertiary).
- **Press state:** scale 0.96 (spring).

**Dedicated badge:** pill, green gradient (`#19D680 → #00B964`), text `#04190F`, 11px/800 uppercase,
3–8pt padding, soft green glow shadow.

### 2. Map
**Purpose:** See courts geographically; tap a pin to preview, open detail.

**Layout:**
- **Full-bleed map** behind everything (in production: MapKit / MapLibre). In the prototype it's a
  stylized abstract Sydney — water, parks, roads, and place labels (Chatswood, Manly, Sydney,
  Parramatta, Bankstown). A faint green radial tint sits on top so glass reads.
- **Top chrome:** a legibility **scrim** (gradient, opaque at top → transparent ~100pt down) under:
  small "Smash" wordmark + green dot (left), and a **thick-glass "Filters" pill** (right) with a
  slider icon and a **red dot** when any filter is active. Tapping it reveals the full Filter bar
  beneath (same component as List).
- **Pins** (see Pin styles below). Dedicated = green, multi-sport = court grey. Selected pin
  scales up (~1.18) and gains a colored ring + elevated shadow.
- **Locate button:** ultra-thin glass circle (46×46), bottom-right, green nav icon. Sits above the
  tab bar (raises further when a preview card is shown).
- **Preview card** (on pin tap): a **thick-glass** card (radius 26) that rises from the bottom,
  positioned above the tab bar. Contents: court tile (62), name + Dedicated badge, "suburb · {dist} km",
  "From $X/hr" (green) + "{n} courts", a close ✕ (top-right), and a full-width green
  **"View venue ›"** button. Dismiss with ✕ or by switching pins.
- **Floating tab bar** (Map active).

### 3. Venue Detail
**Purpose:** Full venue info + booking.

**Layout (scrollable):**
1. **Hero** (height 330): full-bleed gradient — dedicated → green (`#19D680 → #0A6E42`), multi-sport →
   grey (`#3a4046 → #15181b`) — overlaid with court-line strokes, halftone, and an oversized faint
   initial watermark. Gradient scrims top (for status-bar legibility) and bottom (fades into page).
   Top chrome: a back chevron glass pill (left), star + share glass pills (right) — all "light"
   tinted (white icons over the hero).
2. **Title card** — a **thick-glass** card (radius 26) overlapping the hero bottom by ~56pt:
   - Row: Dedicated badge (if any) + "★ 4.8 · 212 reviews".
   - Venue **name** (Title, 26/850, -1 tracking).
   - **Address** with a pin icon (Body, secondary).
   - Three stat tiles (flex, equal width, chip-bg, radius 14): "8 courts", "From $29/hr",
     "10 km away" — each an icon (green) above a 12.5/700 label.
3. **Court hire rates** — section title (icon + "Court hire rates", 18/800), then a **regular-glass**
   card (radius 22). Each **rate row:** label (16/750) + optional note pill (e.g. "Most popular",
   green on light-green), "days · time range" (Caption, secondary) on the left; **price** `$34`
   (19/850, green) + `/hr` on the right. Rows separated by hairlines.
4. **Opening hours** — section title (clock icon), regular-glass card. Seven rows Mon→Sun:
   day name (left, **today** is bolded with a green dot + "Today" pill) and hours or "**Closed**"
   (Closed shown in red).
5. **Floating CTA** (pinned bottom, over a page-color scrim): a **thick-glass** bar (radius 22)
   holding a "FROM / $29/hr" block (left) and a full-width green **"Book a court ›"** button (right,
   height 54). Triggers a haptic; in production this deep-links to the booking provider.

### States (List)
- **Loading:** a spinner + "Finding courts near you…" then 4 **skeleton cards** (glass card with
  shimmering placeholder blocks). Shimmer = 1.5s linear gradient sweep.
- **Empty** ("No venues match your filters"): centered — a glass rounded-square (96) with a halftone
  fill + green **badminton/shuttlecock** icon, a Title heading, a secondary explanation, and a green
  **"Reset filters"** button.
- **Error** ("Couldn't load courts"): same layout, red info icon + halftone, secondary copy
  ("Check your connection… Your filters have been saved."), and a light **"Try again"** button with
  a refresh icon.

---

## Interactions & behavior
- **Filters** are live — changing any chip/switch immediately re-filters and re-sorts (by distance,
  ascending). Filtering to 0 results shows the **Empty** state. Map preview clears on filter change.
- **Tab switch (List↔Map):** instant; the active capsule animates. Light haptic (6ms).
- **Open detail:** tap a card or "View venue". **Back** returns to the previous tab (List or Map).
- **Map pin tap:** toggles selection; selected pin scales + ring; preview card rises (spring).
- **Book a court / tab change:** fire `navigator.vibrate` (→ map to `UIImpactFeedbackGenerator`
  `.light`/`.medium` on iOS).
- **Theme toggle** (Light/Dark) and **Reduce Transparency** are demonstrated via an external harness
  ("dock") in the prototype — in production these follow the **system** appearance &
  `isReduceTransparencyEnabled`, not in-app controls.

### Animation / easing
- **Press:** `transform: scale(0.96)`, spring `cubic-bezier(.34,1.56,.64,1)` ~0.42s.
- **Segmented/tab thumb & switch knob:** spring `cubic-bezier(.34,1.4,.5,1)` ~0.42s/0.3s.
- **Card / preview entrance:** translateY(14→0), `cubic-bezier(.22,1,.36,1)` 0.5s (gate behind
  `prefers-reduced-motion: no-preference`; never animate opacity from 0 as the base state —
  base state must be visible).
- **Shimmer:** 1.5s linear infinite. **Spinner:** 0.8s linear.
- Respect **reduced motion**: disable entrance/loop animations.

---

## State management
Top-level state (see `App` in `Smash.html`):
- `tab`: `"list" | "map"`.
- `f`: filter object `{ dist: "any"|"5"|"10"|"20", price: "any"|"30"|"35"|"40", dedicated: bool }`.
- `detail`: selected venue object or `null` (drives the Detail cover).
- `state`: `"loading" | "ready" | "error"` (data-fetch lifecycle; initial load simulates ~1.5s).
- `theme`: `"light" | "dark"` (production: system). `rt`: reduced-transparency bool (production: system).
- Map-local: `sel` (selected pin id), `showFilters` (filter panel visibility).
- **Derived:** `venues = filter(f) sorted by distance`; `listState` = loading/error/empty/ready.
- **Persistence:** theme & rt persisted to storage in the prototype; in production read from the system.
- **Data fetching:** replace the simulated timeout with the real venues API; keep the loading/error
  states wired to the request lifecycle.

---

## Design tokens

### Brand color (theme-independent)
| Token | Hex | Use |
|---|---|---|
| `--green` | `#00B964` | Primary accent (prices, active, CTAs, dedicated) |
| `--green-bright` | `#19D680` | Gradient top / glow |
| `--green-deep` | `#0A6E42` | Gradient bottom / on-light text |
| `--green-ink` | `#053A23` | — |
| `--red` | `#E5392B` | BWF red — energy, alerts, active-filter dot, "Closed" |
| `--red-bright` | `#FF5A47` | Gradient top |
| `--red-deep` | `#9E1E14` | — |
| `--court` | `#6B7178` | Multi-sport grey (pins / tiles) |
| on-accent (text on green) | `#04190F` (dark) / `#FFFFFF` (light) | Text over green fills |

### Neutrals
| | Light | Dark |
|---|---|---|
| Text | `#16140F` | `#F4F2EC` |
| Text secondary | `rgba(34,31,26,.60)` | `rgba(236,233,225,.62)` |
| Text tertiary | `rgba(34,31,26,.38)` | `rgba(236,233,225,.38)` |
| Hairline | `rgba(20,18,15,.10)` | `rgba(255,255,255,.10)` |
| Page bg | `#E9E5DC` (cream) | `#0C0E0F` (charcoal) |
| Chip bg | `rgba(255,255,255,.55)` | `rgba(255,255,255,.08)` |

### Glass materials (3 levels)
Each = a translucent fill + background blur `saturate(180%)` + 0.5px border + top inner-sheen + drop shadow.
On iOS, map directly to system Materials.

| Level | Blur | Light fill | Dark fill | iOS Material | Used for |
|---|---|---|---|---|---|
| Ultra-thin | 16px | `rgba(255,255,255,.42)` | `rgba(60,66,70,.55)` | `.ultraThinMaterial` | chips, pills, compact rows, locate |
| Regular | 24px | `rgba(255,255,255,.60)` | `rgba(52,58,62,.72)` | `.regularMaterial` | venue cards, detail sections |
| Thick | 38px | `rgba(251,250,247,.82)` | `rgba(38,43,47,.85)` | `.thickMaterial` | filter bar, tab bar, CTA, preview, title card |

- **Glass border:** light `rgba(255,255,255,.70)`, dark `rgba(255,255,255,.16)`.
- **Inner sheen:** `inset 0 .75px 0` of light `rgba(255,255,255,.90)` / dark `rgba(255,255,255,.20)`.
- **Drop shadow:** light `0 1px 2px rgba(20,18,15,.05), 0 12px 34px rgba(20,18,15,.10)`;
  dark `0 2px 6px rgba(0,0,0,.40), 0 18px 44px rgba(0,0,0,.40)`.

### Reduced-transparency fallback (REQUIRED)
When the user enables Reduce Transparency, **every glass surface drops the blur** and uses a **solid**
fill (layout/contrast unchanged). On iOS: branch on `UIAccessibility.isReduceTransparencyEnabled`
(and observe `reduceTransparencyStatusDidChangeNotification`).

| Level | Light solid | Dark solid |
|---|---|---|
| Ultra-thin | `#F0EEE7` | `#1B1F21` |
| Regular | `#F6F4EF` | `#1E2325` |
| Thick | `#FBFAF7` | `#14181A` |

### Map surface colors (prototype stylization)
Land `#ECE7DA`/`#1B201F`, water `#BFE0E8`/`#16343C`, park `#D6E5C9`/`#1C2A1E`, road `#FBF8F0`/`#2A3033`
(light/dark). In production, theme MapKit/MapLibre toward these.

### Radii
`--r-chip / pill`: 999 · `--r-card`: 26 · `--r-section`: 22 · button: 18 · `--r-tile`: 15.

### Typography — SF Pro
Headers **SF Pro Display** (heavy), body/UI **SF Pro Text**. Negative tracking on large sizes.

| Role | Size / Weight | Tracking |
|---|---|---|
| Display (wordmark) | 34–40 / 850 | -1.6 to -2.0 |
| Title (venue name) | 26 / 850 | -1.0 |
| Headline (section / card name) | 18 / 800, 17 / 800 | -0.5 / -0.4 |
| Body | 17 / 600 | -0.2 |
| Subhead | 15 / 650 | -0.2 |
| Caption | 13 / 600 | 0 |
| Micro / label | 11 / 750, UPPERCASE | +0.5 |
| Price | 19–22 / 850, color green | -0.6 to -1.0 |

### Spacing & misc
Screen side padding 16–18pt · card gap 13pt · filter rows ~11pt gap · tap targets ≥ 44pt ·
tab bar floats 26pt above the bottom · status-bar/header always protected by a scrim for AA contrast.

### Shadows / glow
Green glow (badges/CTA/active tab): `0 2px 10px rgba(0,185,100,.40)` + `inset 0 1px 0 rgba(255,255,255,.4)`.
Active-filter indicator: 7px red dot.

---

## Iconography → SF Symbols
Line icons at ~2px stroke, `currentColor`. Suggested SF Symbol mapping:

| App icon | SF Symbol |
|---|---|
| list | `list.bullet` |
| map | `map` |
| pin | `mappin` / `mappin.circle` |
| nav (locate) | `location.fill` / `paperplane.fill` |
| sliders (filters) | `slider.horizontal.3` |
| dollar | `dollarsign` |
| courts | `sportscourt.fill` |
| clock | `clock` |
| share | `square.and.arrow.up` |
| star | `star.fill` |
| check | `checkmark` |
| x (close) | `xmark` |
| info | `info.circle` |
| retry | `arrow.clockwise` |
| bolt (dedicated) | `bolt.fill` |
| shuttle (empty state) | `figure.badminton` |
| chevron | `chevron.right` / `chevron.left` |

---

## Assets
- **No bitmap assets are required** — all graphics are CSS/SVG (gradients, halftone dot fields,
  badminton court-line strokes, oversized initials).
- **Halftone motif:** a dot field (radial-gradient dots, ~13px grid) faded with a radial mask;
  used in backdrops, court tiles, empty/error states, and pins. Recreate as a tiled pattern or
  Canvas/Metal layer.
- **Court-line motif:** a simplified badminton court (outer box, tram lines, service lines, net dash)
  — see `CourtLines` in `app/glass.jsx`. Pure strokes; reproduce as a vector.
- **Imagery placeholders:** the hero and card tiles are stand-ins for **real venue/court photography**
  — wire these to the venues' photo URLs.
- Brand accent evolved from the original `#00C853` to the BWF-court `#00B964`.

---

## Files in this bundle
- `Smash.html` — the interactive prototype (List, Map, Detail, all states, light/dark, reduced-transparency,
  tab bar, pin-style variations). Open in a browser; use the bottom "dock" to switch theme / pins / transparency.
- `Design System.html` — the style tile: color tokens, type scale, material levels, radii, iconography,
  the 3 venue-card variations, the 3 map-pin styles, controls, and accessibility notes.
- `app/system.css` — all design tokens + the glass material system + atoms (chips, switch, segmented,
  badge, button, skeleton) + reduced-transparency rules. **Start here for exact values.**
- `app/glass.jsx` — primitives: `Glass`, `Halftone`, `CourtLines`, `CourtTile`, `Backdrop`, `Phone`
  (device frame + status bar), `Segmented`, `Chip`, `Switch`, `GlassPill`, `TabBar`, and the `Icon` set.
- `app/data.jsx` — the venue dataset (names, suburbs, addresses, rates, opening hours, coordinates).
- `app/cards.jsx` — `VenueCard` (V1) + `VenueCardHero` (V2) + `VenueCardCompact` (V3), `FilterBar`,
  the three pins (`PinTeardrop`, `PinPrice`, `PinDot`) + `PinCluster`, `PreviewCard`, and the
  loading/empty/error states.
- `app/screens.jsx` — `ListScreen`, `MapScreen` (+ `MapBackdrop`), `DetailScreen`, `RateCard`.

### Component → file quick map
Tab bar `TabBar` (glass.jsx) · Filter bar `FilterBar` (cards.jsx) · Venue card `VenueCard` (cards.jsx) ·
Map pins `Pin*` (cards.jsx) · Detail `DetailScreen` (screens.jsx) · Glass material `Glass` + `.glass`
classes (glass.jsx / system.css) · Tokens (system.css).
