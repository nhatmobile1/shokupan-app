import SwiftUI
import SwiftData

struct AddTemplateView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var descriptionText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.panCream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Template Name
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Template Name")
                                .sectionHeader()

                            TextField("e.g., My Sourdough", text: $name)
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

                        // Description
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Description")
                                .sectionHeader()

                            TextField("Optional description", text: $descriptionText)
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

                        // Info
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 14))
                                    .foregroundColor(.terracotta.opacity(0.7))

                                Text("After creating the template, you can add ingredients from the detail view.")
                                    .font(.bakeryBody(13))
                                    .foregroundColor(.stoneGray)
                            }
                        }
                        .padding(Spacing.lg)
                        .warmCard()
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle("New Template")
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
                        saveTemplate()
                    }
                    .font(.bakeryBodyMedium(16))
                    .foregroundColor(.terracotta)
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func saveTemplate() {
        let newTemplate = RecipeTemplate(name: name, descriptionText: descriptionText, isBuiltIn: false)
        modelContext.insert(newTemplate)
        dismiss()
    }
}

#Preview {
    AddTemplateView()
        .modelContainer(for: [RecipeTemplate.self, TemplateIngredient.self], inMemory: true)
}
