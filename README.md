# Zikr Companion

Application iOS native de discipline personnelle pour le dhikr quotidien.

## Positionnement

Assistant personnel de constance — pas un transmetteur de wird, pas un substitut au guide spirituel. Un outil simple pour ancrer une habitude quotidienne.

## Fonctionnalités V1

- **Routine matin** (×100) et **routine soir** (×33)
- Compteur tactile avec anneau de progression et retour haptique
- **Streak** journalier idempotent (1 incrément max/jour)
- Écran d'intention (Niyya) avant la session
- **Rappel local quotidien** configurable (heure libre)
- Persistance offline via UserDefaults — zéro backend
- Historique local des sessions terminées, séparé par routine
- Cartes de formules arabic/translitération/traduction

## Stack

| Couche | Choix |
|---|---|
| UI | SwiftUI (iOS 17+, Swift 6) |
| State | `ObservableObject` / `@EnvironmentObject` |
| Persistance | `UserDefaults` |
| Notifications | `UserNotifications` (local uniquement) |
| Backend | Aucun en V1 |

## Structure du projet

```
ZikrCompanion/
  AppTheme.swift          ← palette gold #C9A96E / bg #0A0A0F, typo, spacing
  ZikrCompanionApp.swift  ← @main entry point
  ContentView.swift       ← TabView root (Counter + Paramètres)
  Models/
    ZikrItem.swift        ← struct ZikrItem, enum RoutineType
    SessionRecord.swift   ← session terminée conservée localement
  Store/
    SessionStore.swift    ← ObservableObject, streak, UserDefaults
  Notifications/
    NotificationManager.swift
  Views/
    CounterView.swift     ← anneau de progression + bouton tap
    RoutineView.swift     ← sélecteur matin / soir
    StreakView.swift       ← flamme + jours consécutifs
    ZikrCardView.swift    ← carte arabic + translitération
    NiyyaView.swift       ← sheet d'intention
    SettingsView.swift    ← rappel + reset
    HistoryView.swift     ← historique local des routines terminées
```

## Vérification

```sh
xcodebuild -project ZikrCompanion/ZikrCompanion.xcodeproj \
  -scheme ZikrCompanion \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  test
```

La feuille de route détaillée se trouve dans [`ROADMAP.md`](ROADMAP.md).

## Phases

| Phase | Périmètre | Statut |
|---|---|---|
| **Phase 1** | Discipline solo — fiabilité, accessibilité, TestFlight | 🔨 En cours |
| **Phase 2** | Cercle proche — famille / dahira, feedback réel | ⏳ |
| **Phase 3** | Extension — contenu validé, partage optionnel | ⏳ |

## Règles produit

- Pas de mot **wird** dans l'UI (non transmis officiellement)
- Streak : **1 incrément maximum par jour** (idempotent)
- **Offline-first** — aucune dépendance réseau en V1
- Dark mode exclusif (thème appliqué via `.preferredColorScheme(.dark)`)

## Linear

Projet : [Zikr Companion](https://linear.app/dakhine/project/zikr-companion-d5848c400cc6) — team **DAK**

| Issue | Titre | Statut |
|---|---|---|
| DAK-152 | Setup projet Xcode + repo GitHub | ✅ Done |
| DAK-153 | StreakView + ZikrCardView | ✅ Done |
| DAK-154 | NotificationManager — rappel quotidien | ✅ Done |
| DAK-155 | Routine soir (RoutineType.evening, ×33) | ✅ Done |
| DAK-156 | TestFlight — build solo phase 1 | ⏳ Backlog |
