import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.lastModifiedDate, order: .reverse) private var recipes: [Recipe]
    @State private var showingAddRecipe = false
    @State private var searchText = ""
    @State private var filterTag: String?
    @State private var hydrationFilter: HydrationRange = .any
    @State private var recipeToDelete: Recipe?
    @State private var showingDeleteConfirmation = false

    enum HydrationRange: String, CaseIterable {
        case any = "Any"
        case low = "< 65%"
        case medium = "65-75%"
        case high = "> 75%"

        var icon: String {
            switch self {
            case .any: return "drop"
            case .low: return "drop.fill"
            case .medium: return "drop.halffull"
            case .high: return "drop.fill"
            }
        }
    }

    var filteredRecipes: [Recipe] {
        recipes.filter { recipe in
            let matchesSearch = searchText.isEmpty ||
                recipe.name.localizedCaseInsensitiveContains(searchText) ||
                recipe.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }

            let matchesTag = filterTag == nil || recipe.tags.contains(filterTag!)

            let matchesHydration: Bool
            switch hydrationFilter {
            case .any:
                matchesHydration = true
            case .low:
                matchesHydration = recipe.hydrationPercentage < 65
            case .medium:
                matchesHydration = recipe.hydrationPercentage >= 65 && recipe.hydrationPercentage <= 75
            case .high:
                matchesHydration = recipe.hydrationPercentage > 75
            }

            return matchesSearch && matchesTag && matchesHydration
        }
    }

    var allTags: [String] {
        Array(Set(recipes.flatMap { $0.tags })).sorted()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmGradientBackground()

                if recipes.isEmpty {
                    EmptyStateView(
                        icon: "oven",
                        title: "No Recipes Yet",
                        message: "Start your baking journey by creating your first recipe",
                        actionTitle: "Create Recipe",
                        action: { showingAddRecipe = true }
                    )
                } else {
                    List {
                        // Filter Section
                        if !allTags.isEmpty {
                            Section {
                                filterSection
                            }
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 0, leading: Spacing.md, bottom: 0, trailing: Spacing.md))
                            .listRowSeparator(.hidden)
                        }

                        // Recipe Cards
                        Section {
                            ForEach(filteredRecipes) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                    RecipeCard(recipe: recipe)
                                }
                                .buttonStyle(.plain)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: Spacing.sm / 2, leading: Spacing.md, bottom: Spacing.sm / 2, trailing: Spacing.md))
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        recipeToDelete = recipe
                                        showingDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }

                            if filteredRecipes.isEmpty && !recipes.isEmpty {
                                noResultsView
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search recipes..."
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddRecipe = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.terracotta)
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView()
            }
            .alert("Delete Recipe?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    recipeToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let recipe = recipeToDelete {
                        deleteRecipe(recipe)
                    }
                }
            } message: {
                if let recipe = recipeToDelete {
                    Text("Are you sure you want to delete \"\(recipe.name)\"? This cannot be undone.")
                }
            }
        }
        .tint(.terracotta)
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Hydration Filter
            HStack(spacing: Spacing.sm) {
                ForEach(HydrationRange.allCases, id: \.self) { range in
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            hydrationFilter = range
                        }
                    } label: {
                        HStack(spacing: 4) {
                            if range != .any {
                                Image(systemName: range.icon)
                                    .font(.system(size: 10))
                            }
                            Text(range.rawValue)
                        }
                        .tagChip(selected: hydrationFilter == range)
                    }
                    .buttonStyle(.plain)
                }
            }

            // Tag Filter
            if !allTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) {
                                filterTag = nil
                            }
                        } label: {
                            Text("All")
                                .tagChip(selected: filterTag == nil)
                        }
                        .buttonStyle(.plain)

                        ForEach(allTags, id: \.self) { tag in
                            Button {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    filterTag = filterTag == tag ? nil : tag
                                }
                            } label: {
                                Text(tag)
                                    .tagChip(selected: filterTag == tag)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .padding(.vertical, Spacing.sm)
    }

    private var noResultsView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(.stoneGray.opacity(0.5))

            Text("No recipes found")
                .font(.bakeryBodyDynamic)
                .foregroundColor(.stoneGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
    }

    private func deleteRecipe(_ recipe: Recipe) {
        modelContext.delete(recipe)
        recipeToDelete = nil
    }
}

// MARK: - Recipe Card

struct RecipeCard: View {
    let recipe: Recipe
    @AppStorage("useMetricUnits") private var useMetricUnits = true

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Thumbnail
            recipeImage
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous))

            // Content
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(recipe.name)
                    .font(.bakeryTitle)
                    .foregroundColor(.inkBrown)
                    .lineLimit(1)

                // Metadata row
                HStack(spacing: Spacing.md) {
                    FlourWeightBadge(weight: formatWeight(recipe.totalFlourGrams))

                    if recipe.hydrationPercentage > 0 {
                        HydrationIndicator(percentage: Int(recipe.hydrationPercentage))
                    }
                }

                // Tags
                if !recipe.tags.isEmpty {
                    HStack(spacing: Spacing.xs) {
                        ForEach(recipe.tags.prefix(2), id: \.self) { tag in
                            ColoredTagChipOutlined(tag: tag)
                        }
                        if recipe.tags.count > 2 {
                            Text("+\(recipe.tags.count - 2)")
                                .font(.bakeryCaption)
                                .foregroundColor(.stoneGray)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .warmCard(elevated: false)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(recipe.name), \(formatWeight(recipe.totalFlourGrams)) flour, \(Int(recipe.hydrationPercentage))% hydration")
    }

    @ViewBuilder
    private var recipeImage: some View {
        if let photoData = recipe.photoData, let uiImage = UIImage(data: photoData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                Color.panCrumb
                Image(systemName: "photo")
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(.crustBrown.opacity(0.4))
            }
        }
    }

    private func formatWeight(_ grams: Double) -> String {
        if useMetricUnits {
            if grams == grams.rounded() {
                return "\(Int(grams))g"
            } else {
                return String(format: "%.1fg", grams)
            }
        } else {
            let ounces = grams / 28.3495
            return String(format: "%.1foz", ounces)
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Recipe.self, Ingredient.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let recipe1 = Recipe(name: "Shokupan", totalFlourGrams: 250, notes: "First attempt", tags: ["japanese", "milk bread"])
    recipe1.ingredients.append(Ingredient(name: "Flour", percentage: 1.0, section: .finalDough))
    recipe1.ingredients.append(Ingredient(name: "Water", percentage: 0.65, section: .finalDough))
    container.mainContext.insert(recipe1)

    let recipe2 = Recipe(name: "Sourdough Boule", totalFlourGrams: 500, notes: "", tags: ["sourdough", "artisan"])
    recipe2.ingredients.append(Ingredient(name: "Flour", percentage: 1.0, section: .finalDough))
    recipe2.ingredients.append(Ingredient(name: "Water", percentage: 0.75, section: .finalDough))
    container.mainContext.insert(recipe2)

    return RecipeListView()
        .modelContainer(container)
}
