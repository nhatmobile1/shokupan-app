import SwiftUI
import SwiftData

struct AddIngredientView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let recipe: Recipe

    @State private var name = ""
    @State private var percentage = 0.0
    @State private var section: IngredientSection = .finalDough

    var body: some View {
        NavigationStack {
            Form {
                Section("Ingredient Details") {
                    TextField("Ingredient Name", text: $name)

                    HStack {
                        Text("Baker's %")
                        Spacer()
                        TextField("Percentage", value: $percentage, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("%")
                    }

                    Picker("Section", selection: $section) {
                        ForEach(IngredientSection.allCases, id: \.self) { section in
                            Text(section.rawValue).tag(section)
                        }
                    }
                }

                Section("Calculated Weight") {
                    HStack {
                        Text("Weight")
                        Spacer()
                        Text("\(Int(recipe.totalFlourGrams * percentage / 100))g")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addIngredient()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func addIngredient() {
        let ingredient = Ingredient(
            name: name,
            percentage: percentage / 100,
            section: section
        )
        recipe.ingredients.append(ingredient)
        recipe.lastModifiedDate = Date()
        dismiss()
    }
}

#Preview {
    let recipe = Recipe(name: "Test", totalFlourGrams: 250)
    return AddIngredientView(recipe: recipe)
        .modelContainer(for: [Recipe.self, Ingredient.self], inMemory: true)
}
