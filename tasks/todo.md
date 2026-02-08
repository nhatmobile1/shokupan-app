# Shokupan - Bread Baking App

## Completed Phases
- [x] Phase 1: Data models, SwiftData, basic views
- [x] Phase 2: Ingredient management, hydration calc, sections, cloning
- [x] Phase 3 & 4: iCloud sync, photos, tags
- [x] Phase 5: Recipe templates
- [x] Phase 6: UI Polish & Bug Fixes
- [x] Phase 7: Bake Timer & Scheduling (except Live Activities)
- [x] DDT Calculator (from Phase 9 roadmap)

---

## Changelog

### Session: February 2026 - Phase 7 Completion + DDT Calculator

#### Phase 7.6: Recipe-Timer Integration
- Added `timerPresetName: String?` to Recipe model (lightweight link by name)
- Timer section in RecipeDetailView: shows linked timer, "Start Timer" button, change/remove menu
- TimerPresetPickerSheet: reusable picker for choosing timer presets
- Timer preset picker in AddRecipeView with auto-suggest matching by template name
- Updated Recipe.clone() to preserve timer preset link

#### Phase 7.7: Notification Actions
- Registered UNNotificationCategory with "Pause" and "Next Step" actions
- Added AppDelegate with UNUserNotificationCenterDelegate for handling action responses
- Foreground notification presentation (banner + sound)
- Routes notification actions to TimerManager.shared

#### DDT Calculator
- New DDTCalculatorView: calculates water temperature from DDT formula
  - Supports straight dough (3×) and preferment (4×) formulas
  - Pre-fills defaults from Settings
  - Temperature warnings for extreme values
  - Formula breakdown display
  - Educational info section
- Settings: new "Dough Temperature" section with default DDT, friction factor, mixing method picker
- MixingMethod enum: Hand (7°F/4°C), Stand Mixer (22°F/12°C), Spiral Mixer (30°F/17°C)
- Integrated into RecipeDetailView as "Dough Temperature" section
- Auto-detects preferment from recipe ingredients

#### Files Modified
| File | Changes |
|------|---------|
| `Models/Recipe.swift` | Added `timerPresetName`, updated init and clone |
| `Views/Recipes/RecipeDetailView.swift` | Timer section, DDT section, TimerPresetPickerSheet, picker states |
| `Views/Recipes/AddRecipeView.swift` | Timer preset picker, auto-suggest on template selection |
| `Services/TimerManager.swift` | Notification category + actions, handleNotificationAction() |
| `ShokupaniosApp.swift` | AppDelegate for notification handling |
| `Views/Settings/SettingsView.swift` | DDT defaults section, MixingMethod enum |

#### Files Created
| File | Purpose |
|------|---------|
| `Views/Recipes/DDTCalculatorView.swift` | DDT water temperature calculator |

---

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
- ✅ Multi-step bake timers (5 built-in presets)
- ✅ Timer controls: start/pause/resume/skip/reset
- ✅ Recipe-timer integration (link presets, start from recipe)
- ✅ Background notifications with Pause/Next actions
- ✅ DDT calculator (water temperature from room/flour/friction)
- ✅ Mixing method settings (hand, stand mixer, spiral)

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

---

## iOS Development Skill Review (January 2026)

### Overall Assessment: Good

**Strengths:**
- Clean, consistent code style with proper Swift conventions
- Proper SwiftData implementation with relationships and external storage
- Good UI/UX with accessibility features (Dynamic Type, VoiceOver labels)
- Well-organized file structure
- Effective use of SwiftUI's declarative patterns

**Areas for Improvement:**
1. Error handling - Many `try?` statements silently fail
2. One force unwrap at `RecipeDetailView.swift:602`
3. No ViewModels - Views handle business logic directly
4. No unit tests for calculation logic
5. `RecipeDetailView` is large (~900 lines, 25 @State properties)

**Recommendations:**
- Add error alerts when save/delete fails
- Replace force unwrap with safe alternative
- Consider ViewModels for testability if app grows
- Add unit tests for `hydrationPercentage` calculation

---

## Future Phases Roadmap

### Phase 7: Bake Timer & Scheduling ✅ (except Live Activities)
- ~~Multi-step timers (autolyse → bulk → proof → bake)~~ Done
- ~~Background notifications when timers complete~~ Done
- ~~Save timer presets per recipe~~ Done
- Live Activities for active timers (iOS 16+) — Deferred

### Phase 8: Enhanced Export & Sharing
- Export recipe as PDF with formatted layout
- Export/import recipes as JSON for backup
- Share to other Shokupan users
- Print-friendly recipe view

### Phase 9: Fermentation Calculator (Partially Done)
- ~~Desired Dough Temperature (DDT) calculator~~ Done
- ~~Friction factor calculator for mixer~~ Done (integrated in DDT)
- Proof time estimates based on temperature
- Yeast conversion (fresh ↔ instant ↔ active dry)

### Phase 10: Recipe History & Bake Log
- Track modifications to recipes over time
- "Bake log" - record each bake with results
- Photo gallery per recipe (multiple bakes)
- Compare different bakes side-by-side

### Phase 11: Advanced Features
- Recipe version history with diff view
- Ingredient inventory tracking
- Shopping list generation
- Nutrition information

### Phase 12: Social & Sync
- iCloud account sign-in
- Share recipes with friends
- Import recipes from URLs
- Community recipe browser

### Quick Wins (Anytime)
- [ ] Haptic feedback on button taps
- [ ] Spotlight search integration
- [ ] Widget for recent recipe or active timer
- [ ] Siri shortcuts
- [ ] iPad layout optimization
- [ ] watchOS companion for timers

---

## Phase 7: Bake Timer & Scheduling

### Overview
Multi-step timer system for bread baking with background notifications.

### Todo Items

#### 7.1 Data Models
- [x] Create `BakeTimer` SwiftData model (name, steps, recipe relationship)
- [x] Create `TimerStep` model (name, duration, order, isRunning, startedAt)
- [x] Create `TimerPreset` model for reusable timer templates
- [x] Add optional `timerPresetName` to Recipe model

#### 7.2 Timer Service
- [x] Create `TimerManager` class (@Observable singleton)
- [x] Implement background timer with `UNUserNotificationCenter`
- [x] Handle app backgrounding/foregrounding
- [x] Persist timer state for app restarts
- [x] Add haptic feedback on timer completion

#### 7.3 Timer UI - List View
- [x] Create `TimerListView` for active/saved timers
- [x] Add "Timers" tab to ContentView (4th tab)
- [x] Show active timer with countdown
- [x] List saved timer presets

#### 7.4 Timer UI - Detail/Running View
- [x] Create `TimerDetailView` with step-by-step display
- [x] Large countdown display for current step
- [x] Progress indicator across all steps
- [x] Pause/Resume/Skip/Reset controls
- [x] Audio/vibration on step completion

#### 7.5 Timer UI - Create/Edit
- [x] Create `AddTimerView` for new timer presets
- [x] Add/remove/reorder steps
- [x] Duration picker (hours, minutes)
- [x] Quick presets (common bread timings)

#### 7.6 Recipe Integration
- [x] Add "Start Timer" button to RecipeDetailView
- [x] Option to attach timer preset to recipe via name
- [x] TimerPresetPickerSheet for choosing presets
- [x] Auto-suggest matching timer when template selected in AddRecipeView
- [x] Timer preset picker in AddRecipeView

#### 7.7 Notifications
- [x] Request notification permissions
- [x] Schedule local notifications for each step
- [x] Notification actions (Pause, Next Step) via UNNotificationCategory
- [x] AppDelegate for handling notification responses
- [x] Foreground notification presentation

#### 7.8 Live Activities (Deferred)
- [ ] Create Live Activity for active timer
- [ ] Show on Lock Screen and Dynamic Island
- [ ] Requires Widget Extension target — deferred to future phase

---

## DDT Calculator (Desired Dough Temperature)

### Overview
Calculate the water temperature needed to hit a target dough temperature after mixing. Based on the classic DDT formula from King Arthur Baking and The Perfect Loaf.

### Formula
```
Water Temp = (Factor × DDT) - Room Temp - Flour Temp - Friction Factor
Factor = 3 (straight dough), 4 (with preferment, also subtracts preferment temp)
```

### Todo Items
- [x] Add DDT default settings to SettingsView (target DDT, friction factor, mixing method)
- [x] Create MixingMethod enum (Hand, Stand Mixer, Spiral) with friction factor values
- [x] Create DDTCalculatorView with inputs, result display, formula breakdown
- [x] Add preferment toggle (switches to 4-factor formula)
- [x] Add temperature warnings (too cold/too hot for yeast)
- [x] Integrate into RecipeDetailView as "Dough Temperature" section
- [x] Auto-detect preferment from recipe ingredients
- [x] Respect Metric/Imperial unit setting
- [x] Educational info section explaining DDT concepts
