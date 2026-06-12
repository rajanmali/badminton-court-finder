# ADR-0004: iOS widget deferred to its own phase

**Status:** Accepted

## Context

iOS WidgetKit requires a native Swift extension target. This is unavoidable regardless of whether the app uses React Native or native development — no cross-platform tooling can bypass it.

## Decision

Ship the Android widget first (Phase 3). The iOS widget is Phase 4, treated as a small standalone native sub-project with its own scoped timeline.

## Consequences

- Android users get the widget experience sooner.
- iOS app users have full app functionality from Phase 1 — only the widget is delayed, not the app itself.
- The iOS widget will share data via a shared app group container, reading the same local sync store the Android widget reads from.
- Budget the iOS widget as a separate mini-project requiring Swift knowledge.
