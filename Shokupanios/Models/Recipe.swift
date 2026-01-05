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
    @Attribute(.externalStorage) var photoData: Data?
    var tags: [String]
    @Relationship(deleteRule: .cascade) var ingredients: [Ingredient]

    init(name: String, totalFlourGrams: Double = 250.0, notes: String = "", rating: Int? = nil, tags: [String] = []) {
        self.name = name
        self.totalFlourGrams = totalFlourGrams
        self.createdDate = Date()
        self.lastModifiedDate = Date()
        self.notes = notes
        self.rating = rating
        self.photoData = nil
        self.tags = tags
        self.ingredients = []
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

    /// Creates a clone of this recipe with a new name
    func clone(newName: String) -> Recipe {
        let cloned = Recipe(
            name: newName,
            totalFlourGrams: totalFlourGrams,
            notes: notes,
            rating: rating,
            tags: tags
        )
        cloned.photoData = photoData
        for ingredient in ingredients {
            let clonedIngredient = Ingredient(
                name: ingredient.name,
                percentage: ingredient.percentage,
                section: ingredient.section
            )
            cloned.ingredients.append(clonedIngredient)
        }
        return cloned
    }
}

@Model
class Ingredient {
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

    func weight(basedOn totalFlour: Double) -> Double {
        return totalFlour * percentage
    }
}

enum IngredientSection: String, Codable, CaseIterable {
    case preferment = "Preferment"
    case finalDough = "Final Dough"
}
