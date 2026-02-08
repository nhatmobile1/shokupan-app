# Shokupan - Bread Baking iOS App

## Quick Context

A SwiftUI iOS app for bread bakers to manage recipes with baker's percentages, templates, and photos.

## Project Status

- **Phases 1-7 complete** - Core features, templates, UI polish, bake timers
- **DDT Calculator complete** - Desired dough temperature / water temp calculator
- **HIG compliant** - Dynamic Type, dark mode, accessibility
- **Next**: Phase 8 (Export/Sharing) or Phase 9 remainder (yeast conversion, proof time)

## Key Architecture

- **SwiftData** for persistence with iCloud sync
- **MVVM-ish** pattern with SwiftUI views
- **Custom design system** in `Design/Theme.swift`

## File Structure

```
Shokupanios/
├── Models/           # Recipe.swift, RecipeTemplate.swift, BakeTimer.swift
├── Services/         # TimerManager.swift
├── Views/
│   ├── Recipes/      # RecipeListView, RecipeDetailView, AddRecipeView, DDTCalculatorView
│   ├── Templates/    # TemplateListView, TemplateDetailView
│   ├── Timers/       # TimerListView, TimerDetailView, AddTimerView
│   └── Settings/     # SettingsView (includes MixingMethod enum)
├── Design/           # Theme.swift (colors, fonts, components)
└── tasks/            # todo.md (changelog & progress)
```

## Design System

- **Aesthetic**: Wabi-sabi (warm, artisanal, imperfect)
- **Colors**: panCream, flourWhite, crustBrown, terracotta, inkBrown
- **Fonts**: System rounded fonts with bakery naming
- **See**: `DESIGN_SYSTEM.md` for full reference

## Development Rules

See `claude-rules.md` for workflow:
1. Plan in `tasks/todo.md`
2. Work one task at a time
3. Keep changes minimal and simple
4. Document changes in review section

## Reference Docs

- `tasks/todo.md` - Changelog and current state
- `SKILL.md` - Apple HIG guidelines
- `DESIGN_SYSTEM.md` - Design tokens and components
- `BREAD_APP_GUIDE.md` - Bread baking domain knowledge

## Key Architecture Details

- **TimerManager**: `@MainActor @Observable` singleton (`TimerManager.shared`)
- **Recipe-Timer link**: `timerPresetName: String?` on Recipe (name-based, not relationship)
- **DDT settings**: Stored in AppStorage (`defaultDDT`, `defaultFrictionFactor`, `mixingMethod`)
- **MixingMethod enum**: Lives in `SettingsView.swift` (Hand, Stand Mixer, Spiral)
- **Notification actions**: Registered via `UNNotificationCategory` in TimerManager, handled by AppDelegate in `ShokupaniosApp.swift`

## Future Phases

- **Phase 7.8 (Deferred)**: Live Activities (requires Widget Extension target)
- **Phase 8**: Enhanced Export & Sharing (PDF, JSON)
- **Phase 9 (Partial)**: ~~DDT Calculator~~ Done — remaining: yeast conversion, proof time estimates
- **Phase 10**: Recipe History & Bake Log
- **Phase 11**: Advanced Features (inventory, shopping list)
- **Phase 12**: Social & Sync

See `tasks/todo.md` for detailed breakdown and iOS review notes.
