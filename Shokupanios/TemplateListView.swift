import SwiftUI
import SwiftData

struct TemplateListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RecipeTemplate.name) private var templates: [RecipeTemplate]

    @State private var showingAddTemplate = false
    @State private var templateToDelete: RecipeTemplate?
    @State private var showingDeleteConfirmation = false
    @State private var searchText = ""

    var filteredTemplates: [RecipeTemplate] {
        if searchText.isEmpty {
            return templates
        }
        return templates.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmGradientBackground()

                if templates.isEmpty {
                    EmptyStateView(
                        icon: "doc.text",
                        title: "No Templates Yet",
                        message: "Templates help you quickly start new recipes with preset ingredients",
                        actionTitle: "Create Template",
                        action: { showingAddTemplate = true }
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: Spacing.md) {
                            // Built-in Templates Section
                            if !builtInTemplates.isEmpty {
                                templateSection(
                                    title: "Built-in Templates",
                                    templates: builtInTemplates,
                                    icon: "checkmark.seal.fill"
                                )
                            }

                            // User Templates Section
                            templateSection(
                                title: "My Templates",
                                templates: userTemplates,
                                icon: "person.fill",
                                allowDelete: true
                            )
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search templates..."
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTemplate = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.terracotta)
                    }
                }
            }
            .sheet(isPresented: $showingAddTemplate) {
                AddTemplateView()
            }
            .alert("Delete Template?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    templateToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let template = templateToDelete {
                        deleteTemplate(template)
                    }
                }
            } message: {
                if let template = templateToDelete {
                    Text("Are you sure you want to delete \"\(template.name)\"? This cannot be undone.")
                }
            }
        }
        .tint(.terracotta)
    }

    // MARK: - Template Section

    @ViewBuilder
    private func templateSection(title: String, templates: [RecipeTemplate], icon: String, allowDelete: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(.crustBrown)
                Text(title)
                    .sectionHeader()
            }

            if templates.isEmpty && allowDelete {
                // Empty state for user templates
                VStack(spacing: Spacing.md) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(.crustBrown.opacity(0.4))
                    Text("No custom templates yet")
                        .font(.bakeryBody(14))
                        .foregroundColor(.stoneGray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.xl)
                .warmCard()
            } else {
                ForEach(templates) { template in
                    NavigationLink(destination: TemplateDetailView(template: template)) {
                        TemplateCard(template: template, onDelete: allowDelete ? {
                            templateToDelete = template
                            showingDeleteConfirmation = true
                        } : nil)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var builtInTemplates: [RecipeTemplate] {
        filteredTemplates.filter { $0.isBuiltIn }
    }

    private var userTemplates: [RecipeTemplate] {
        filteredTemplates.filter { !$0.isBuiltIn }
    }

    // MARK: - Actions

    private func deleteTemplate(_ template: RecipeTemplate) {
        modelContext.delete(template)
        templateToDelete = nil
    }
}

// MARK: - Template Card

struct TemplateCard: View {
    let template: RecipeTemplate
    var onDelete: (() -> Void)?

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                    .fill(template.isBuiltIn ? Color.terracotta.opacity(0.12) : Color.crustBrown.opacity(0.12))
                    .frame(width: 56, height: 56)

                Image(systemName: template.isBuiltIn ? "doc.text.fill" : "doc.text")
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(template.isBuiltIn ? .terracotta : .crustBrown)
            }

            // Content
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack(spacing: Spacing.sm) {
                    Text(template.name)
                        .font(.bakerySerifMedium(17))
                        .foregroundColor(.inkBrown)
                        .lineLimit(1)

                    if template.isBuiltIn {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.terracotta)
                    }
                }

                if !template.descriptionText.isEmpty {
                    Text(template.descriptionText)
                        .font(.bakeryBody(13))
                        .foregroundColor(.stoneGray)
                        .lineLimit(2)
                }

                // Metadata
                HStack(spacing: Spacing.md) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 10))
                        Text("\(template.ingredients.count)")
                    }
                    .font(.bakeryBody(12))
                    .foregroundColor(.stoneGray)

                    if template.hydrationPercentage > 0 {
                        HydrationIndicator(percentage: Int(template.hydrationPercentage))
                    }
                }
            }

            Spacer()

            // Delete or Chevron
            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.stoneGray.opacity(0.6))
                }
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.stoneGray.opacity(0.4))
            }
        }
        .padding(Spacing.md)
        .warmCard(elevated: false)
    }
}

#Preview {
    TemplateListView()
        .modelContainer(for: [RecipeTemplate.self, TemplateIngredient.self], inMemory: true)
}
