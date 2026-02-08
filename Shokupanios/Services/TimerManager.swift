import Foundation
import SwiftUI
import SwiftData
import UserNotifications
import Combine

@MainActor @Observable
class TimerManager {
    var activeTimer: BakeTimer?
    var displayTime: TimeInterval = 0
    var isRunning: Bool = false

    private var timer: Timer?
    private var modelContext: ModelContext?

    static let shared = TimerManager()

    private init() {}

    func configure(with context: ModelContext) {
        self.modelContext = context
        restoreActiveTimer()
    }

    // MARK: - Timer Control

    func startTimer(from preset: TimerPreset, in context: ModelContext) {
        // Stop any existing timer
        stopTimer()

        // Create new timer session from preset
        let newTimer = BakeTimer.fromPreset(preset)
        context.insert(newTimer)

        activeTimer = newTimer
        startCurrentStep()
    }

    func startTimer(_ timer: BakeTimer) {
        activeTimer = timer
        startCurrentStep()
    }

    private func startCurrentStep() {
        guard let timer = activeTimer,
              let step = timer.currentStep else {
            completeTimer()
            return
        }

        // Mark timer and step as started
        let now = Date()
        if timer.startedAt == nil {
            timer.startedAt = now
        }
        step.startedAt = now
        step.pausedAt = nil

        isRunning = true
        scheduleNotification(for: step, in: timer)
        startDisplayTimer()
    }

    func pauseTimer() {
        guard let timer = activeTimer,
              let step = timer.currentStep else { return }

        let now = Date()
        step.pausedAt = now
        timer.pausedAt = now

        // Save accumulated time
        if let started = step.startedAt {
            step.accumulatedTime += now.timeIntervalSince(started)
        }

        isRunning = false
        cancelNotifications()
        stopDisplayTimer()
    }

    func resumeTimer() {
        guard let timer = activeTimer,
              let step = timer.currentStep else { return }

        let now = Date()
        step.startedAt = now
        step.pausedAt = nil
        timer.pausedAt = nil

        isRunning = true
        scheduleNotification(for: step, in: timer)
        startDisplayTimer()
    }

    func skipToNextStep() {
        guard let timer = activeTimer,
              let currentStep = timer.currentStep else { return }

        // Mark current step as completed
        currentStep.isCompleted = true
        currentStep.pausedAt = nil

        // Move to next step
        timer.currentStepIndex += 1

        cancelNotifications()

        // Check if there are more steps
        if timer.currentStepIndex < timer.steps.count {
            startCurrentStep()
        } else {
            completeTimer()
        }

        triggerHaptic(.success)
    }

    func resetTimer() {
        guard let timer = activeTimer else { return }

        // Reset all steps
        for step in timer.steps {
            step.startedAt = nil
            step.pausedAt = nil
            step.accumulatedTime = 0
            step.isCompleted = false
        }

        // Reset timer
        timer.currentStepIndex = 0
        timer.startedAt = nil
        timer.pausedAt = nil
        timer.isCompleted = false

        isRunning = false
        displayTime = timer.currentStep?.duration ?? 0
        cancelNotifications()
        stopDisplayTimer()
    }

    func stopTimer() {
        cancelNotifications()
        stopDisplayTimer()
        activeTimer = nil
        isRunning = false
        displayTime = 0
    }

    private func completeTimer() {
        guard let timer = activeTimer else { return }

        timer.isCompleted = true
        isRunning = false
        stopDisplayTimer()
        triggerHaptic(.success)

        // Send completion notification
        sendCompletionNotification(for: timer)
    }

    // MARK: - Display Timer

    private func startDisplayTimer() {
        stopDisplayTimer()
        updateDisplayTime()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateDisplayTime()
            }
        }
    }

    private func stopDisplayTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateDisplayTime() {
        guard let timer = activeTimer,
              let step = timer.currentStep else {
            displayTime = 0
            return
        }

        displayTime = step.remainingTime

        // Check if step completed
        if step.remainingTime <= 0 && !step.isCompleted {
            skipToNextStep()
        }
    }

    // MARK: - State Persistence

    private func restoreActiveTimer() {
        guard let context = modelContext else { return }

        // Find any active (non-completed) timer
        let descriptor = FetchDescriptor<BakeTimer>(
            predicate: #Predicate { $0.isCompleted == false }
        )

        if let timers = try? context.fetch(descriptor),
           let activeTimer = timers.first {
            self.activeTimer = activeTimer

            if activeTimer.isRunning {
                startDisplayTimer()
                isRunning = true
            } else {
                displayTime = activeTimer.currentStep?.remainingTime ?? 0
            }
        }
    }

    // MARK: - Notifications

    static let notificationCategoryID = "TIMER_STEP_COMPLETE"
    static let pauseActionID = "PAUSE_TIMER"
    static let skipActionID = "SKIP_STEP"

    func requestNotificationPermission() {
        // Register notification actions
        let pauseAction = UNNotificationAction(
            identifier: Self.pauseActionID,
            title: "Pause",
            options: []
        )
        let skipAction = UNNotificationAction(
            identifier: Self.skipActionID,
            title: "Next Step",
            options: [.foreground]
        )
        let category = UNNotificationCategory(
            identifier: Self.notificationCategoryID,
            actions: [pauseAction, skipAction],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    func handleNotificationAction(_ actionIdentifier: String) {
        switch actionIdentifier {
        case Self.pauseActionID:
            pauseTimer()
        case Self.skipActionID:
            skipToNextStep()
        default:
            break
        }
    }

    private func scheduleNotification(for step: BakeTimerStep, in timer: BakeTimer) {
        let content = UNMutableNotificationContent()
        content.title = "Timer Complete"
        content.body = "\(step.name) is done!"
        content.sound = .default
        content.categoryIdentifier = Self.notificationCategoryID

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, step.remainingTime),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "timer-\(step.order)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    private func sendCompletionNotification(for timer: BakeTimer) {
        let content = UNMutableNotificationContent()
        content.title = "All Done! 🍞"
        content.body = "\(timer.name) timer complete"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "timer-complete",
            content: content,
            trigger: nil // Deliver immediately
        )

        UNUserNotificationCenter.current().add(request)
    }

    private func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Haptics

    private func triggerHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func triggerSelectionHaptic() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - Time Formatting Helpers

extension TimeInterval {
    var formatted: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        let seconds = Int(self) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    var shortFormatted: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60

        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}
