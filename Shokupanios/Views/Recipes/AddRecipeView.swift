import SwiftUI
import SwiftData

struct AddRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \RecipeTemplate.name) private var templates: [RecipeTemplate]

    @State private var name = ""
    @State private var totalFlourGrams = 250.0
    @State private var instructions = ""
    @State private var notes = ""
    @State private var selectedTemplate: RecipeTemplate?
    @State private var showingTemplatePicker = false

    @AppStorage("panSize1Kin") private var panSize1Kin = 250.0
    @AppStorage("panSize1_5Kin") private var panSize1_5Kin = 375.0
    @AppStorage("panSize2Kin") private var panSize2Kin = 500.0

    private func formatPercentage(_ value: Double) -> String {
        let rounded = (value * 10).rounded() / 10
        if rounded == rounded.rounded() {
            return "\(Int(rounded))%"
        } else {
            return String(format: "%.1f%%", rounded)
        }
    }

    private func formatWeight(_ grams: Double) -> String {
        if grams == grams.rounded() {
            return "\(Int(grams))g"
        } else {
            return String(format: "%.1fg", grams)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.panCream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Template Selection
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Start From")
                                .sectionHeader()

                            Button {
                                showingTemplatePicker = true
                            } label: {
                                HStack {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 16))
                                        .foregroundColor(.terracotta.opacity(0.8))

                                    Text("Template")
                                        .font(.bakeryBody(15))
                                        .foregroundColor(.inkBrown)

                                    Spacer()

                                    if let template = selectedTemplate {
                                        Text(template.name)
                                            .font(.bakeryBody(14))
                                            .foregroundColor(.stoneGray)
                                    } else {
                                        Text("None (Blank)")
                                            .font(.bakeryBody(14))
                                            .foregroundColor(.stoneGray)
                                    }

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.stoneGray)
                                }
                                .padding(Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                                        .fill(Color.flourWhite)
                                )
                            }
                            .buttonStyle(.plain)

                            if selectedTemplate != nil {
                                Button {
                                    selectedTemplate = nil
                                } label: {
                                    HStack(spacing: Spacing.xs) {
                                        Image(systemName: "xmark.circle")
                                            .font(.system(size: 12))
                                        Text("Clear Template")
                                            .font(.bakeryBody(13))
                                    }
                                    .foregroundColor(.terracotta)
                                }
                            }
                        }
                        .padding(Spacing.lg)
                        .warmCard()

                        // Recipe Details
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Recipe Details")
                                .sectionHeader()

                            TextField("Recipe Name", text: $name)
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

                        // Total Flour
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Total Flour Weight")
                                .sectionHeader()

                            HStack {
                                TextField("Amount", value: $totalFlourGrams, format: .number)
                                    .font(.bakeryMono(24))
                                    .keyboardType(.numberPad)
                                    .foregroundColor(.inkBrown)

                                Text("grams")
                                    .font(.bakeryBody(16))
                                    .foregroundColor(.stoneGray)
                            }
                            .padding(Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                                    .fill(Color.flourWhite)
                            )
                        }
                        .padding(Spacing.lg)
                        .warmCard()

                        // Pan Size Presets
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Pan Sizes")
                                .sectionHeader()

                            let flourPresets: [(String, Double)] = [
                                ("1 kin", panSize1Kin),
                                ("1.5 kin", panSize1_5Kin),
                                ("2 kin", panSize2Kin)
                            ]

                            ForEach(flourPresets, id: \.0) { preset in
                                Button {
                                    totalFlourGrams = preset.1
                                } label: {
                                    HStack {
                                        Text(preset.0)
                                            .font(.bakeryBodyMedium(15))
                                            .foregroundColor(.inkBrown)

                                        Spacer()

                                        Text("\(Int(preset.1))g")
                                            .font(.bakeryMono(13))
                                            .foregroundColor(.stoneGray)

                                        if totalFlourGrams == preset.1 {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.terracotta)
                                        }
                                    }
                                    .padding(Spacing.md)
                                    .background(
                                        RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                                            .fill(totalFlourGrams == preset.1 ? Color.terracotta.opacity(0.08) : Color.flourWhite)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(Spacing.lg)
                        .warmCard()

                        // Ingredients Preview (if template selected)
                        if let template = selectedTemplate, !template.ingredients.isEmpty {
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                Text("Ingredients from Template")
                                    .sectionHeader()

                                ForEach(template.ingredients) { ingredient in
                                    HStack {
                                        Text(ingredient.name)
                                            .font(.bakeryBody(15))
                                            .foregroundColor(.inkBrown)

                                        Spacer()

                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text(formatWeight(totalFlourGrams * ingredient.percentage))
                                                .font(.bakeryMono(15))
                                                .foregroundColor(.inkBrown)

                                            Text(formatPercentage(ingredient.percentage * 100))
                                                .font(.bakeryMono(12))
                                                .foregroundColor(.stoneGray)
                                        }
                                    }
                                    .padding(.vertical, Spacing.sm)

                                    if ingredient.id != template.ingredients.last?.id {
                                        WarmDivider()
                                    }
                                }
                            }
                            .padding(Spacing.lg)
                            .warmCard()
                        }

                        // Instructions
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Instructions")
                                .sectionHeader()

                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $instructions)
                                    .font(.bakeryBody(15))
                                    .foregroundColor(.inkBrown)
                                    .frame(minHeight: 120)
                                    .padding(Spacing.sm)
                                    .scrollContentBackground(.hidden)

                                if instructions.isEmpty {
                                    Text("Step-by-step instructions...")
                                        .font(.bakeryBody(15))
                                        .foregroundColor(.stoneGray.opacity(0.6))
                                        .padding(Spacing.sm)
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                        .allowsHitTesting(false)
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                                    .fill(Color.flourWhite)
                            )
                        }
                        .padding(Spacing.lg)
                        .warmCard()

                        // Notes
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Notes")
                                .sectionHeader()

                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $notes)
                                    .font(.bakeryBody(15))
                                    .foregroundColor(.inkBrown)
                                    .frame(minHeight: 100)
                                    .padding(Spacing.sm)
                                    .scrollContentBackground(.hidden)

                                if notes.isEmpty {
                                    Text("Results, experiments, observations...")
                                        .font(.bakeryBody(15))
                                        .foregroundColor(.stoneGray.opacity(0.6))
                                        .padding(Spacing.sm)
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                        .allowsHitTesting(false)
                                }
                            }
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
            .navigationTitle("New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.stoneGray)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRecipe()
                    }
                    .font(.bakeryBodyMedium(16))
                    .foregroundColor(.terracotta)
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showingTemplatePicker) {
                TemplatePickerView(selectedTemplate: $selectedTemplate, templates: templates)
            }
        }
    }

    private func saveRecipe() {
        // Use template instructions if user hasn't written their own
        let finalInstructions = instructions.isEmpty ? (selectedTemplate?.instructions ?? "") : instructions

        let newRecipe = Recipe(name: name, totalFlourGrams: totalFlourGrams, instructions: finalInstructions, notes: notes)

        // Copy ingredients from template if selected
        if let template = selectedTemplate {
            for templateIngredient in template.ingredients {
                let ingredient = Ingredient(
                    name: templateIngredient.name,
                    percentage: templateIngredient.percentage,
                    section: templateIngredient.section
                )
                newRecipe.ingredients.append(ingredient)
            }
        }

        modelContext.insert(newRecipe)
        dismiss()
    }
}

// MARK: - Template Picker View
struct TemplatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTemplate: RecipeTemplate?
    let templates: [RecipeTemplate]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.panCream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Blank Recipe Option
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Button {
                                selectedTemplate = nil
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "doc")
                                        .font(.system(size: 16))
                                        .foregroundColor(.crustBrown)

                                    Text("Blank Recipe")
                                        .font(.bakeryBodyMedium(15))
                                        .foregroundColor(.inkBrown)

                                    Spacer()

                                    if selectedTemplate == nil {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.terracotta)
                                    }
                                }
                                .padding(Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                                        .fill(selectedTemplate == nil ? Color.terracotta.opacity(0.08) : Color.flourWhite)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(Spacing.lg)
                        .warmCard()

                        // Built-in Templates
                        if !builtInTemplates.isEmpty {
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                Text("Built-in Templates")
                                    .sectionHeader()

                                ForEach(builtInTemplates) { template in
                                    TemplatePickerRow(
                                        template: template,
                                        isSelected: selectedTemplate?.id == template.id
                                    ) {
                                        selectedTemplate = template
                                        dismiss()
                                    }

                                    if template.id != builtInTemplates.last?.id {
                                        WarmDivider()
                                    }
                                }
                            }
                            .padding(Spacing.lg)
                            .warmCard()
                        }

                        // User Templates
                        if !userTemplates.isEmpty {
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                Text("My Templates")
                                    .sectionHeader()

                                ForEach(userTemplates) { template in
                                    TemplatePickerRow(
                                        template: template,
                                        isSelected: selectedTemplate?.id == template.id
                                    ) {
                                        selectedTemplate = template
                                        dismiss()
                                    }

                                    if template.id != userTemplates.last?.id {
                                        WarmDivider()
                                    }
                                }
                            }
                            .padding(Spacing.lg)
                            .warmCard()
                        }
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle("Choose Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.stoneGray)
                }
            }
        }
    }

    private var builtInTemplates: [RecipeTemplate] {
        templates.filter { $0.isBuiltIn }
    }

    private var userTemplates: [RecipeTemplate] {
        templates.filter { !$0.isBuiltIn }
    }
}

struct TemplatePickerRow: View {
    let template: RecipeTemplate
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack(spacing: Spacing.sm) {
                        Text(template.name)
                            .font(.bakeryBodyMedium(15))
                            .foregroundColor(.inkBrown)

                        if template.isBuiltIn {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.terracotta.opacity(0.6))
                        }
                    }

                    if !template.descriptionText.isEmpty {
                        Text(template.descriptionText)
                            .font(.bakeryBody(13))
                            .foregroundColor(.stoneGray)
                            .lineLimit(1)
                    }

                    HStack(spacing: Spacing.sm) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 10))
                            Text("\(template.ingredients.count)")
                                .font(.bakeryMono(11))
                        }
                        .foregroundColor(.stoneGray)

                        if template.hydrationPercentage > 0 {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "drop.fill")
                                    .font(.system(size: 10))
                                Text("\(Int(template.hydrationPercentage))%")
                                    .font(.bakeryMono(11))
                            }
                            .foregroundColor(.terracotta.opacity(0.7))
                        }
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.terracotta)
                }
            }
            .padding(.vertical, Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddRecipeView()
        .modelContainer(for: [Recipe.self, Ingredient.self, RecipeTemplate.self, TemplateIngredient.self], inMemory: true)
}
