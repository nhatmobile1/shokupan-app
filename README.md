# Shokupan - Bread Baking App

A SwiftUI iOS app for bread bakers to manage recipes, calculate baker's percentages, and create from templates.

## Features

### Recipe Management
- Create, edit, and delete bread recipes
- Organize ingredients by section (preferment, final dough, additions)
- Automatic baker's percentage calculations
- Hydration percentage display
- Photo attachments for recipes
- Tags for organization and filtering

### Templates
- 5 built-in templates: Shokupan, Sourdough, Brioche, Focaccia, White Bread
- Create custom templates
- Clone and modify templates
- Start new recipes from any template with calculated weights

### Calculations
- Baker's percentages (flour = 100%)
- Hydration calculation across all sections
- Pan size presets (1 kin, 1.5 kin, 2 kin)
- Weight scaling from templates

### Settings
- Metric/Imperial unit toggle
- iCloud sync support

## Design

Wabi-sabi aesthetic with warm, artisanal styling:
- **Colors**: Pan Cream, Flour White, Crust Brown, Terracotta, Ink Brown
- **Fonts**: Fraunces (serif headings), DM Sans (body), DM Mono (numbers)

## Project Structure

```
Shokupanios/
├── ShokupaniosApp.swift      # App entry point & SwiftData setup
├── ContentView.swift         # Tab navigation
├── Assets.xcassets/          # App icons, colors, images
├── Models/
│   ├── Recipe.swift          # Recipe & Ingredient models
│   └── RecipeTemplate.swift  # Template models + default seeding
├── Views/
│   ├── Recipes/
│   │   ├── RecipeListView.swift
│   │   ├── RecipeDetailView.swift
│   │   ├── AddRecipeView.swift
│   │   └── AddIngredientView.swift
│   ├── Templates/
│   │   ├── TemplateListView.swift
│   │   ├── TemplateDetailView.swift
│   │   └── AddTemplateView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Components/
└── Design/
    └── Theme.swift           # Colors, fonts, spacing, modifiers
```

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Tech Stack

- **SwiftUI** - Declarative UI
- **SwiftData** - Persistence and iCloud sync
- **PhotosUI** - Photo picker integration

## Default Templates

| Template | Description | Hydration |
|----------|-------------|-----------|
| Shokupan | Japanese milk bread with tangzhong | ~65% |
| Basic Sourdough | Traditional sourdough with levain | 75% |
| Brioche | Rich butter and egg enriched bread | ~55% |
| Focaccia | High hydration Italian flatbread | 80% |
| Basic White Bread | Simple sandwich loaf | 65% |

## License

Private project.
