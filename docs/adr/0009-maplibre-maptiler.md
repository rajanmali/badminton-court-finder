# ADR-0009: MapLibre + Maptiler for maps (not react-native-maps + Google Maps)

**Status:** Accepted

## Context

The venue list has a map toggle showing venue pins. A mapping library is required. The original assumption was `react-native-maps` with Google Maps, which requires a Google Cloud project, billing account, Maps SDK for Android, Maps SDK for iOS, and Places API enabled — with API keys restricted per bundle ID.

## Decision

Use `@maplibre/maplibre-react-native` as the map renderer, with Maptiler as the tile provider.

- **MapLibre** — open-source renderer (fork of Mapbox GL), no proprietary SDK, same on iOS and Android.
- **Maptiler** — OSM-based tile provider. Free tier: 100,000 tile requests/month. One account, one API key, no per-platform restrictions.

## Rationale

Phase 1 only needs to display ~20 static venue pins. Google Maps adds significant account overhead (Google Cloud Console, billing account, API key restrictions by bundle ID) for a feature that doesn't need any Google-specific capabilities (no Street View, no Google Places autocomplete in Phase 1).

MapLibre + Maptiler removes Google as a dependency entirely. If Google Places search is needed in Phase 2+ (e.g. "search venues near an address"), it can be evaluated then — by that point there's a concrete use case to justify the overhead.

## Consequences

- No Google Maps API key needed. No Google Cloud project.
- Maptiler account required (free tier sufficient for Phase 1 and likely Phase 2–3).
- `@maplibre/maplibre-react-native` is the map library; `react-native-maps` is not used.
- Tile URL constructed in `app.config.js` using `MAPTILER_API_KEY` env var.
- If Google Places-style geocoding is needed later, options include Maptiler Geocoding API (OSM-based) or introducing Google Places API at that point.
