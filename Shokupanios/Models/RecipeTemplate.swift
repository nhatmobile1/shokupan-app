import Foundation
import SwiftData

@Model
class RecipeTemplate {
    var name: String
    var descriptionText: String
    var isBuiltIn: Bool
    var createdDate: Date
    @Relationship(deleteRule: .cascade) var ingredients: [TemplateIngredient]

    init(name: String, descriptionText: String = "", isBuiltIn: Bool = false) {
        self.name = name
        self.descriptionText = descriptionText
        self.isBuiltIn = isBuiltIn
        self.createdDate = Date()
        self.ingredients = []
    }

    /// Creates a clone of this template with a new name
    func clone(newName: String) -> RecipeTemplate {
        let cloned = RecipeTemplate(
            name: newName,
            descriptionText: descriptionText,
            isBuiltIn: false
        )
        for ingredient in ingredients {
            let clonedIngredient = TemplateIngredient(
                name: ingredient.name,
                percentage: ingredient.percentage,
                section: ingredient.section
            )
            cloned.ingredients.append(clonedIngredient)
        }
        return cloned
    }

    /// Total hydration percentage (water content / flour weight * 100)
    /// Accounts for water content in various ingredients:
    /// - Water: 100%
    /// - Milk (liquid, not powder): ~87%
    /// - Eggs: ~75%
    var hydrationPercentage: Double {
        var totalHydration = 0.0

        for ingredient in ingredients {
            let name = ingredient.name.lowercased()

            // Skip dry milk / milk powder - they don't contribute to hydration
            if name.contains("dry milk") || name.contains("milk powder") || name.contains("powdered milk") {
                continue
            }

            if name.contains("water") {
                totalHydration += ingredient.percentage * 1.0
            } else if name.contains("milk") {
                totalHydration += ingredient.percentage * 0.87
            } else if name.contains("egg") {
                totalHydration += ingredient.percentage * 0.75
            }
        }

        return totalHydration * 100
    }
}

@Model
class TemplateIngredient {
    var name: String
    var percentage: Double
    var sectionRawValue: String

    var section: IngredientSection {
        get { IngredientSection(rawValue: sectionRawValue) ?? .finalDough }
        set { sectionRawValue = newValue.rawValue }
    }

    init(name: String, percentage: Double, section: IngredientSection = .finalDough) {
        self.name = name
        self.percentage = percentage
        self.sectionRawValue = section.rawValue
    }
}

// MARK: - Default Templates
struct DefaultTemplates {
    // Increment this version number when built-in templates need to be refreshed
    private static let currentVersion = 2
    private static let versionKey = "builtInTemplatesVersion"

    static func seedTemplates(in context: ModelContext) {
        let savedVersion = UserDefaults.standard.integer(forKey: versionKey)

        // If version changed, delete old built-in templates
        if savedVersion != currentVersion {
            let descriptor = FetchDescriptor<RecipeTemplate>(
                predicate: #Predicate { $0.isBuiltIn == true }
            )
            if let existingTemplates = try? context.fetch(descriptor) {
                for template in existingTemplates {
                    context.delete(template)
                }
            }
            try? context.save()
        }

        // Check if templates already exist
        let descriptor = FetchDescriptor<RecipeTemplate>(
            predicate: #Predicate { $0.isBuiltIn == true }
        )
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0

        guard existingCount == 0 else { return }

        // Shokupan (Japanese Milk Bread)
        let shokupan = RecipeTemplate(
            name: "Shokupan",
            descriptionText: "Soft Japanese milk bread with yudane",
            isBuiltIn: true
        )
        shokupan.ingredients = [
            TemplateIngredient(name: "Flour", percentage: 0.20, section: .preferment),
            TemplateIngredient(name: "Water", percentage: 0.16, section: .preferment),
            TemplateIngredient(name: "Flour", percentage: 0.80, section: .finalDough),
            TemplateIngredient(name: "Water", percentage: 0.54, section: .finalDough),
            TemplateIngredient(name: "Dry Milk", percentage: 0.06, section: .finalDough),
            TemplateIngredient(name: "Sugar", percentage: 0.06, section: .finalDough),
            TemplateIngredient(name: "Honey", percentage: 0.03, section: .finalDough),
            TemplateIngredient(name: "Salt", percentage: 0.02, section: .finalDough),
            TemplateIngredient(name: "Unsalted Butter", percentage: 0.06, section: .finalDough),
            TemplateIngredient(name: "Instant Yeast", percentage: 0.014, section: .finalDough),
        ]
        context.insert(shokupan)

        // Basic Sourdough
        let sourdough = RecipeTemplate(
            name: "Basic Sourdough",
            descriptionText: "Classic sourdough with 75% hydration",
            isBuiltIn: true
        )
        sourdough.ingredients = [
            TemplateIngredient(name: "Flour", percentage: 0.20, section: .preferment),
            TemplateIngredient(name: "Water", percentage: 0.20, section: .preferment),
            TemplateIngredient(name: "Starter", percentage: 0.20, section: .preferment),
            TemplateIngredient(name: "Flour", percentage: 0.80, section: .finalDough),
            TemplateIngredient(name: "Water", percentage: 0.55, section: .finalDough),
            TemplateIngredient(name: "Salt", percentage: 0.02, section: .finalDough),
        ]
        context.insert(sourdough)

        // Brioche
        let brioche = RecipeTemplate(
            name: "Brioche",
            descriptionText: "Rich, buttery French bread",
            isBuiltIn: true
        )
        brioche.ingredients = [
            TemplateIngredient(name: "Flour", percentage: 1.0, section: .finalDough),
            TemplateIngredient(name: "Eggs", percentage: 0.50, section: .finalDough),
            TemplateIngredient(name: "Unsalted Butter", percentage: 0.50, section: .finalDough),
            TemplateIngredient(name: "Sugar", percentage: 0.10, section: .finalDough),
            TemplateIngredient(name: "Salt", percentage: 0.02, section: .finalDough),
            TemplateIngredient(name: "Milk", percentage: 0.10, section: .finalDough),
            TemplateIngredient(name: "Yeast", percentage: 0.03, section: .finalDough),
        ]
        context.insert(brioche)

        // Focaccia
        let focaccia = RecipeTemplate(
            name: "Focaccia",
            descriptionText: "Italian flatbread with high hydration",
            isBuiltIn: true
        )
        focaccia.ingredients = [
            TemplateIngredient(name: "Flour", percentage: 1.0, section: .finalDough),
            TemplateIngredient(name: "Water", percentage: 0.80, section: .finalDough),
            TemplateIngredient(name: "Olive Oil", percentage: 0.08, section: .finalDough),
            TemplateIngredient(name: "Salt", percentage: 0.02, section: .finalDough),
            TemplateIngredient(name: "Yeast", percentage: 0.02, section: .finalDough),
        ]
        context.insert(focaccia)

        // Basic White Bread
        let whiteBread = RecipeTemplate(
            name: "Basic White Bread",
            descriptionText: "Simple sandwich bread",
            isBuiltIn: true
        )
        whiteBread.ingredients = [
            TemplateIngredient(name: "Flour", percentage: 1.0, section: .finalDough),
            TemplateIngredient(name: "Water", percentage: 0.65, section: .finalDough),
            TemplateIngredient(name: "Sugar", percentage: 0.05, section: .finalDough),
            TemplateIngredient(name: "Salt", percentage: 0.02, section: .finalDough),
            TemplateIngredient(name: "Unsalted Butter", percentage: 0.05, section: .finalDough),
            TemplateIngredient(name: "Yeast", percentage: 0.02, section: .finalDough),
        ]
        context.insert(whiteBread)

        try? context.save()

        // Save the current version
        UserDefaults.standard.set(currentVersion, forKey: versionKey)
    }
}
