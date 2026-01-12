# Shokupan - Bread Baking iOS App

## Quick Context

A SwiftUI iOS app for bread bakers to manage recipes with baker's percentages, templates, and photos.

## Project Status

- **Phases 1-6 complete** - Core features, templates, UI polish
- **HIG compliant** - Dynamic Type, dark mode, accessibility
- **Current: Phase 7** - Bake Timer & Scheduling

## Key Architecture

- **SwiftData** for persistence with iCloud sync
- **MVVM-ish** pattern with SwiftUI views
- **Custom design system** in `Design/Theme.swift`

## File Structure

```
Shokupanios/
├── Models/           # Recipe.swift, RecipeTemplate.swift
├── Views/
│   ├── Recipes/      # RecipeListView, RecipeDetailView, AddRecipeView
│   ├── Templates/    # TemplateListView, TemplateDetailView
│   └── Settings/     # SettingsView
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

## Future Phases

- **Phase 7 (Current)**: Bake Timer & Scheduling
- **Phase 8**: Enhanced Export & Sharing (PDF, JSON)
- **Phase 9**: Fermentation Calculator (DDT, proof times)
- **Phase 10**: Recipe History & Bake Log
- **Phase 11**: Advanced Features (inventory, shopping list)
- **Phase 12**: Social & Sync

See `tasks/todo.md` for detailed breakdown and iOS review notes.
