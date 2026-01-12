import SwiftUI
import SwiftData

struct AddTimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var descriptionText = ""
    @State private var steps: [EditableStep] = []
    @State private var showingAddStep = false

    // For editing an existing preset
    var existingPreset: TimerPreset?

    init(preset: TimerPreset? = nil) {
        self.existingPreset = preset
        if let preset = preset {
            _name = State(initialValue: preset.name)
            _descriptionText = State(initialValue: preset.descriptionText)
            _steps = State(initialValue: preset.steps
                .sorted { $0.order < $1.order }
                .map { EditableStep(name: $0.name, hours: Int($0.duration) / 3600, minutes: (Int($0.duration) % 3600) / 60) }
            )
        }
    }

    var totalDuration: TimeInterval {
        steps.reduce(0) { $0 + $1.duration }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.panCream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Timer Details
                        detailsSection

                        // Quick Presets (for new timers only)
                        if existingPreset == nil && steps.isEmpty {
                            quickPresetsSection
                        }

                        // Steps
                        stepsSection

                        // Summary
                        if !steps.isEmpty {
                            summarySection
                        }
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle(existingPreset != nil ? "Edit Timer" : "New Timer")
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
                        savePreset()
                    }
                    .font(.bakeryBodyMedium(16))
                    .foregroundColor(.terracotta)
                    .disabled(name.isEmpty || steps.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddStep) {
                AddStepSheet { newStep in
                    steps.append(newStep)
                }
            }
        }
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Timer Details")
                .sectionHeader()

            TextField("Timer Name", text: $name)
                .font(.bakeryBody(16))
                .foregroundColor(.inkBrown)
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                        .fill(Color.flourWhite)
                )

            TextField("Description (optional)", text: $descriptionText)
                .font(.bakeryBody(14))
                .foregroundColor(.inkBrown)
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                        .fill(Color.flourWhite)
                )
        }
        .padding(Spacing.lg)
        .warmCard()
    }

    // MARK: - Quick Presets Section

    private var quickPresetsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Quick Start")
                .sectionHeader()

            Text("Start with a common baking schedule:")
                .font(.bakeryBody(13))
                .foregroundColor(.stoneGray)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                QuickPresetButton(title: "Simple Proof", subtitle: "2 steps") {
                    name = "Simple Proof"
                    steps = [
                        EditableStep(name: "Bulk Rise", hours: 1, minutes: 0),
                        EditableStep(name: "Final Proof", hours: 0, minutes: 45),
                    ]
                }

                QuickPresetButton(title: "Sourdough", subtitle: "4 steps") {
                    name = "Sourdough"
                    steps = [
                        EditableStep(name: "Autolyse", hours: 0, minutes: 30),
                        EditableStep(name: "Bulk Fermentation", hours: 4, minutes: 0),
                        EditableStep(name: "Final Proof", hours: 1, minutes: 0),
                        EditableStep(name: "Bake", hours: 0, minutes: 45),
                    ]
                }

                QuickPresetButton(title: "Enriched", subtitle: "3 steps") {
                    name = "Enriched Bread"
                    steps = [
                        EditableStep(name: "First Rise", hours: 1, minutes: 30),
                        EditableStep(name: "Second Rise", hours: 1, minutes: 0),
                        EditableStep(name: "Bake", hours: 0, minutes: 35),
                    ]
                }

                QuickPresetButton(title: "Custom", subtitle: "Start fresh") {
                    showingAddStep = true
                }
            }
        }
        .padding(Spacing.lg)
        .warmCard()
    }

    // MARK: - Steps Section

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Steps")
                    .sectionHeader()

                Spacer()

                Button {
                    showingAddStep = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.terracotta)
                }
            }

            if steps.isEmpty {
                VStack(spacing: Spacing.md) {
                    Image(systemName: "list.number")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(.crustBrown.opacity(0.4))

                    Text("No steps yet")
                        .font(.bakeryBody(14))
                        .foregroundColor(.stoneGray)

                    Button("Add First Step") {
                        showingAddStep = true
                    }
                    .font(.bakeryBodyMedium(14))
                    .foregroundColor(.terracotta)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.xl)
            } else {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    EditableStepRow(
                        step: $steps[index],
                        stepNumber: index + 1,
                        onDelete: {
                            steps.remove(at: index)
                        }
                    )

                    if index < steps.count - 1 {
                        WarmDivider()
                    }
                }
                .onMove { from, to in
                    steps.move(fromOffsets: from, toOffset: to)
                }
            }
        }
        .padding(Spacing.lg)
        .warmCard()
    }

    // MARK: - Summary Section

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Summary")
                .sectionHeader()

            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Total Duration")
                        .font(.bakeryBody(13))
                        .foregroundColor(.stoneGray)

                    Text(totalDuration.shortFormatted)
                        .font(.bakeryMono(20))
                        .foregroundColor(.inkBrown)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    Text("Steps")
                        .font(.bakeryBody(13))
                        .foregroundColor(.stoneGray)

                    Text("\(steps.count)")
                        .font(.bakeryMono(20))
                        .foregroundColor(.inkBrown)
                }
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                    .fill(Color.terracotta.opacity(0.08))
            )
        }
        .padding(Spacing.lg)
        .warmCard()
    }

    // MARK: - Save

    private func savePreset() {
        if let existing = existingPreset {
            // Update existing
            existing.name = name
            existing.descriptionText = descriptionText

            // Remove old steps
            for step in existing.steps {
                modelContext.delete(step)
            }
            existing.steps = []

            // Add new steps
            for (index, editableStep) in steps.enumerated() {
                let step = TimerPresetStep(
                    name: editableStep.name,
                    duration: editableStep.duration,
                    order: index
                )
                existing.steps.append(step)
            }
        } else {
            // Create new
            let preset = TimerPreset(name: name, descriptionText: descriptionText)

            for (index, editableStep) in steps.enumerated() {
                let step = TimerPresetStep(
                    name: editableStep.name,
                    duration: editableStep.duration,
                    order: index
                )
                preset.steps.append(step)
            }

            modelContext.insert(preset)
        }

        dismiss()
    }
}

// MARK: - Editable Step Model

struct EditableStep: Identifiable {
    let id = UUID()
    var name: String
    var hours: Int
    var minutes: Int

    var duration: TimeInterval {
        TimeInterval(hours * 3600 + minutes * 60)
    }
}

// MARK: - Editable Step Row

struct EditableStepRow: View {
    @Binding var step: EditableStep
    let stepNumber: Int
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Step number
            ZStack {
                Circle()
                    .fill(Color.terracotta.opacity(0.15))
                    .frame(width: 28, height: 28)

                Text("\(stepNumber)")
                    .font(.bakeryMono(12))
                    .foregroundColor(.terracotta)
            }

            // Step name
            TextField("Step name", text: $step.name)
                .font(.bakeryBody(15))
                .foregroundColor(.inkBrown)

            Spacer()

            // Duration
            HStack(spacing: 4) {
                Picker("Hours", selection: $step.hours) {
                    ForEach(0..<24, id: \.self) { h in
                        Text("\(h)h").tag(h)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()

                Picker("Minutes", selection: $step.minutes) {
                    ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { m in
                        Text("\(m)m").tag(m)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
            }
            .font(.bakeryMono(13))

            // Delete
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(.red.opacity(0.7))
            }
        }
        .padding(.vertical, Spacing.sm)
    }
}

// MARK: - Quick Preset Button

struct QuickPresetButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Text(title)
                    .font(.bakeryBodyMedium(14))
                    .foregroundColor(.inkBrown)

                Text(subtitle)
                    .font(.bakeryBody(11))
                    .foregroundColor(.stoneGray)
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                    .fill(Color.flourWhite)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Add Step Sheet

struct AddStepSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var hours = 0
    @State private var minutes = 30

    let onAdd: (EditableStep) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.panCream.ignoresSafeArea()

                VStack(spacing: Spacing.lg) {
                    // Step Name
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Step Name")
                            .sectionHeader()

                        TextField("e.g., Bulk Fermentation", text: $name)
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

                    // Duration
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Duration")
                            .sectionHeader()

                        HStack(spacing: Spacing.lg) {
                            VStack(spacing: Spacing.xs) {
                                Picker("Hours", selection: $hours) {
                                    ForEach(0..<24, id: \.self) { h in
                                        Text("\(h)").tag(h)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 80, height: 120)
                                .clipped()

                                Text("hours")
                                    .font(.bakeryBody(12))
                                    .foregroundColor(.stoneGray)
                            }

                            VStack(spacing: Spacing.xs) {
                                Picker("Minutes", selection: $minutes) {
                                    ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { m in
                                        Text("\(m)").tag(m)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 80, height: 120)
                                .clipped()

                                Text("minutes")
                                    .font(.bakeryBody(12))
                                    .foregroundColor(.stoneGray)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(Spacing.lg)
                    .warmCard()

                    Spacer()
                }
                .padding(Spacing.md)
            }
            .navigationTitle("Add Step")
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
                        let step = EditableStep(name: name, hours: hours, minutes: minutes)
                        onAdd(step)
                        dismiss()
                    }
                    .font(.bakeryBodyMedium(16))
                    .foregroundColor(.terracotta)
                    .disabled(name.isEmpty || (hours == 0 && minutes == 0))
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    AddTimerView()
        .modelContainer(for: [TimerPreset.self, TimerPresetStep.self], inMemory: true)
}
