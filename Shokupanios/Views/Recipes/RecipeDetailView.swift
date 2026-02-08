import SwiftUI
import SwiftData
import PhotosUI

struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var recipe: Recipe
    @Query(sort: \TimerPreset.name) private var timerPresets: [TimerPreset]
    private var timerManager = TimerManager.shared

    @State private var showingAddIngredient = false
    @State private var showingCloneAlert = false
    @State private var cloneName = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var newTag = ""
    @State private var showingScaleSheet = false
    @State private var scaleMode: ScaleMode = .flour
    @State private var inputAmount = ""
    @State private var showingShareSheet = false
    @State private var showingPhotoOptions = false
    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    @State private var showingEditInstructions = false
    @State private var showingEditNotes = false
    @State private var editingInstructions = ""
    @State private var editingNotes = ""
    @State private var showingTimerPicker = false
    @State private var showingDDTCalculator = false

    // Global settings
    @AppStorage("useMetricUnits") private var useMetricUnits = true
    @AppStorage("panSize1Kin") private var panSize1Kin = 250.0
    @AppStorage("panSize1_5Kin") private var panSize1_5Kin = 375.0
    @AppStorage("panSize2Kin") private var panSize2Kin = 500.0

    init(recipe: Recipe) {
        self.recipe = recipe
    }

    enum ScaleMode: String, CaseIterable {
        case flour = "By Flour"
        case dough = "By Dough"
    }

    var body: some View {
        ZStack {
            WarmGradientBackground()

            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Hero Image Section
                    heroImageSection

                    // Content
                    VStack(spacing: Spacing.lg) {
                        // Quick Stats
                        quickStatsSection

                        // Tags
                        if !recipe.tags.isEmpty || true {
                            tagsSection
                        }

                        // Scale Recipe
                        scaleSection

                        // Ingredients
                        ingredientsSection

                        // Instructions
                        instructionsSection

                        // Timer
                        timerSection

                        // Dough Temperature
                        doughTemperatureSection

                        // Notes
                        notesSection
                    }
                    .padding(.horizontal, Spacing.md)
                }
                .padding(.bottom, Spacing.xxl)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: { showingAddIngredient = true }) {
                        Label("Add Ingredient", systemImage: "plus")
                    }
                    Button(action: {
                        cloneName = "\(recipe.name) (Copy)"
                        showingCloneAlert = true
                    }) {
                        Label("Clone Recipe", systemImage: "doc.on.doc")
                    }
                    Button(action: { showingShareSheet = true }) {
                        Label("Share Recipe", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.terracotta)
                }
            }
        }
        .sheet(isPresented: $showingAddIngredient) {
            AddIngredientView(recipe: recipe)
        }
        .alert("Clone Recipe", isPresented: $showingCloneAlert) {
            TextField("Recipe Name", text: $cloneName)
            Button("Cancel", role: .cancel) { }
            Button("Clone") {
                cloneRecipe()
            }
        } message: {
            Text("Enter a name for the cloned recipe")
        }
        .onChange(of: selectedPhoto) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    recipe.photoData = data
                    recipe.lastModifiedDate = Date()
                }
            }
        }
        .sheet(isPresented: $showingScaleSheet) {
            scaleSheet
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: generateShareItems())
        }
        .confirmationDialog("Add Photo", isPresented: $showingPhotoOptions, titleVisibility: .visible) {
            Button("Take Photo") {
                showingCamera = true
            }
            Button("Choose from Library") {
                showingPhotoPicker = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showingCamera) {
            CameraPicker { image in
                if let data = image.jpegData(compressionQuality: 0.8) {
                    recipe.photoData = data
                    recipe.lastModifiedDate = Date()
                }
            }
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Text("Select Photo")
            }
            .photosPickerStyle(.inline)
            .photosPickerDisabledCapabilities(.selectionActions)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingEditInstructions) {
            editTextSheet(
                title: "Instructions",
                placeholder: "Write step-by-step instructions for making this bread...\n\n1. Mix dry ingredients\n2. Add wet ingredients\n3. Knead until smooth\n4. Bulk fermentation\n5. Shape and proof\n6. Bake",
                text: $editingInstructions
            ) {
                recipe.instructions = editingInstructions
                recipe.lastModifiedDate = Date()
            }
        }
        .sheet(isPresented: $showingEditNotes) {
            editTextSheet(
                title: "Notes",
                placeholder: "Record your results, experiments, or anything you want to remember...\n\n• What worked well\n• What to change next time\n• Temperature and timing notes",
                text: $editingNotes
            ) {
                recipe.notes = editingNotes
                recipe.lastModifiedDate = Date()
            }
        }
        .sheet(isPresented: $showingTimerPicker) {
            TimerPresetPickerSheet(
                presets: timerPresets,
                selectedPresetName: recipe.timerPresetName
            ) { presetName in
                recipe.timerPresetName = presetName
                recipe.lastModifiedDate = Date()
            }
        }
        .sheet(isPresented: $showingDDTCalculator) {
            DDTCalculatorView(hasPreferment: recipeHasPreferment)
        }
        .onAppear {
            editingInstructions = recipe.instructions
            editingNotes = recipe.notes
        }
        .tint(.terracotta)
    }

    // MARK: - Edit Text Sheet

    private func editTextSheet(title: String, placeholder: String, text: Binding<String>, onSave: @escaping () -> Void) -> some View {
        NavigationStack {
            ZStack {
                Color.panCream.ignoresSafeArea()

                VStack(spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: text)
                            .font(.bakeryBody(15))
                            .foregroundColor(.inkBrown)
                            .scrollContentBackground(.hidden)
                            .padding(Spacing.md)

                        if text.wrappedValue.isEmpty {
                            Text(placeholder)
                                .font(.bakeryBody(15))
                                .foregroundColor(.stoneGray.opacity(0.6))
                                .padding(Spacing.md)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                    }
                    .background(Color.flourWhite)
                    .cornerRadius(CornerRadius.md)
                    .padding(Spacing.md)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if title == "Instructions" {
                            editingInstructions = recipe.instructions
                            showingEditInstructions = false
                        } else {
                            editingNotes = recipe.notes
                            showingEditNotes = false
                        }
                    }
                    .foregroundColor(.stoneGray)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        if title == "Instructions" {
                            showingEditInstructions = false
                        } else {
                            showingEditNotes = false
                        }
                    }
                    .font(.bakeryBodyMedium(16))
                    .foregroundColor(.terracotta)
                }
            }
        }
        .presentationDetents([.large])
    }

    // MARK: - Hero Image Section

    private var heroImageSection: some View {
        ZStack(alignment: .bottomTrailing) {
            if let photoData = recipe.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 240)
                    .clipped()
            } else {
                ZStack {
                    Color.panCrumb
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "photo")
                            .font(.system(size: 40, weight: .light))
                            .foregroundColor(.crustBrown.opacity(0.3))
                        Text("Add a photo")
                            .font(.bakeryBody(14))
                            .foregroundColor(.crustBrown.opacity(0.5))
                    }
                }
                .frame(height: 200)
            }

            // Photo button
            Button {
                showingPhotoOptions = true
            } label: {
                Image(systemName: "camera.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.flourWhite)
                    .padding(Spacing.md)
                    .background(
                        Circle()
                            .fill(Color.terracotta)
                            .shadow(color: Color.warmBrown.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
            }
            // Ensure 44pt minimum touch target
            .frame(minWidth: 44, minHeight: 44)
            .accessibilityLabel(recipe.photoData != nil ? "Change photo" : "Add photo")
            .padding(Spacing.md)
        }
    }

    // MARK: - Quick Stats Section

    private var quickStatsSection: some View {
        HStack(spacing: Spacing.md) {
            StatCard(
                icon: "scalemass",
                label: "Flour",
                value: formatWeight(recipe.totalFlourGrams)
            )

            StatCard(
                icon: "drop.fill",
                label: "Hydration",
                value: "\(Int(recipe.hydrationPercentage))%"
            )

            StatCard(
                icon: "circle.hexagongrid",
                label: "Total Dough",
                value: formatWeight(totalDoughWeight)
            )
        }
    }

    // MARK: - Tags Section

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Tags")
                .sectionHeader()

            FlowLayout(spacing: Spacing.sm) {
                ForEach(recipe.tags, id: \.self) { tag in
                    ColoredTagChip(tag: tag, showDelete: true) {
                        recipe.tags.removeAll { $0 == tag }
                        recipe.lastModifiedDate = Date()
                    }
                }

                // Add tag field
                HStack(spacing: 4) {
                    TextField("Add tag", text: $newTag)
                        .font(.bakeryBody(13))
                        .textInputAutocapitalization(.never)
                        .frame(width: 80)

                    if !newTag.isEmpty {
                        Button {
                            addTag()
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .semibold))
                        }
                    }
                }
                .foregroundColor(.warmBrown)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    Capsule()
                        .stroke(Color.panCrumb, lineWidth: 1.5)
                        .background(Capsule().fill(Color.flourWhite))
                )
            }
        }
        .padding(Spacing.lg)
        .warmCard()
    }

    // MARK: - Scale Section

    private var scaleSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Scale Recipe")
                .sectionHeader()

            Button {
                inputAmount = String(Int(recipe.totalFlourGrams))
                scaleMode = .flour
                showingScaleSheet = true
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Adjust amounts")
                            .font(.bakeryBodyMedium(15))
                            .foregroundColor(.inkBrown)
                        Text("Scale by flour weight or target dough")
                            .font(.bakeryBody(13))
                            .foregroundColor(.stoneGray)
                    }

                    Spacer()

                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18))
                        .foregroundColor(.terracotta)
                }
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                        .fill(Color.terracotta.opacity(0.08))
                )
            }
            .buttonStyle(.plain)
        }
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
                Button {
                    showingAddIngredient = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.terracotta)
                }
            }

            if recipe.ingredients.isEmpty {
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
                            IngredientRow(
                                ingredient: ingredient,
                                weight: formatWeight(ingredient.weight(basedOn: recipe.totalFlourGrams))
                            )
                        }
                        .onDelete { offsets in
                            deleteIngredients(in: section, at: offsets)
                        }
                    }
                }
            }
        }
        .padding(Spacing.lg)
        .warmCard()
    }

    // MARK: - Instructions Section

    private var instructionsSection: some View {
        EditableCardSection(
            title: "Instructions",
            isEmpty: recipe.instructions.isEmpty,
            emptyText: "Tap to add step-by-step instructions...",
            onTap: { showingEditInstructions = true }
        ) {
            Text(recipe.instructions)
                .font(.bakeryBodyDynamic)
                .foregroundColor(.inkBrown)
                .lineSpacing(4)
        }
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        EditableCardSection(
            title: "Notes",
            isEmpty: recipe.notes.isEmpty,
            emptyText: "Tap to add notes, results, or experiments...",
            onTap: { showingEditNotes = true }
        ) {
            Text(recipe.notes)
                .font(.bakeryBodyDynamic)
                .foregroundColor(.inkBrown)
                .lineSpacing(4)
        }
    }

    // MARK: - Timer Section

    private var timerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Timer")
                .sectionHeader()

            if let presetName = recipe.timerPresetName,
               let preset = timerPresets.first(where: { $0.name == presetName }) {
                // Linked timer preset
                VStack(spacing: Spacing.md) {
                    HStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.terracotta.opacity(0.1))
                                .frame(width: 40, height: 40)

                            Image(systemName: "timer")
                                .font(.system(size: 16))
                                .foregroundColor(.terracotta)
                        }

                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(preset.name)
                                .font(.bakeryBodyMedium(15))
                                .foregroundColor(.inkBrown)

                            HStack(spacing: Spacing.sm) {
                                Text("\(preset.steps.count) steps")
                                    .font(.bakeryBody(12))
                                    .foregroundColor(.stoneGray)

                                Text("•")
                                    .foregroundColor(.stoneGray)

                                Text(preset.totalDuration.shortFormatted)
                                    .font(.bakeryMono(12))
                                    .foregroundColor(.stoneGray)
                            }
                        }

                        Spacer()
                    }

                    HStack(spacing: Spacing.sm) {
                        Button {
                            timerManager.startTimer(from: preset, in: modelContext)
                        } label: {
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 12))
                                Text("Start Timer")
                                    .font(.bakeryBodyMedium(14))
                            }
                            .foregroundColor(.flourWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                                    .fill(Color.terracotta)
                            )
                        }
                        .buttonStyle(.plain)

                        Menu {
                            Button {
                                showingTimerPicker = true
                            } label: {
                                Label("Change Timer", systemImage: "arrow.triangle.2.circlepath")
                            }
                            Button(role: .destructive) {
                                recipe.timerPresetName = nil
                                recipe.lastModifiedDate = Date()
                            } label: {
                                Label("Remove Timer", systemImage: "minus.circle")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.stoneGray)
                                .frame(width: 36, height: 36)
                                .background(
                                    RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                                        .fill(Color.panCrumb)
                                )
                        }
                    }
                }
            } else {
                // No timer linked
                Button {
                    showingTimerPicker = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Add a bake timer")
                                .font(.bakeryBodyMedium(15))
                                .foregroundColor(.inkBrown)
                            Text("Track each step of your bake")
                                .font(.bakeryBody(13))
                                .foregroundColor(.stoneGray)
                        }

                        Spacer()

                        Image(systemName: "timer")
                            .font(.system(size: 18))
                            .foregroundColor(.terracotta)
                    }
                    .padding(Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                            .fill(Color.terracotta.opacity(0.08))
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.lg)
        .warmCard()
    }

    // MARK: - Dough Temperature Section

    private var doughTemperatureSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Dough Temperature")
                .sectionHeader()

            Button {
                showingDDTCalculator = true
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Calculate water temperature")
                            .font(.bakeryBodyMedium(15))
                            .foregroundColor(.inkBrown)
                        Text("Hit your desired dough temperature")
                            .font(.bakeryBody(13))
                            .foregroundColor(.stoneGray)
                    }

                    Spacer()

                    Image(systemName: "thermometer.medium")
                        .font(.system(size: 18))
                        .foregroundColor(.terracotta)
                }
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                        .fill(Color.terracotta.opacity(0.08))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(Spacing.lg)
        .warmCard()
    }

    private var recipeHasPreferment: Bool {
        recipe.ingredients.contains { $0.section == .preferment }
    }

    // MARK: - Scale Sheet

    private var scaleSheet: some View {
        NavigationStack {
            ZStack {
                Color.panCream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Mode Picker
                        VStack(spacing: Spacing.md) {
                            Picker("Scale by", selection: $scaleMode) {
                                ForEach(ScaleMode.allCases, id: \.self) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(Spacing.lg)
                        .warmCard()

                        // Input
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text(scaleMode == .flour ? "Total Flour Weight" : "Target Dough Weight")
                                .sectionHeader()

                            HStack {
                                TextField("Amount", text: $inputAmount)
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
                                let targetValue = scaleMode == .flour ? preset.1 : doughForFlour(preset.1)

                                Button {
                                    inputAmount = String(Int(targetValue))
                                } label: {
                                    HStack {
                                        Text(preset.0)
                                            .font(.bakeryBodyMedium(15))
                                            .foregroundColor(.inkBrown)

                                        Spacer()

                                        Text(scaleMode == .flour ? "\(Int(preset.1))g flour" : "~\(Int(targetValue))g dough")
                                            .font(.bakeryMono(13))
                                            .foregroundColor(.stoneGray)

                                        if inputAmount == String(Int(targetValue)) {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.terracotta)
                                        }
                                    }
                                    .padding(Spacing.md)
                                    .background(
                                        RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                                            .fill(inputAmount == String(Int(targetValue)) ? Color.terracotta.opacity(0.08) : Color.flourWhite)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(Spacing.lg)
                        .warmCard()

                        // Preview
                        if let amount = Double(inputAmount), amount > 0 {
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                Text("Preview")
                                    .sectionHeader()

                                let newFlour = scaleMode == .flour ? amount : flourForTargetDough(amount)
                                let newDough = scaleMode == .flour ? doughForFlour(amount) : amount

                                HStack {
                                    StatCard(icon: "scalemass", label: "Flour", value: "\(Int(newFlour))g")
                                    StatCard(icon: "circle.hexagongrid", label: "Dough", value: "\(Int(newDough))g")
                                }
                            }
                            .padding(Spacing.lg)
                            .warmCard()
                        }
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle("Scale Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingScaleSheet = false
                    }
                    .foregroundColor(.stoneGray)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        applyScale()
                    }
                    .font(.bakeryBodyMedium(16))
                    .foregroundColor(.terracotta)
                    .disabled(Double(inputAmount) == nil || Double(inputAmount)! <= 0)
                }
            }
            .onChange(of: scaleMode) { _, newMode in
                if let amount = Double(inputAmount), amount > 0 {
                    if newMode == .dough {
                        inputAmount = String(Int(doughForFlour(amount)))
                    } else {
                        inputAmount = String(Int(flourForTargetDough(amount)))
                    }
                }
            }
        }
        .presentationDetents([.large])
    }

    // MARK: - Computed Properties

    private var totalDoughWeight: Double {
        recipe.ingredients.reduce(0) { $0 + $1.weight(basedOn: recipe.totalFlourGrams) }
    }

    private var sectionsWithIngredients: [IngredientSection] {
        let sections = Set(recipe.ingredients.map { $0.section })
        return IngredientSection.allCases.filter { sections.contains($0) }
    }

    private func ingredientsFor(section: IngredientSection) -> [Ingredient] {
        recipe.ingredients.filter { $0.section == section }
    }

    // MARK: - Helper Functions

    private func formatWeight(_ grams: Double) -> String {
        if useMetricUnits {
            if grams == grams.rounded() {
                return "\(Int(grams))g"
            } else {
                return String(format: "%.1fg", grams)
            }
        } else {
            let ounces = grams / 28.3495
            return String(format: "%.1f oz", ounces)
        }
    }

    private func formatPercentage(_ value: Double) -> String {
        let rounded = (value * 10).rounded() / 10
        if rounded == rounded.rounded() {
            return "\(Int(rounded))%"
        } else {
            return String(format: "%.1f%%", rounded)
        }
    }

    private func generateShareItems() -> [Any] {
        var items: [Any] = []

        var text = "\(recipe.name)\n"
        if !recipe.notes.isEmpty {
            text += "\(recipe.notes)\n"
        }
        text += "\nTotal Flour: \(formatWeight(recipe.totalFlourGrams))\n"
        text += "Hydration: \(Int(recipe.hydrationPercentage))%\n"
        text += "Total Dough: \(formatWeight(totalDoughWeight))\n\n"

        for section in sectionsWithIngredients {
            text += "[\(section.rawValue)]\n"
            for ingredient in ingredientsFor(section: section) {
                let weight = formatWeight(ingredient.weight(basedOn: recipe.totalFlourGrams))
                text += "• \(ingredient.name): \(weight) (\(formatPercentage(ingredient.percentage * 100)))\n"
            }
            text += "\n"
        }

        if !recipe.tags.isEmpty {
            text += "Tags: \(recipe.tags.joined(separator: ", "))\n"
        }

        text += "\n— Shared from Shokupan"

        items.append(text)

        if let photoData = recipe.photoData, let image = UIImage(data: photoData) {
            items.append(image)
        }

        return items
    }

    private func doughForFlour(_ flour: Double) -> Double {
        let totalPercentage = recipe.ingredients.reduce(0.0) { $0 + $1.percentage }
        return flour * totalPercentage
    }

    private func flourForTargetDough(_ targetDough: Double) -> Double {
        let totalPercentage = recipe.ingredients.reduce(0.0) { $0 + $1.percentage }
        guard totalPercentage > 0 else { return targetDough }
        return targetDough / totalPercentage
    }

    private func applyScale() {
        guard let amount = Double(inputAmount), amount > 0 else {
            showingScaleSheet = false
            return
        }

        if scaleMode == .flour {
            recipe.totalFlourGrams = amount
        } else {
            recipe.totalFlourGrams = flourForTargetDough(amount)
        }
        recipe.lastModifiedDate = Date()
        showingScaleSheet = false
    }

    private func deleteIngredients(in section: IngredientSection, at offsets: IndexSet) {
        let sectionIngredients = ingredientsFor(section: section)
        for index in offsets {
            if let ingredientIndex = recipe.ingredients.firstIndex(where: { $0.id == sectionIngredients[index].id }) {
                recipe.ingredients.remove(at: ingredientIndex)
            }
        }
        recipe.lastModifiedDate = Date()
    }

    private func cloneRecipe() {
        let cloned = recipe.clone(newName: cloneName)
        modelContext.insert(cloned)
    }

    private func addTag() {
        let trimmed = newTag.trimmingCharacters(in: .whitespaces).lowercased()
        if !trimmed.isEmpty && !recipe.tags.contains(trimmed) {
            recipe.tags.append(trimmed)
            recipe.lastModifiedDate = Date()
        }
        newTag = ""
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .light))
                .foregroundColor(.terracotta.opacity(0.8))

            Text(value)
                .font(.bakeryMono(16))
                .foregroundColor(.inkBrown)

            Text(label)
                .font(.bakeryBody(11))
                .foregroundColor(.stoneGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                .fill(Color.flourWhite)
        )
    }
}

struct IngredientRow: View {
    let ingredient: Ingredient
    let weight: String

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

            VStack(alignment: .trailing, spacing: 2) {
                Text(weight)
                    .font(.bakeryMono(15))
                    .foregroundColor(.inkBrown)

                Text(formatPercentage(ingredient.percentage * 100))
                    .font(.bakeryMono(12))
                    .foregroundColor(.stoneGray)
            }
        }
        .padding(.vertical, Spacing.sm)
    }
}

// MARK: - Flow Layout for Tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var frames: [CGRect] = []

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: currentY + lineHeight), frames)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Camera Picker

struct CameraPicker: UIViewControllerRepresentable {
    var onImagePicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var onImagePicked: (UIImage) -> Void

        init(onImagePicked: @escaping (UIImage) -> Void) {
            self.onImagePicked = onImagePicked
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImagePicked(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Timer Preset Picker Sheet

struct TimerPresetPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let presets: [TimerPreset]
    let selectedPresetName: String?
    let onSelect: (String?) -> Void

    private var builtInPresets: [TimerPreset] {
        presets.filter { $0.isBuiltIn }
    }

    private var userPresets: [TimerPreset] {
        presets.filter { !$0.isBuiltIn }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.panCream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // None option
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Button {
                                onSelect(nil)
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "xmark.circle")
                                        .font(.system(size: 16))
                                        .foregroundColor(.stoneGray)

                                    Text("No Timer")
                                        .font(.bakeryBodyMedium(15))
                                        .foregroundColor(.inkBrown)

                                    Spacer()

                                    if selectedPresetName == nil {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.terracotta)
                                    }
                                }
                                .padding(Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                                        .fill(selectedPresetName == nil ? Color.terracotta.opacity(0.08) : Color.flourWhite)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(Spacing.lg)
                        .warmCard()

                        // Built-in Presets
                        if !builtInPresets.isEmpty {
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                Text("Built-in Timers")
                                    .sectionHeader()

                                ForEach(builtInPresets) { preset in
                                    timerPresetRow(preset)

                                    if preset.id != builtInPresets.last?.id {
                                        WarmDivider()
                                    }
                                }
                            }
                            .padding(Spacing.lg)
                            .warmCard()
                        }

                        // User Presets
                        if !userPresets.isEmpty {
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                Text("My Timers")
                                    .sectionHeader()

                                ForEach(userPresets) { preset in
                                    timerPresetRow(preset)

                                    if preset.id != userPresets.last?.id {
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
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Choose Timer")
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
        .presentationDetents([.medium, .large])
    }

    private func timerPresetRow(_ preset: TimerPreset) -> some View {
        Button {
            onSelect(preset.name)
            dismiss()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack(spacing: Spacing.sm) {
                        Text(preset.name)
                            .font(.bakeryBodyMedium(15))
                            .foregroundColor(.inkBrown)

                        if preset.isBuiltIn {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.terracotta.opacity(0.6))
                        }
                    }

                    HStack(spacing: Spacing.sm) {
                        Text("\(preset.steps.count) steps")
                            .font(.bakeryBody(12))
                            .foregroundColor(.stoneGray)

                        Text("•")
                            .foregroundColor(.stoneGray)

                        Text(preset.totalDuration.shortFormatted)
                            .font(.bakeryMono(12))
                            .foregroundColor(.stoneGray)
                    }
                }

                Spacer()

                if selectedPresetName == preset.name {
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

struct RecipeDetailPreview: View {
    @State var recipe: Recipe

    init() {
        let r = Recipe(name: "Shokupan", totalFlourGrams: 250, notes: "First attempt at Japanese milk bread. Very soft and fluffy!", tags: ["japanese", "milk bread"])
        r.ingredients.append(Ingredient(name: "Bread Flour", percentage: 1.0, section: .finalDough))
        r.ingredients.append(Ingredient(name: "Water", percentage: 0.65, section: .finalDough))
        r.ingredients.append(Ingredient(name: "Sugar", percentage: 0.08, section: .finalDough))
        r.ingredients.append(Ingredient(name: "Flour", percentage: 0.2, section: .preferment))
        r.ingredients.append(Ingredient(name: "Water", percentage: 0.2, section: .preferment))
        _recipe = State(initialValue: r)
    }

    var body: some View {
        NavigationStack {
            RecipeDetailView(recipe: recipe)
        }
    }
}

#Preview {
    RecipeDetailPreview()
        .modelContainer(for: [Recipe.self, Ingredient.self, TimerPreset.self, TimerPresetStep.self, BakeTimer.self, BakeTimerStep.self], inMemory: true)
}
