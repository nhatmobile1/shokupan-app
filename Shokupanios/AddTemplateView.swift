import SwiftUI
import SwiftData

struct AddTemplateView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var descriptionText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Template Details") {
                    TextField("Template Name", text: $name)
                    TextField("Description (optional)", text: $descriptionText)
                }

                Section {
                    Text("After creating the template, you can add ingredients from the detail view.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        saveTemplate()
                    }
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
