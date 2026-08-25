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
| Haptic feedback | Light tactile feedback on tap | Implemented | SwiftUI `sensoryFeedback` in both counter modes |
| Session completion | Visual success state when target reached | Implemented | Completion overlay and success color |
| Daily streak | Max 1 increment per day, persisted | Implemented | `SessionStore.completeSession()` is idempotent |
| Niyya screen | Intention screen before session | Implemented | Enforced before first tap (non-dismissible); voluntary mid-session via button |
| Daily reminder | Local notification with configurable time | Implemented | `SettingsView` + `NotificationManager` |
| Offline persistence | Save progress/settings locally | Implemented | `UserDefaults`, no backend |
| Local history | Keep completed sessions by routine on device | Implemented | `SessionRecord` encoded in `UserDefaults` |
| Zikr cards | Arabic, transliteration, translation | Implemented | Static content in `ZikrItem.swift` |
| Dark theme | Consistent app theme | Implemented | Forced dark mode in `ZikrCompanionApp.swift` |
| Device build/distribution | Run on iPhone and prepare TestFlight | In progress | Current blocker is signing/provisioning |
| Automated tests | Cover streak/persistence/history logic | Implemented | Shared test scheme, 18 deterministic unit tests |
| Accessibility | VoiceOver, Dynamic Type, Reduce Motion | Implemented | Accessible controls and adjustable scroll counter |
| Brand assets | Default, dark and tinted app icons | Implemented | App icon set + in-app brand mark |

## Current Product Rules
- No use of the word `wird` in the UI.
- Offline-first in V1.
- One streak increment maximum per calendar day.
- No backend, auth, sync, or social features in Phase 1.

## Immediate Gaps To Develop
1. Fix Xcode signing so the app runs on device and can move toward TestFlight (DAK-156).
2. Validate the Arabic, transliteration and French content with a trusted human reviewer.
3. Execute the release checklist on a physical iPhone before archiving.

## Out of Scope For V1
- User accounts
- iCloud backup and cross-device sync (planned after V1)
- Shared groups or community features
- Remote content delivery
