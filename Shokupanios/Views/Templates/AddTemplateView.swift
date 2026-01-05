import SwiftUI
import SwiftData

struct AddTemplateView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var descriptionText = ""
    @State private var instructions = ""

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

                            TextField("Optional short description", text: $descriptionText)
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
                                    Text("Step-by-step instructions (optional)...")
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
        let newTemplate = RecipeTemplate(name: name, descriptionText: descriptionText, instructions: instructions, isBuiltIn: false)
        modelContext.insert(newTemplate)
        dismiss()
    }
}

#Preview {
    AddTemplateView()
        .modelContainer(for: [RecipeTemplate.self, TemplateIngredient.self], inMemory: true)
}
