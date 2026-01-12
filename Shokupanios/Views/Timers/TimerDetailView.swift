import SwiftUI
import SwiftData

struct TimerDetailView: View {
    @Environment(\.dismiss) private var dismiss
    private var timerManager = TimerManager.shared
    @Bindable var timer: BakeTimer

    init(timer: BakeTimer) {
        self.timer = timer
    }

    var body: some View {
        ZStack {
            WarmGradientBackground()

            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Main countdown display
                    countdownSection

                    // Current step info
                    if let step = timer.currentStep {
                        currentStepSection(step)
                    }

                    // Control buttons
                    controlsSection

                    // All steps list
                    stepsListSection
                }
                .padding(Spacing.md)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(timer.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(role: .destructive) {
                        timerManager.resetTimer()
                    } label: {
                        Label("Reset Timer", systemImage: "arrow.counterclockwise")
                    }

                    Button(role: .destructive) {
                        timerManager.stopTimer()
                        dismiss()
                    } label: {
                        Label("Stop & Exit", systemImage: "xmark")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.terracotta)
                }
            }
        }
    }

    // MARK: - Countdown Section

    private var countdownSection: some View {
        VStack(spacing: Spacing.md) {
            // Large countdown
            Text(timerManager.displayTime.formatted)
                .font(.system(size: 72, weight: .light, design: .monospaced))
                .foregroundColor(.inkBrown)
                .monospacedDigit()

            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.panCrumb, lineWidth: 8)
                    .frame(width: 200, height: 200)

                Circle()
                    .trim(from: 0, to: timer.overallProgress)
                    .stroke(Color.terracotta, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.5), value: timer.overallProgress)

                VStack(spacing: Spacing.xs) {
                    Text("\(Int(timer.overallProgress * 100))%")
                        .font(.bakeryMono(24))
                        .foregroundColor(.terracotta)

                    Text("Complete")
                        .font(.bakeryBody(12))
                        .foregroundColor(.stoneGray)
                }
            }
        }
        .padding(Spacing.lg)
        .warmCard()
    }

    // MARK: - Current Step Section

    private func currentStepSection(_ step: BakeTimerStep) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Current Step")
                    .sectionHeader()

                Spacer()

                Text("Step \(timer.currentStepIndex + 1) of \(timer.steps.count)")
                    .font(.bakeryBody(12))
                    .foregroundColor(.stoneGray)
            }

            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(step.name)
                        .font(.bakerySerifMedium(20))
                        .foregroundColor(.inkBrown)

                    Text("Duration: \(step.formattedDuration)")
                        .font(.bakeryBody(14))
                        .foregroundColor(.stoneGray)
                }

                Spacer()

                // Step progress
                CircularProgressView(progress: step.progress)
                    .frame(width: 50, height: 50)
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

    // MARK: - Controls Section

    private var controlsSection: some View {
        HStack(spacing: Spacing.lg) {
            // Skip Button
            Button {
                timerManager.triggerSelectionHaptic()
                timerManager.skipToNextStep()
            } label: {
                VStack(spacing: Spacing.xs) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 20))
                    Text("Skip")
                        .font(.bakeryBody(12))
                }
                .foregroundColor(.stoneGray)
                .frame(width: 70, height: 70)
                .background(
                    Circle()
                        .fill(Color.flourWhite)
                        .shadow(color: Color.warmBrown.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            }

            // Play/Pause Button (Large)
            Button {
                timerManager.triggerSelectionHaptic()
                if timerManager.isRunning {
                    timerManager.pauseTimer()
                } else {
                    timerManager.resumeTimer()
                }
            } label: {
                Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.flourWhite)
                    .frame(width: 90, height: 90)
                    .background(
                        Circle()
                            .fill(Color.terracotta)
                            .shadow(color: Color.terracotta.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
            }

            // Reset Button
            Button {
                timerManager.triggerSelectionHaptic()
                timerManager.resetTimer()
            } label: {
                VStack(spacing: Spacing.xs) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 20))
                    Text("Reset")
                        .font(.bakeryBody(12))
                }
                .foregroundColor(.stoneGray)
                .frame(width: 70, height: 70)
                .background(
                    Circle()
                        .fill(Color.flourWhite)
                        .shadow(color: Color.warmBrown.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            }
        }
        .padding(.vertical, Spacing.md)
    }

    // MARK: - Steps List Section

    private var stepsListSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("All Steps")
                .sectionHeader()

            VStack(spacing: 0) {
                let sortedSteps = timer.steps.sorted { $0.order < $1.order }

                ForEach(Array(sortedSteps.enumerated()), id: \.element.id) { index, step in
                    TimerStepRow(
                        step: step,
                        stepNumber: index + 1,
                        isCurrent: index == timer.currentStepIndex,
                        isCompleted: step.isCompleted
                    )

                    if index < sortedSteps.count - 1 {
                        WarmDivider()
                            .padding(.leading, 48)
                    }
                }
            }
        }
        .padding(Spacing.lg)
        .warmCard()
    }
}

// MARK: - Timer Step Row

struct TimerStepRow: View {
    let step: BakeTimerStep
    let stepNumber: Int
    let isCurrent: Bool
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Step number/status indicator
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 32, height: 32)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.flourWhite)
                } else {
                    Text("\(stepNumber)")
                        .font(.bakeryMono(14))
                        .foregroundColor(isCurrent ? .flourWhite : .stoneGray)
                }
            }

            // Step info
            VStack(alignment: .leading, spacing: 2) {
                Text(step.name)
                    .font(isCurrent ? .bakeryBodyMedium(15) : .bakeryBody(15))
                    .foregroundColor(isCurrent ? .inkBrown : (isCompleted ? .stoneGray : .inkBrown))

                Text(step.formattedDuration)
                    .font(.bakeryMono(12))
                    .foregroundColor(.stoneGray)
            }

            Spacer()

            // Current indicator
            if isCurrent && !isCompleted {
                HStack(spacing: Spacing.xs) {
                    Circle()
                        .fill(Color.terracotta)
                        .frame(width: 6, height: 6)

                    Text("Now")
                        .font(.bakeryBody(12))
                        .foregroundColor(.terracotta)
                }
            }
        }
        .padding(.vertical, Spacing.sm)
        .opacity(isCompleted && !isCurrent ? 0.6 : 1.0)
    }

    private var backgroundColor: Color {
        if isCompleted {
            return .green
        } else if isCurrent {
            return .terracotta
        } else {
            return .panCrumb
        }
    }
}

// MARK: - Circular Progress View

struct CircularProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.panCrumb, lineWidth: 4)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.terracotta, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(Int(progress * 100))%")
                .font(.bakeryMono(10))
                .foregroundColor(.terracotta)
        }
    }
}

//#Preview {
//    let timer = BakeTimer(name: "Sourdough Day")
//    NavigationStack {
//        TimerDetailView(timer: timer)
//    }
//    .modelContainer(for: [BakeTimer.self, BakeTimerStep.self], inMemory: true)
//}
