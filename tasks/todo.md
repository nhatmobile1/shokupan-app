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

### Phase 7: Bake Timer & Scheduling
- Multi-step timers (autolyse → bulk → proof → bake)
- Background notifications when timers complete
- Save timer presets per recipe
- Live Activities for active timers (iOS 16+)

### Phase 8: Enhanced Export & Sharing
- Export recipe as PDF with formatted layout
- Export/import recipes as JSON for backup
- Share to other Shokupan users
- Print-friendly recipe view

### Phase 9: Fermentation Calculator
- Desired Dough Temperature (DDT) calculator
- Proof time estimates based on temperature
- Friction factor calculator for mixer
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
Multi-step timer system for bread baking with background notifications and Live Activities.

### Todo Items

#### 7.1 Data Models
- [ ] Create `BakeTimer` SwiftData model (name, steps, recipe relationship)
- [ ] Create `TimerStep` model (name, duration, order, isRunning, startedAt)
- [ ] Create `TimerPreset` model for reusable timer templates
- [ ] Add optional `timerPreset` relationship to Recipe

#### 7.2 Timer Service
- [ ] Create `TimerManager` class (ObservableObject)
- [ ] Implement background timer with `UNUserNotificationCenter`
- [ ] Handle app backgrounding/foregrounding
- [ ] Persist timer state for app restarts
- [ ] Add haptic feedback on timer completion

#### 7.3 Timer UI - List View
- [ ] Create `TimerListView` for active/saved timers
- [ ] Add "Timers" tab to ContentView (4th tab)
- [ ] Show active timer with countdown
- [ ] List saved timer presets

#### 7.4 Timer UI - Detail/Running View
- [ ] Create `TimerDetailView` with step-by-step display
- [ ] Large countdown display for current step
- [ ] Progress indicator across all steps
- [ ] Pause/Resume/Skip/Reset controls
- [ ] Audio/vibration on step completion

#### 7.5 Timer UI - Create/Edit
- [ ] Create `AddTimerView` for new timer presets
- [ ] Add/remove/reorder steps
- [ ] Duration picker (hours, minutes)
- [ ] Quick presets (common bread timings)

#### 7.6 Recipe Integration
- [ ] Add "Start Timer" button to RecipeDetailView
- [ ] Option to attach timer preset to recipe
- [ ] Auto-suggest timer based on recipe instructions

#### 7.7 Notifications
- [ ] Request notification permissions
- [ ] Schedule local notifications for each step
- [ ] Custom notification sounds (optional)
- [ ] Notification actions (Pause, Skip to Next)

#### 7.8 Live Activities (iOS 16+)
- [ ] Create Live Activity for active timer
- [ ] Show on Lock Screen and Dynamic Island
- [ ] Update countdown in real-time
- [ ] Deep link back to app

### Files to Create
```
Shokupanios/
├── Models/
│   └── BakeTimer.swift          # Timer, TimerStep, TimerPreset models
├── Services/
│   └── TimerManager.swift       # Timer logic and notifications
├── Views/
│   └── Timers/
│       ├── TimerListView.swift
│       ├── TimerDetailView.swift
│       ├── AddTimerView.swift
│       └── TimerStepRow.swift
└── Widgets/
    └── TimerLiveActivity.swift  # Live Activity (separate target)
```

### Default Timer Presets
- **Quick Proof** - 1 hour bulk, 45 min final proof
- **Sourdough Day** - 30 min autolyse, 4 hr bulk (with folds), 1 hr proof, 45 min bake
- **Shokupan** - 1.5 hr bulk, 50 min proof, 35 min bake
- **Overnight Cold Proof** - 1 hr bulk, 12 hr cold proof, 45 min bake

### Technical Notes
- Use `TimeInterval` for durations
- Store `startedAt: Date?` to calculate remaining time on app relaunch
- Use `BGTaskScheduler` for background refresh if needed
- Live Activities require a Widget Extension target
