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
            ZStack {
                Color.panCream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Ingredient Name
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Ingredient Name")
                                .sectionHeader()

                            TextField("e.g., Bread Flour", text: $name)
                                .font(.bakeryBody(16))
                                .foregroundColor(.inkBrown)
                                .padding(Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                                        .fill(Color.flourWhite)
                                )
                        }
                        .padding(Spacing.lg)
                        .warmCard()

                        // Baker's Percentage
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Baker's Percentage")
                                .sectionHeader()

                            HStack {
                                TextField("Percentage", value: $percentage, format: .number)
                                    .font(.bakeryMono(24))
                                    .keyboardType(.decimalPad)
                                    .foregroundColor(.inkBrown)

                                Text("%")
                                    .font(.bakeryBody(16))
                                    .foregroundColor(.stoneGray)
                            }
                            .padding(Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                                    .fill(Color.flourWhite)
                            )

                            Text("100% = flour weight. Water at 65% means 65g water per 100g flour.")
                                .font(.bakeryBody(12))
                                .foregroundColor(.stoneGray)
                        }
                        .padding(Spacing.lg)
                        .warmCard()

                        // Section
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Section")
                                .sectionHeader()

                            HStack(spacing: Spacing.sm) {
                                ForEach(IngredientSection.allCases, id: \.self) { sec in
                                    Button {
                                        section = sec
                                    } label: {
                                        Text(sec.rawValue)
                                            .tagChip(selected: section == sec)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(Spacing.lg)
                        .warmCard()

                        // Calculated Weight
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Calculated Weight")
                                .sectionHeader()

                            HStack {
                                Image(systemName: "scalemass")
                                    .font(.system(size: 16))
                                    .foregroundColor(.terracotta.opacity(0.8))

                                Text("Weight")
                                    .font(.bakeryBody(15))
                                    .foregroundColor(.inkBrown)

                                Spacer()

                                Text("\(Int((recipe.totalFlourGrams * percentage / 100).rounded()))g")
                                    .font(.bakeryMono(16))
                                    .foregroundColor(.warmBrown)
                            }
                            .padding(Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                                    .fill(Color.flourWhite)
                            )
                        }
                        .padding(Spacing.lg)
                        .warmCard()
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.stoneGray)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addIngredient()
                    }
                    .font(.bakeryBodyMedium(16))
                    .foregroundColor(.terracotta)
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
