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
                    List {
                        // Built-in Templates Section
                        if !builtInTemplates.isEmpty {
                            Section {
                                HStack(spacing: Spacing.sm) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.crustBrown)
                                    Text("Built-in Templates")
                                        .sectionHeader()
                                }
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: Spacing.sm, leading: Spacing.md, bottom: Spacing.xs, trailing: Spacing.md))
                                .listRowSeparator(.hidden)

                                ForEach(builtInTemplates) { template in
                                    NavigationLink(destination: TemplateDetailView(template: template)) {
                                        TemplateCard(template: template)
                                    }
                                    .buttonStyle(.plain)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets(top: Spacing.sm / 2, leading: Spacing.md, bottom: Spacing.sm / 2, trailing: Spacing.md))
                                    .listRowSeparator(.hidden)
                                }
                            }
                        }

                        // User Templates Section
                        Section {
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.crustBrown)
                                Text("My Templates")
                                    .sectionHeader()
                            }
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: Spacing.sm, leading: Spacing.md, bottom: Spacing.xs, trailing: Spacing.md))
                            .listRowSeparator(.hidden)

                            if userTemplates.isEmpty {
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
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: Spacing.sm / 2, leading: Spacing.md, bottom: Spacing.sm / 2, trailing: Spacing.md))
                                .listRowSeparator(.hidden)
                            } else {
                                ForEach(userTemplates) { template in
                                    NavigationLink(destination: TemplateDetailView(template: template)) {
                                        TemplateCard(template: template)
                                    }
                                    .buttonStyle(.plain)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets(top: Spacing.sm / 2, leading: Spacing.md, bottom: Spacing.sm / 2, trailing: Spacing.md))
                                    .listRowSeparator(.hidden)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            templateToDelete = template
                                            showingDeleteConfirmation = true
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
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
    var onDelete: (() -> Void)? = nil

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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .warmCard(elevated: false)
    }
}

#Preview {
    TemplateListView()
        .modelContainer(for: [RecipeTemplate.self, TemplateIngredient.self], inMemory: true)
}
