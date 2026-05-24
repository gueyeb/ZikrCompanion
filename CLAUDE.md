# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Native iOS app (SwiftUI, iOS 17+) for daily dhikr discipline. Offline-first, no backend, no SPM/CocoaPods dependencies. Single Xcode project at `ZikrCompanion/ZikrCompanion.xcodeproj`.

## Commands

```bash
# Open in Xcode (preferred for running on simulator)
open ZikrCompanion/ZikrCompanion.xcodeproj

# CLI build
xcodebuild -project ZikrCompanion/ZikrCompanion.xcodeproj \
           -scheme ZikrCompanion \
           -destination 'platform=iOS Simulator,name=iPhone 16' \
           build

# CLI test (no test target exists yet)
xcodebuild -project ZikrCompanion/ZikrCompanion.xcodeproj \
           -scheme ZikrCompanion \
           -destination 'platform=iOS Simulator,name=iPhone 16' \
           test
```

## Architecture

**State flow:** `ZikrCompanionApp` creates a single `SessionStore` as `@StateObject` and injects it app-wide via `@EnvironmentObject`. All views read from it — no local state for business logic.

**`SessionStore`** (`Store/SessionStore.swift`) — `@MainActor ObservableObject`, the only source of truth. Persists everything to `UserDefaults` (keys prefixed `zc_`). Key invariant: streak increment is idempotent — fires at most once per calendar day, checked against `zc_lastSessionDate`.

**`ContentView`** — `TabView` root (counter tab + settings tab). Presents `NiyyaView` as a `.medium` sheet. Calls `NotificationManager.shared.rescheduleIfNeeded` in `.task` on every cold launch.

**`AppTheme`** (`AppTheme.swift`) — all design tokens as static properties on a caseless enum: gold `#C9A96E`, background `#0A0A0F`, surface `#13131A`. Always use these; never hardcode colors or spacing.

**`NotificationManager`** — `@MainActor` singleton. Schedules a single repeating `UNCalendarNotificationTrigger` with identifier `zc.daily.reminder`. Replaces the previous request on each reschedule.

**`ZikrItem` / `RoutineType`** (`Models/ZikrItem.swift`) — `RoutineType` drives the counter target (morning ×100, evening ×33). Hardcoded catalogues live in `ZikrItem.morningItems` / `ZikrItem.eveningItems`.

## Product rules

- Never use the word **wird** in UI strings.
- Streak is **idempotent**: max 1 increment per calendar day — do not change this logic.
- **Dark mode only** — `preferredColorScheme(.dark)` is set at the root and must not be overridden.
- **Offline-first** — no network calls in V1.
- Linear project: [Zikr Companion](https://linear.app/dakhine/project/zikr-companion-d5848c400cc6) — team **DAK**.
