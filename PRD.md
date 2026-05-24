# Zikr Companion PRD

## Product Intent
Zikr Companion is an offline-first iOS app for building a consistent daily dhikr habit. It is a personal discipline tool, not a spiritual guide replacement and not a content-sharing platform.

## Phase 1 Goal
Ship a usable solo experience on iPhone for daily personal use.

## Target V1 Scope
| Feature | Target | Current Status | Notes |
|---|---|---|---|
| Morning routine | `x100` routine | Implemented | `RoutineType.morning` with target `100` |
| Evening routine | `x33` routine | Implemented | `RoutineType.evening` with target `33` |
| Tap counter | Large tap target, progress ring, remaining count | Implemented | `CounterView.swift` |
| Haptic feedback | Light tactile feedback on tap | Implemented | `UIImpactFeedbackGenerator` in `CounterView.swift` |
| Session completion | Visual success state when target reached | Implemented | Completion overlay and success color |
| Daily streak | Max 1 increment per day, persisted | Implemented | `SessionStore.completeSession()` is idempotent |
| Niyya screen | Intention screen before session | Implemented | Enforced before first tap (non-dismissible); voluntary mid-session via button |
| Daily reminder | Local notification with configurable time | Implemented | `SettingsView` + `NotificationManager` |
| Offline persistence | Save progress/settings locally | Implemented | `UserDefaults`, no backend |
| Zikr cards | Arabic, transliteration, translation | Implemented | Static content in `ZikrItem.swift` |
| Dark theme | Consistent app theme | Implemented | Forced dark mode in `ZikrCompanionApp.swift` |
| Device build/distribution | Run on iPhone and prepare TestFlight | In progress | Current blocker is signing/provisioning |
| Automated tests | Cover streak/persistence logic | Partial | `SessionStoreTests.swift` written; test target must be added in Xcode |

## Current Product Rules
- No use of the word `wird` in the UI.
- Offline-first in V1.
- One streak increment maximum per calendar day.
- No backend, auth, sync, or social features in Phase 1.

## Immediate Gaps To Develop
1. Fix Xcode signing so the app runs on device and can move toward TestFlight (DAK-156).
2. Add Unit Testing Bundle target in Xcode and wire `ZikrCompanionTests/SessionStoreTests.swift` to it.
3. Add a lightweight release checklist for device verification, notifications, and first-launch behavior.

## Out of Scope For V1
- User accounts
- Cloud sync
- Shared groups or community features
- Remote content delivery
