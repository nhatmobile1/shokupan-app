# Bread Baking App - Phase 5: Recipe Templates

## Completed Phases
- [x] Phase 1: Data models, SwiftData, basic views
- [x] Phase 2: Ingredient management, hydration calc, sections, cloning
- [x] Phase 3 & 4: iCloud sync, photos, tags
- [x] Phase 5: Recipe templates

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
