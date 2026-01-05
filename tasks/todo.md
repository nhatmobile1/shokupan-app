# Shokupan - Bread Baking App

## Completed Phases
- [x] Phase 1: Data models, SwiftData, basic views
- [x] Phase 2: Ingredient management, hydration calc, sections, cloning
- [x] Phase 3 & 4: iCloud sync, photos, tags
- [x] Phase 5: Recipe templates
- [x] Phase 6: UI Polish & Bug Fixes

---

## Changelog

### Session: January 2025 - UI Polish & Bug Fixes

#### Weight Display Fixes
- Fixed weight rounding: Changed from `Int()` truncation to proper `.rounded()`
- Updated weight precision to 1 decimal place (e.g., `12.5g` instead of `12g` or `12.45g`)
- Files updated: `RecipeDetailView.swift`, `RecipeListView.swift`, `AddRecipeView.swift`, `AddIngredientView.swift`

#### Swipe-to-Delete Implementation
- **Problem**: `ScrollView` + `LazyVStack` doesn't support `.swipeActions`
- **Solution**: Converted both `RecipeListView` and `TemplateListView` to use `List` instead
- Added swipe-to-delete for recipes (all) and templates (user templates only)
- Added delete confirmation alerts with "Are you sure?" messaging

#### Card UI Fixes
- **Double chevrons issue**: Cards had their own chevron + List's NavigationLink added disclosure indicator
  - Removed chevrons from `RecipeCard` and `TemplateCard`
  - Added `.buttonStyle(.plain)` to NavigationLinks to hide disclosure indicators
- **Cards not spanning full width**: NavigationLink inside List doesn't auto-expand
  - Added `.frame(maxWidth: .infinity, alignment: .leading)` to both card types
- Removed trash icon from `TemplateCard` (use swipe instead)

#### Code Changes Summary
| File | Changes |
|------|---------|
| `RecipeListView.swift` | ScrollView→List, swipeActions, delete alert, card width fix |
| `TemplateListView.swift` | ScrollView→List, swipeActions, delete alert, card width fix |
| `RecipeDetailView.swift` | formatWeight with 1 decimal |
| `AddRecipeView.swift` | Added formatWeight function |
| `AddIngredientView.swift` | Added formatWeight function |

#### Project Reorganization
Reorganized flat file structure into organized folders:

```
Shokupanios/
├── ShokupaniosApp.swift      # App entry point
├── ContentView.swift         # Tab navigation
├── Assets.xcassets/          # App icons, colors, images
├── Models/
│   ├── Recipe.swift          # Recipe & Ingredient models
│   └── RecipeTemplate.swift  # Template models + seeding
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
│   └── Components/           # (empty - for shared components)
└── Design/
    └── Theme.swift           # Colors, fonts, spacing, modifiers
```

---

## Phase 5 Todo Items

### Template Models
- [x] Create RecipeTemplate model with TemplateIngredient
- [x] Add default built-in templates (Shokupan, Sourdough, Brioche, Focaccia, White Bread)
- [x] Add seeding logic for first launch

### Template Management UI
- [x] Create TemplateListView (built-in and user sections)
- [x] Create TemplateDetailView with clone functionality
- [x] Create AddTemplateView for new custom templates
- [x] Add delete confirmation for user templates

### Template Selection
- [x] Update AddRecipeView with template picker
- [x] Preview ingredients with calculated weights
- [x] Copy template ingredients to new recipe

### Navigation
- [x] Add tab bar with Recipes and Templates tabs

---

## Review

### Files Created
1. **RecipeTemplate.swift** - Template and TemplateIngredient models with:
   - `isBuiltIn` flag to protect default templates
   - `clone()` method for duplicating templates
   - `hydrationPercentage` computed property
   - `DefaultTemplates.seedTemplates()` for first-launch setup

2. **TemplateListView.swift** - Template management with:
   - Separate sections for built-in and user templates
   - Delete with confirmation alert (user templates only)
   - Checkmark seal icon for built-in templates

3. **TemplateDetailView.swift** - View/edit templates with:
   - Ingredient list grouped by section
   - Clone template option (creates user copy)
   - Add ingredient (user templates only)
   - Swipe to delete ingredients (user templates only)

4. **AddTemplateView.swift** - Create custom templates

### Files Modified
1. **ShokupaniosApp.swift**
   - Added RecipeTemplate and TemplateIngredient to schema
   - Seeds default templates on first launch

2. **ContentView.swift**
   - Added TabView with Recipes and Templates tabs

3. **AddRecipeView.swift**
   - Template picker to start from preset
   - Live preview of ingredients with calculated weights
   - Copies template ingredients to new recipe

### Default Templates
- **Shokupan** - Japanese milk bread with tangzhong (20% preferment)
- **Basic Sourdough** - 75% hydration with levain
- **Brioche** - Rich butter/egg enriched bread
- **Focaccia** - High hydration (80%) Italian flatbread
- **Basic White Bread** - Simple sandwich loaf

---

## Current App State

### Core Features Working
- ✅ Recipe CRUD with SwiftData persistence
- ✅ Baker's percentage calculations
- ✅ Ingredient sections (preferment, final dough, additions)
- ✅ Hydration percentage display
- ✅ Recipe templates (built-in and custom)
- ✅ Template-based recipe creation
- ✅ Swipe-to-delete with confirmation
- ✅ Photo attachments for recipes
- ✅ Tags and filtering
- ✅ Pan size presets (1 kin, 1.5 kin, 2 kin)
- ✅ Metric/Imperial unit toggle

### Design System
- Wabi-sabi aesthetic (warm, artisanal, imperfect)
- Custom fonts: Fraunces (serif), DM Sans (body), DM Mono (numbers)
- Warm color palette: panCream, flourWhite, crustBrown, terracotta, inkBrown
- Components: warmCard, tagChip, WarmDivider, EmptyStateView

### Key Files Reference
| Purpose | File |
|---------|------|
| App entry & SwiftData setup | `ShokupaniosApp.swift` |
| Tab navigation | `ContentView.swift` |
| Recipe list | `Views/Recipes/RecipeListView.swift` |
| Recipe details | `Views/Recipes/RecipeDetailView.swift` |
| Add/edit recipe | `Views/Recipes/AddRecipeView.swift` |
| Add ingredient | `Views/Recipes/AddIngredientView.swift` |
| Template list | `Views/Templates/TemplateListView.swift` |
| Template details | `Views/Templates/TemplateDetailView.swift` |
| Add template | `Views/Templates/AddTemplateView.swift` |
| Settings | `Views/Settings/SettingsView.swift` |
| Data models | `Models/Recipe.swift`, `Models/RecipeTemplate.swift` |
| Design system | `Design/Theme.swift`, `DESIGN_SYSTEM.md` |

### Pending/Future Ideas
- [ ] Bake timer integration
- [ ] Recipe scaling calculator
- [ ] Export/share recipes
- [ ] Recipe version history
- [ ] Fermentation temperature calculator
