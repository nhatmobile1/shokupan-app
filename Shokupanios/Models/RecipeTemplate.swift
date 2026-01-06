import Foundation
import SwiftData

@Model
class RecipeTemplate {
    var name: String
    var descriptionText: String
    var instructions: String
    var isBuiltIn: Bool
    var createdDate: Date
    @Relationship(deleteRule: .cascade) var ingredients: [TemplateIngredient]

    init(name: String, descriptionText: String = "", instructions: String = "", isBuiltIn: Bool = false) {
        self.name = name
        self.descriptionText = descriptionText
        self.instructions = instructions
        self.isBuiltIn = isBuiltIn
        self.createdDate = Date()
        self.ingredients = []
    }

    /// Creates a clone of this template with a new name
    func clone(newName: String) -> RecipeTemplate {
        let cloned = RecipeTemplate(
            name: newName,
            descriptionText: descriptionText,
            instructions: instructions,
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
    private static let currentVersion = 4
    private static let versionKey = "builtInTemplatesVersion"

    // MARK: - Instructions (from King Arthur Baking)

    private static let shokupanInstructions = """
1. Make the tangzhong: Combine flour and water in a small saucepan, whisk until no lumps remain. Cook over low heat, stirring constantly, until thickened (3-5 minutes). Transfer to a bowl and cool to lukewarm.

2. Mix the dough: Combine the cooled tangzhong with all remaining ingredients except butter. Mix and knead until smooth and elastic, about 15 minutes in a stand mixer. Add butter and knead until incorporated.

3. First rise: Place dough in a greased bowl, cover, and let rise for 1 to 1½ hours until puffy.

4. Shape: Divide dough into four equal pieces. Flatten each into a 5"×8" rectangle, fold short ends together like a letter, then flatten again to 3"×6". Roll each into a 4" log. Place logs in a row, seam side down, in a greased 9"×5" loaf pan.

5. Final rise: Cover and let rise 40-50 minutes until puffy.

6. Bake: Preheat oven to 350°F (175°C). Brush loaf with milk. Bake 30-35 minutes until golden brown and internal temperature reaches 190°F (88°C).

7. Cool in pan 10 minutes before transferring to a rack.
"""

    private static let sourdoughInstructions = """
1. Mix: Combine active sourdough starter, flours, and water in a large bowl. Mix until all flour is moistened and dough forms a cohesive mass.

2. Autolyse: Let dough rest for 20 minutes to allow flour to hydrate and gluten to begin forming.

3. Add salt and knead: Incorporate salt and knead until smooth. Place in a covered bowl and let rise for 1 hour.

4. Stretch and fold: Fold dough like a letter, turn 90 degrees, and repeat. Return to bowl and rise another hour. Repeat folding if desired.

5. Shape: Divide dough in half, shape into rounds, and rest 20 minutes. Shape into tight rounds or bâtards. Place seam-side up in floured proofing baskets.

6. Final proof: Let rise 2 to 2½ hours until light and airy. Alternatively, refrigerate overnight for cold proofing.

7. Preheat: Heat oven to 450°F (230°C) with a baking stone or Dutch oven for at least 60 minutes.

8. Score and bake: Turn loaves onto parchment, slash with a sharp knife or lame. Add steam (ice cubes or water in a pan). Bake 35-40 minutes until deep golden brown.

9. Cool completely on a rack before slicing.
"""

    private static let briocheInstructions = """
1. Mix the dough: In a stand mixer with dough hook, combine all ingredients except butter. Mix until smooth and stretchy, 7-10 minutes at medium speed.

2. Add butter: Add butter one piece at a time, mixing 1-2 minutes between additions until fully incorporated. Continue kneading 5-10 minutes until dough is soft and smooth.

3. First rise: Shape into a ball, place in a greased bowl, cover, and let rise for 1 hour.

4. Refrigerate: Chill the dough for several hours or overnight. This slows fermentation and keeps butter cold for better texture.

5. Shape: Divide chilled dough as desired—12 pieces for mini brioche, whole for a round, or halved for loaves.

6. Second rise: Place in greased pan(s), cover lightly, and let rise 2½ to 3 hours until doubled and very puffy.

7. Bake:
   • Large round: 400°F for 10 min, then 350°F for 30-35 min
   • Mini brioche: 375°F for 15-20 min
   • Loaves: 350°F for 30-35 min
   Internal temperature should reach 190°F (88°C).

8. Cool before serving.
"""

    private static let focacciaInstructions = """
1. Mix dough: Combine flour, salt, sugar, and yeast in a large bowl, whisking together. Add warm water (90-110°F) and olive oil, stirring until fully blended with no dry patches. Cover and rest 15 minutes.

2. Fold the dough: Using a wet hand, lift dough from edges toward center, working around the bowl in a full circle. Flip dough smooth-side up. Rest 15 minutes. Repeat this folding process 3 more times (4 folds total), with 15-minute rests between each.

3. First rise: Cover bowl and let dough rise at room temperature (70-75°F) for 1 hour until nearly doubled.

4. Prepare pan: Spray a 9" square pan with nonstick spray. Line with parchment, pressing firmly. Add 1 tablespoon olive oil and tilt to coat.

5. Second rise: Transfer dough to prepared pan, coating with oil. Cover and let rise 1 to 1½ hours until puffy and marshmallow-like.

6. Preheat oven to 475°F (245°C).

7. Dimple: Oil your fingertips and press into dough to create dimples throughout, spacing about 1½" apart.

8. Top: Drizzle with remaining olive oil and sprinkle generously with flaky sea salt.

9. Bake: Place on lower rack and bake 15-18 minutes until golden brown.

10. Crisp the crust: Remove focaccia from pan using parchment. Return directly to oven rack for 5-7 minutes until sides are crisp.

11. Cool completely on a wire rack before slicing.
"""

    private static let whiteBreadInstructions = """
1. Measure ingredients: Weigh flour for accuracy, or spoon gently into measuring cup and level off.

2. Mix and knead: Combine all ingredients. Knead until smooth—5-7 minutes in a stand mixer, or 8-10 minutes by hand. Dough should form a smooth, elastic ball.

3. First rise: Transfer to a greased bowl, cover, and let rise 1-2 hours until puffy (doesn't need to double).

4. Shape: Gently deflate dough on an oiled surface. Form into an 8-inch log.

5. Second rise: Place in a greased 9"×5" loaf pan. Cover loosely with greased plastic wrap. Let rise about 60 minutes until dough domes about 1 inch above pan rim.

6. Bake: Preheat oven to 350°F (175°C). Bake 30-35 minutes until light golden brown. Bread should sound hollow when tapped on bottom, or reach 190°F (88°C) internal temperature.

7. Cool: Remove from pan and cool completely on a rack before slicing.

8. Store in a plastic bag at room temperature for several days, or freeze for longer storage.
"""

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
            descriptionText: "Soft Japanese milk bread with tangzhong",
            instructions: shokupanInstructions,
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
            instructions: sourdoughInstructions,
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
            instructions: briocheInstructions,
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
            descriptionText: "Big and bubbly Italian flatbread",
            instructions: focacciaInstructions,
            isBuiltIn: true
        )
        focaccia.ingredients = [
            TemplateIngredient(name: "Flour", percentage: 1.0, section: .finalDough),
            TemplateIngredient(name: "Water", percentage: 0.79, section: .finalDough),
            TemplateIngredient(name: "Olive Oil", percentage: 0.12, section: .finalDough),
            TemplateIngredient(name: "Salt", percentage: 0.025, section: .finalDough),
            TemplateIngredient(name: "Sugar", percentage: 0.015, section: .finalDough),
            TemplateIngredient(name: "Instant Yeast", percentage: 0.01, section: .finalDough),
        ]
        context.insert(focaccia)

        // Basic White Bread
        let whiteBread = RecipeTemplate(
            name: "Basic White Bread",
            descriptionText: "Simple sandwich bread",
            instructions: whiteBreadInstructions,
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
