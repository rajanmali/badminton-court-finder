# ADR-0010: Native iOS (Swift/SwiftUI) rewrite, superseding ADR-0001

**Status:** Accepted
**Supersedes:** [ADR-0001](0001-react-native-expo.md)

## Context

The Expo/React Native iOS build required escalating native workarounds: config plugins forcing React Native to build from source, and Podfile patches to wire MapLibre's SPM framework into Expo's generated Podfile (see branch `fix/ios-build-plugins`). The friction of bending Expo's managed workflow to accommodate native map integration, combined with iOS being the priority platform, prompted reconsidering ADR-0001's cross-platform choice. The app is small (2 screens — venue list + detail) and pre-launch, so the rewrite cost is at its lowest.

## Decision

Rewrite the mobile app as a native iOS app in Swift/SwiftUI under `apps/ios/`, iOS-first. Android is deferred until the product shows traction; if built, it would be a separate native app, not a shared codebase.

Specific technical choices:

- **Minimum deployment target: iOS 26** (latest; the app is pre-launch with no existing user base to support).
- **Swift 6.2 language mode** with default-MainActor isolation (`SWIFT_DEFAULT_ACTOR_ISOLATION: MainActor`); `@preconcurrency import` as the escape hatch for third-party frameworks.
- **XcodeGen** generates the Xcode project from a committed `project.yml`; the generated `.xcodeproj` is gitignored. A checked-in `.pbxproj` is a constant merge-conflict and tooling-corruption surface; folder-based source definitions keep project plumbing out of every PR.
- **Swift Package Manager only** for dependencies, each pinned to an exact version in `project.yml`: MapLibre Native iOS (`maplibre-gl-native-distribution`) for maps; `sentry-cocoa` for error tracking (added at release prep). No CocoaPods.
- **No client-side stale-cache layer** replacing React Query: the view model's lifetime inside the SwiftUI `NavigationStack` already preserves fetched list data across push/pop, which is what React Query's 60s `staleTime` was buying. `URLSession` async/await with a retry-2 policy in the API client covers the rest.

## Consequences

- The full app (networking, models, two screens, map, location, filters) is reimplemented in Swift; behavior is pinned by porting the existing Jest test suites to Swift Testing so parity is verifiable.
- Android support is dropped for now; the planned Phase 3 Android widget and any Android app become future separate-codebase work.
- The iOS widget (Phase 4, ADR-0004) becomes a natural extension of a native codebase rather than a bolted-on Swift sub-project alongside React Native.
- Expo/EAS tooling is decommissioned; builds go through Xcode/TestFlight directly. The `com.rajanmali.smash` bundle ID and existing App Store Connect identity are reused.
- `@maplibre/maplibre-react-native` (ADR-0009) is replaced by MapLibre Native iOS directly; the MapLibre + Maptiler decision itself (open renderer + OSM tiles) still stands — only the binding changes.
- The React Native app and its mobile-only packages (`packages/api-client`, `packages/ui`) are removed once the Swift app passes a screen-by-screen parity gate.
