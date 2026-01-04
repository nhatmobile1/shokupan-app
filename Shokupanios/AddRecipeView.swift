import SwiftUI
import SwiftData

struct AddRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \RecipeTemplate.name) private var templates: [RecipeTemplate]

    @State private var name = ""
    @State private var totalFlourGrams = 250.0
    @State private var notes = ""
    @State private var selectedTemplate: RecipeTemplate?
    @State private var showingTemplatePicker = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Start From") {
                    Button {
                        showingTemplatePicker = true
                    } label: {
                        HStack {
                            Text("Template")
                            Spacer()
                            if let template = selectedTemplate {
                                Text(template.name)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("None (Blank Recipe)")
                                    .foregroundColor(.secondary)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)

                    if selectedTemplate != nil {
                        Button(role: .destructive) {
                            selectedTemplate = nil
                        } label: {
                            Label("Clear Template", systemImage: "xmark.circle")
                        }
                    }
                }

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

                if let template = selectedTemplate, !template.ingredients.isEmpty {
                    Section("Ingredients from Template") {
                        ForEach(template.ingredients) { ingredient in
                            HStack {
                                Text(ingredient.name)
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("\(Int(ingredient.percentage * 100))%")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(Int(totalFlourGrams * ingredient.percentage))g")
                                }
                            }
                        }
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
            .sheet(isPresented: $showingTemplatePicker) {
                TemplatePickerView(selectedTemplate: $selectedTemplate, templates: templates)
            }
        }
    }

    private func saveRecipe() {
        let newRecipe = Recipe(name: name, totalFlourGrams: totalFlourGrams, notes: notes)

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
            List {
                Section {
                    Button {
                        selectedTemplate = nil
                        dismiss()
                    } label: {
                        HStack {
                            Text("Blank Recipe")
                            Spacer()
                            if selectedTemplate == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }

                if !builtInTemplates.isEmpty {
                    Section("Built-in Templates") {
                        ForEach(builtInTemplates) { template in
                            TemplatePickerRow(
                                template: template,
                                isSelected: selectedTemplate?.id == template.id
                            ) {
                                selectedTemplate = template
                                dismiss()
                            }
                        }
                    }
                }

                if !userTemplates.isEmpty {
                    Section("My Templates") {
                        ForEach(userTemplates) { template in
                            TemplatePickerRow(
                                template: template,
                                isSelected: selectedTemplate?.id == template.id
                            ) {
                                selectedTemplate = template
                                dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Choose Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
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
                VStack(alignment: .leading, spacing: 2) {
                    Text(template.name)
                    if !template.descriptionText.isEmpty {
                        Text(template.descriptionText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("\(template.ingredients.count) ingredients")
                        if template.hydrationPercentage > 0 {
                            Text("•")
                            Text("\(Int(template.hydrationPercentage))% hydration")
                        }
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .foregroundColor(.primary)
    }
}

#Preview {
    AddRecipeView()
        .modelContainer(for: [Recipe.self, Ingredient.self, RecipeTemplate.self, TemplateIngredient.self], inMemory: true)
}
