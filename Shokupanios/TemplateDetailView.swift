import SwiftUI
import SwiftData

struct TemplateDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var template: RecipeTemplate

    @State private var showingAddIngredient = false
    @State private var showingCloneAlert = false
    @State private var cloneName = ""
    @State private var showingCreateRecipe = false

    var body: some View {
        ZStack {
            WarmGradientBackground()

            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Header Card
                    headerCard

                    // Quick Stats
                    if template.hydrationPercentage > 0 || !template.ingredients.isEmpty {
                        quickStatsSection
                    }

                    // Description
                    if !template.descriptionText.isEmpty {
                        descriptionSection
                    }

                    // Ingredients
                    ingredientsSection

                    // Create Recipe Button
                    createRecipeButton
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(template.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    if !template.isBuiltIn {
                        Button(action: { showingAddIngredient = true }) {
                            Label("Add Ingredient", systemImage: "plus")
                        }
                    }
                    Button(action: {
                        cloneName = "\(template.name) (Copy)"
                        showingCloneAlert = true
                    }) {
                        Label("Clone Template", systemImage: "doc.on.doc")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.terracotta)
                }
            }
        }
        .sheet(isPresented: $showingAddIngredient) {
            AddTemplateIngredientView(template: template)
        }
        .sheet(isPresented: $showingCreateRecipe) {
            CreateRecipeFromTemplateView(template: template)
        }
        .alert("Clone Template", isPresented: $showingCloneAlert) {
            TextField("Template Name", text: $cloneName)
            Button("Cancel", role: .cancel) { }
            Button("Clone") {
                cloneTemplate()
            }
        } message: {
            Text("Enter a name for the cloned template")
        }
        .tint(.terracotta)
    }

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(spacing: Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(template.isBuiltIn ? Color.terracotta.opacity(0.12) : Color.crustBrown.opacity(0.12))
                    .frame(width: 72, height: 72)

                Image(systemName: template.isBuiltIn ? "doc.text.fill" : "doc.text")
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(template.isBuiltIn ? .terracotta : .crustBrown)
            }

            // Title & Badge
            VStack(spacing: Spacing.sm) {
                Text(template.name)
                    .font(.bakerySerifMedium(24))
                    .foregroundColor(.inkBrown)
                    .multilineTextAlignment(.center)

                if template.isBuiltIn {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                        Text("Built-in Template")
                            .font(.bakeryBody(13))
                    }
                    .foregroundColor(.terracotta)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
        .warmCard()
    }

    // MARK: - Quick Stats

    private var quickStatsSection: some View {
        HStack(spacing: Spacing.md) {
            StatCard(
                icon: "list.bullet",
                label: "Ingredients",
                value: "\(template.ingredients.count)"
            )

            if template.hydrationPercentage > 0 {
                StatCard(
                    icon: "drop.fill",
                    label: "Hydration",
                    value: "\(Int(template.hydrationPercentage))%"
                )
            }

            StatCard(
                icon: "percent",
                label: "Total %",
                value: "\(Int(totalPercentage * 100))%"
            )
        }
    }

    // MARK: - Description Section

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Description")
                .sectionHeader()

            Text(template.descriptionText)
                .font(.bakeryBody(15))
                .foregroundColor(.inkBrown)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.lg)
        .warmCard()
    }

    // MARK: - Ingredients Section

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            HStack {
                Text("Ingredients")
                    .sectionHeader()
                Spacer()
                if !template.isBuiltIn {
                    Button {
                        showingAddIngredient = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.terracotta)
                    }
                }
            }

            if template.ingredients.isEmpty {
                VStack(spacing: Spacing.md) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(.crustBrown.opacity(0.4))
                    Text("No ingredients yet")
                        .font(.bakeryBody(14))
                        .foregroundColor(.stoneGray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.xl)
            } else {
                ForEach(sectionsWithIngredients, id: \.self) { section in
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        SectionBadge(section: section)

                        ForEach(ingredientsFor(section: section)) { ingredient in
                            TemplateIngredientRow(
                                ingredient: ingredient,
                                canDelete: !template.isBuiltIn,
                                onDelete: {
                                    deleteIngredient(ingredient)
                                }
                            )
                        }
                    }
                }
            }
        }
        .padding(Spacing.lg)
        .warmCard()
    }

    // MARK: - Create Recipe Button

    private var createRecipeButton: some View {
        Button {
            showingCreateRecipe = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18))
                Text("Create Recipe from Template")
                    .font(.bakeryBodyMedium(16))
            }
            .foregroundColor(.flourWhite)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                    .fill(Color.terracotta)
            )
        }
        .buttonStyle(.plain)
        .padding(.top, Spacing.sm)
    }

    // MARK: - Computed Properties

    private var sectionsWithIngredients: [IngredientSection] {
        let sections = Set(template.ingredients.map { $0.section })
        return IngredientSection.allCases.filter { sections.contains($0) }
    }

    private var totalPercentage: Double {
        template.ingredients.reduce(0) { $0 + $1.percentage }
    }

    private func ingredientsFor(section: IngredientSection) -> [TemplateIngredient] {
        template.ingredients.filter { $0.section == section }
    }

    // MARK: - Actions

    private func deleteIngredient(_ ingredient: TemplateIngredient) {
        template.ingredients.removeAll { $0.id == ingredient.id }
    }

    private func deleteIngredients(in section: IngredientSection, at offsets: IndexSet) {
        let sectionIngredients = ingredientsFor(section: section)
        for index in offsets {
            if let ingredientIndex = template.ingredients.firstIndex(where: { $0.id == sectionIngredients[index].id }) {
                template.ingredients.remove(at: ingredientIndex)
            }
        }
    }

    private func cloneTemplate() {
        let cloned = template.clone(newName: cloneName)
        modelContext.insert(cloned)
    }
}

// MARK: - Template Ingredient Row

struct TemplateIngredientRow: View {
    let ingredient: TemplateIngredient
    var canDelete: Bool = false
    var onDelete: (() -> Void)?

    private func formatPercentage(_ value: Double) -> String {
        let rounded = (value * 10).rounded() / 10  // Round to 1 decimal place
        if rounded == rounded.rounded() {
            return "\(Int(rounded))%"
        } else {
            return String(format: "%.1f%%", rounded)
        }
    }

    var body: some View {
        HStack {
            Text(ingredient.name)
                .font(.bakeryBody(15))
                .foregroundColor(.inkBrown)

            Spacer()

            Text(formatPercentage(ingredient.percentage * 100))
                .font(.bakeryMono(15))
                .foregroundColor(.warmBrown)

            if canDelete, let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(.stoneGray.opacity(0.6))
                }
                .padding(.leading, Spacing.sm)
            }
        }
        .padding(.vertical, Spacing.sm)
    }
}

// MARK: - Create Recipe From Template View

struct CreateRecipeFromTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let template: RecipeTemplate

    @State private var recipeName = ""
    @State private var totalFlour = 250.0

    @AppStorage("panSize1Kin") private var panSize1Kin = 250.0
    @AppStorage("panSize1_5Kin") private var panSize1_5Kin = 375.0
    @AppStorage("panSize2Kin") private var panSize2Kin = 500.0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.panCream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Recipe Name
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Recipe Name")
                                .sectionHeader()

                            TextField("Enter recipe name", text: $recipeName)
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
                                TextField("Amount", value: $totalFlour, format: .number)
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
                                    totalFlour = preset.1
                                } label: {
                                    HStack {
                                        Text(preset.0)
                                            .font(.bakeryBodyMedium(15))
                                            .foregroundColor(.inkBrown)

                                        Spacer()

                                        Text("\(Int(preset.1))g")
                                            .font(.bakeryMono(13))
                                            .foregroundColor(.stoneGray)

                                        if totalFlour == preset.1 {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.terracotta)
                                        }
                                    }
                                    .padding(Spacing.md)
                                    .background(
                                        RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                                            .fill(totalFlour == preset.1 ? Color.terracotta.opacity(0.08) : Color.flourWhite)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
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
                    Button("Create") {
                        createRecipe()
                    }
                    .font(.bakeryBodyMedium(16))
                    .foregroundColor(.terracotta)
                    .disabled(recipeName.isEmpty || totalFlour <= 0)
                }
            }
        }
        .onAppear {
            recipeName = template.name
        }
    }

    private func createRecipe() {
        let recipe = Recipe(
            name: recipeName,
            totalFlourGrams: totalFlour,
            notes: "",
            tags: []
        )

        // Copy ingredients from template
        for templateIngredient in template.ingredients {
            let ingredient = Ingredient(
                name: templateIngredient.name,
                percentage: templateIngredient.percentage,
                section: templateIngredient.section
            )
            recipe.ingredients.append(ingredient)
        }

        modelContext.insert(recipe)
        dismiss()
    }
}

// MARK: - Add Template Ingredient View

struct AddTemplateIngredientView: View {
    @Environment(\.dismiss) private var dismiss

    let template: RecipeTemplate

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
        let ingredient = TemplateIngredient(
            name: name,
            percentage: percentage / 100,
            section: section
        )
        template.ingredients.append(ingredient)
        dismiss()
    }
}

#Preview {
    let template = RecipeTemplate(name: "Classic Shokupan", descriptionText: "A soft Japanese milk bread with a pillowy texture", isBuiltIn: true)
    template.ingredients.append(TemplateIngredient(name: "Bread Flour", percentage: 1.0, section: .finalDough))
    template.ingredients.append(TemplateIngredient(name: "Milk", percentage: 0.65, section: .finalDough))
    template.ingredients.append(TemplateIngredient(name: "Sugar", percentage: 0.08, section: .finalDough))
    template.ingredients.append(TemplateIngredient(name: "Salt", percentage: 0.02, section: .finalDough))
    template.ingredients.append(TemplateIngredient(name: "Yeast", percentage: 0.01, section: .finalDough))
    template.ingredients.append(TemplateIngredient(name: "Butter", percentage: 0.06, section: .finalDough))

    return NavigationStack {
        TemplateDetailView(template: template)
    }
    .modelContainer(for: [RecipeTemplate.self, TemplateIngredient.self], inMemory: true)
}
