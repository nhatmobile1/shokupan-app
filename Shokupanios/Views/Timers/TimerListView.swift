import SwiftUI
import SwiftData

struct TimerListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TimerPreset.name) private var presets: [TimerPreset]
    private var timerManager = TimerManager.shared

    @State private var showingAddPreset = false
    @State private var presetToDelete: TimerPreset?
    @State private var showingDeleteConfirmation = false

    var builtInPresets: [TimerPreset] {
        presets.filter { $0.isBuiltIn }
    }

    var userPresets: [TimerPreset] {
        presets.filter { !$0.isBuiltIn }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmGradientBackground()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Active Timer (if any)
                        if let activeTimer = timerManager.activeTimer, !activeTimer.isCompleted {
                            activeTimerCard(activeTimer)
                        }

                        // Built-in Presets
                        if !builtInPresets.isEmpty {
                            presetsSection(title: "Built-in Timers", presets: builtInPresets, canDelete: false)
                        }

                        // User Presets
                        if !userPresets.isEmpty {
                            presetsSection(title: "My Timers", presets: userPresets, canDelete: true)
                        }

                        // Empty state if no presets
                        if presets.isEmpty {
                            EmptyStateView(
                                icon: "timer",
                                title: "No Timers Yet",
                                message: "Create timer presets for your baking schedules",
                                actionTitle: "Create Timer",
                                action: { showingAddPreset = true }
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Timers")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddPreset = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.terracotta)
                    }
                }
            }
            .sheet(isPresented: $showingAddPreset) {
                AddTimerView()
            }
            .alert("Delete Timer?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    presetToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let preset = presetToDelete {
                        deletePreset(preset)
                    }
                }
            } message: {
                if let preset = presetToDelete {
                    Text("Are you sure you want to delete \"\(preset.name)\"?")
                }
            }
            .onAppear {
                timerManager.configure(with: modelContext)
                DefaultTimerPresets.seedPresets(in: modelContext)
                timerManager.requestNotificationPermission()
            }
        }
        .tint(.terracotta)
    }

    // MARK: - Active Timer Card

    private func activeTimerCard(_ timer: BakeTimer) -> some View {
        NavigationLink(destination: TimerDetailView(timer: timer)) {
            VStack(spacing: Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack(spacing: Spacing.sm) {
                            Circle()
                                .fill(timerManager.isRunning ? Color.green : Color.orange)
                                .frame(width: 8, height: 8)

                            Text(timerManager.isRunning ? "Running" : "Paused")
                                .font(.bakeryBody(12))
                                .foregroundColor(timerManager.isRunning ? .green : .orange)
                        }

                        Text(timer.name)
                            .font(.bakerySerifMedium(20))
                            .foregroundColor(.inkBrown)
                    }

                    Spacer()

                    Text(timerManager.displayTime.formatted)
                        .font(.bakeryMono(32))
                        .foregroundColor(.terracotta)
                }

                if let step = timer.currentStep {
                    HStack {
                        Text(step.name)
                            .font(.bakeryBody(14))
                            .foregroundColor(.stoneGray)

                        Spacer()

                        Text("Step \(timer.currentStepIndex + 1) of \(timer.steps.count)")
                            .font(.bakeryBody(12))
                            .foregroundColor(.stoneGray)
                    }

                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.panCrumb)
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.terracotta)
                                .frame(width: geometry.size.width * timer.overallProgress, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
            }
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                    .fill(Color.flourWhite)
                    .shadow(color: Color.terracotta.opacity(0.15), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                    .stroke(Color.terracotta.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Presets Section

    private func presetsSection(title: String, presets: [TimerPreset], canDelete: Bool) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(title)
                .sectionHeader()
                .padding(.leading, Spacing.sm)

            VStack(spacing: Spacing.sm) {
                ForEach(presets) { preset in
                    TimerPresetCard(
                        preset: preset,
                        onStart: { startTimer(from: preset) },
                        onDelete: canDelete ? {
                            presetToDelete = preset
                            showingDeleteConfirmation = true
                        } : nil
                    )
                }
            }
        }
    }

    // MARK: - Actions

    private func startTimer(from preset: TimerPreset) {
        timerManager.startTimer(from: preset, in: modelContext)
    }

    private func deletePreset(_ preset: TimerPreset) {
        modelContext.delete(preset)
        presetToDelete = nil
    }
}

// MARK: - Timer Preset Card

struct TimerPresetCard: View {
    let preset: TimerPreset
    let onStart: () -> Void
    var onDelete: (() -> Void)?

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.terracotta.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: "timer")
                    .font(.system(size: 18))
                    .foregroundColor(.terracotta)
            }

            // Content
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack(spacing: Spacing.sm) {
                    Text(preset.name)
                        .font(.bakeryBodyMedium(16))
                        .foregroundColor(.inkBrown)

                    if preset.isBuiltIn {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.terracotta.opacity(0.6))
                    }
                }

                HStack(spacing: Spacing.sm) {
                    Label("\(preset.steps.count) steps", systemImage: "list.number")
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

            // Start Button
            Button(action: onStart) {
                Image(systemName: "play.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.flourWhite)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.terracotta))
            }
        }
        .padding(Spacing.md)
        .warmCard()
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if let onDelete = onDelete {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

#Preview {
    TimerListView()
        .modelContainer(for: [TimerPreset.self, TimerPresetStep.self, BakeTimer.self, BakeTimerStep.self], inMemory: true)
}
