# Bread Baking App - Development Guide

## Project Overview
Building an iOS app to manage bread recipes using baker's percentages, with experiment tracking and notes.

## Current Status
- ✅ Xcode installed
- ✅ New iOS project created
- 🎯 Ready to start building

---

## Phase 1: Initial Setup & Basic Structure

### Step 1: Project Configuration
In Xcode, make sure your project settings are:
- **Deployment Target**: iOS 17.0 or later (to use SwiftData)
- **Interface**: SwiftUI
- **Language**: Swift
- **Storage**: SwiftData (if available in template, otherwise we'll add it)

### Step 2: Create Your Data Models

Create a new Swift file called `Recipe.swift` in your project.

This will be your core data structure. Here's what we need:

```swift
import Foundation
import SwiftData

@Model
class Recipe {
    var name: String
    var totalFlourGrams: Double
    var createdDate: Date
    var lastModifiedDate: Date
    var notes: String
    var rating: Int?
    var ingredients: [Ingredient]
    
    init(name: String, totalFlourGrams: Double = 250.0, notes: String = "", rating: Int? = nil) {
        self.name = name
        self.totalFlourGrams = totalFlourGrams
        self.createdDate = Date()
        self.lastModifiedDate = Date()
        self.notes = notes
        self.rating = rating
        self.ingredients = []
    }
}

@Model
class Ingredient {
    var name: String
    var percentage: Double  // Baker's percentage (e.g., 0.7 for 70%)
    var section: IngredientSection
    
    init(name: String, percentage: Double, section: IngredientSection = .finalDough) {
        self.name = name
        self.percentage = percentage
        self.section = section
    }
    
    // Calculated property for weight in grams
    func weight(basedOn totalFlour: Double) -> Double {
        return totalFlour * percentage
    }
}

enum IngredientSection: String, Codable {
    case yudane = "Yudane"
    case tangzhong = "Tangzhong"
    case finalDough = "Final Dough"
    case other = "Other"
}
```

### Step 3: Set Up SwiftData in Your App

Find your main app file (probably `[YourAppName]App.swift`).

Update it to include SwiftData:

```swift
import SwiftUI
import SwiftData

@main
struct BreadBakingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Recipe.self, Ingredient.self])
    }
}
```

### Step 4: Create Recipe List View

Create a new SwiftUI file called `RecipeListView.swift`:

```swift
import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recipes: [Recipe]
    @State private var showingAddRecipe = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(recipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        VStack(alignment: .leading) {
                            Text(recipe.name)
                                .font(.headline)
                            Text("\(Int(recipe.totalFlourGrams))g flour base")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if !recipe.notes.isEmpty {
                                Text(recipe.notes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteRecipes)
            }
            .navigationTitle("My Recipes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddRecipe = true }) {
                        Label("Add Recipe", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView()
            }
        }
    }
    
    private func deleteRecipes(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(recipes[index])
        }
    }
}
```

### Step 5: Create Add Recipe View

Create `AddRecipeView.swift`:

```swift
import SwiftUI
import SwiftData

struct AddRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var totalFlourGrams = 250.0
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Recipe Details") {
                    TextField("Recipe Name", text: $name)
                    
                    HStack {
                        Text("Total Flour (g)")
                        Spacer()
                        TextField("Grams", value: $totalFlourGrams, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRecipe()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveRecipe() {
        let newRecipe = Recipe(name: name, totalFlourGrams: totalFlourGrams, notes: notes)
        modelContext.insert(newRecipe)
        dismiss()
    }
}
```

### Step 6: Create Recipe Detail View (Simple Version)

Create `RecipeDetailView.swift`:

```swift
import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Bindable var recipe: Recipe
    
    var body: some View {
        List {
            Section("Details") {
                HStack {
                    Text("Total Flour")
                    Spacer()
                    Text("\(Int(recipe.totalFlourGrams))g")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Created")
                    Spacer()
                    Text(recipe.createdDate.formatted(date: .abbreviated, time: .omitted))
                        .foregroundColor(.secondary)
                }
            }
            
            if !recipe.notes.isEmpty {
                Section("Notes") {
                    Text(recipe.notes)
                }
            }
            
            Section("Ingredients") {
                if recipe.ingredients.isEmpty {
                    Text("No ingredients yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(recipe.ingredients) { ingredient in
                        HStack {
                            Text(ingredient.name)
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("\(Int(ingredient.percentage * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(Int(ingredient.weight(basedOn: recipe.totalFlourGrams)))g")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
```

### Step 7: Update ContentView

Replace the content in `ContentView.swift` with:

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        RecipeListView()
    }
}
```

---

## Testing Your First Build

1. **Build and Run**: Click the Play button in Xcode (or Cmd+R)
2. **Add a Recipe**: Click the + button, enter "Shokupan Test" with 250g flour
3. **View It**: Tap on the recipe to see details

You now have a working app that can:
- ✅ Create recipes
- ✅ Store them persistently (SwiftData)
- ✅ View recipe details
- ✅ Delete recipes

---

## Next Steps (Phase 2)

Once this is working, we'll add:

1. **Ingredient Management**: Add/edit ingredients with percentages
2. **Calculator View**: Live calculation of weights based on percentages
3. **Section Support**: Yudane, Tangzhong, Final Dough sections
4. **Hydration Calculation**: Auto-calculate total hydration
5. **Recipe Cloning**: Duplicate recipes for experiments

---

## Common Issues & Solutions

### "Cannot find 'Recipe' in scope"
- Make sure `Recipe.swift` is added to your target (check the file inspector)

### SwiftData errors
- Ensure deployment target is iOS 17.0+
- Check that `.modelContainer` is in your App file

### Preview crashes
- Add sample data to your previews
- Use `@Previewable` for SwiftData previews

### Build errors
- Clean build folder: Product → Clean Build Folder (Cmd+Shift+K)
- Restart Xcode if needed

---

## File Structure Reference

```
YourApp/
├── YourAppApp.swift          # Main app entry point
├── ContentView.swift         # Root view
├── Models/
│   └── Recipe.swift         # Data models
├── Views/
│   ├── RecipeListView.swift
│   ├── RecipeDetailView.swift
│   └── AddRecipeView.swift
└── Assets.xcassets/
```

---

## Key Concepts to Understand

### @Model
SwiftData's way of marking a class as persistable. Automatically handles database operations.

### @Query
Fetches data from SwiftData. Auto-updates when data changes.

### @Bindable
Allows two-way data binding for SwiftData models.

### .modelContainer()
Tells SwiftUI which models to persist.

---

## Resources

- [Apple SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Hacking with Swift - SwiftData Tutorial](https://www.hackingwithswift.com/quick-start/swiftdata)
- [SwiftUI List Tutorial](https://developer.apple.com/tutorials/swiftui/building-lists-and-navigation)

---

## Your Excel → App Feature Mapping

| Excel Feature | App Equivalent | Status |
|--------------|----------------|---------|
| Multiple sheets (recipes) | Recipe List | ✅ Phase 1 |
| Ingredient + % columns | Ingredient model | ✅ Phase 1 |
| Weight calculation | `.weight()` method | ✅ Phase 1 |
| Notes column | Recipe.notes | ✅ Phase 1 |
| Yudane/Final Dough sections | IngredientSection enum | ✅ Phase 1 |
| Copying sheets for experiments | Clone recipe feature | 🔜 Phase 2 |
| Multiple experiments | Recipe versioning | 🔜 Phase 2 |
| Photos | Photo support | 🔜 Phase 3 |
| Hydration calculation | Auto-calc | 🔜 Phase 2 |

---

## Questions? Next in Claude Code

When you switch to Claude Code, you can:
- Ask for help implementing any of these features
- Debug specific errors you're seeing
- Request explanations of SwiftUI/SwiftData concepts
- Get help with UI improvements
- Add new features

**Pro tip**: Take screenshots of your Xcode errors and share them - makes debugging much easier!
