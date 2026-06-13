# ADR-0001: React Native (Expo) over native iOS/Android

**Status:** Superseded by [ADR-0010](0010-native-ios-swiftui.md)

## Context

Need a cross-platform mobile app with home screen widget support. The team (currently solo) has strong React/TypeScript background and limited native iOS/Android experience.

## Decision

Use React Native with Expo managed workflow.

## Consequences

- Faster iteration and a shared codebase for ~90% of the app.
- Android widget achievable via `react-native-android-widget`.
- iOS widget requires a native Swift extension regardless (WidgetKit constraint, not an RN limitation) — scoped as a separate task. See ADR-0004.
- Drop to bare Expo workflow only if a widget library requires it.
