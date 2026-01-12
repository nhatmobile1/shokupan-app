import Foundation
import SwiftData

// MARK: - Timer Preset (Saved template for reuse)

@Model
class TimerPreset {
    var name: String
    var descriptionText: String
    var isBuiltIn: Bool
    var createdDate: Date
    @Relationship(deleteRule: .cascade) var steps: [TimerPresetStep]

    init(name: String, descriptionText: String = "", isBuiltIn: Bool = false) {
        self.name = name
        self.descriptionText = descriptionText
        self.isBuiltIn = isBuiltIn
        self.createdDate = Date()
        self.steps = []
    }

    /// Total duration of all steps
    var totalDuration: TimeInterval {
        steps.reduce(0) { $0 + $1.duration }
    }

    /// Creates a clone of this preset
    func clone(newName: String) -> TimerPreset {
        let cloned = TimerPreset(
            name: newName,
            descriptionText: descriptionText,
            isBuiltIn: false
        )
        for step in steps.sorted(by: { $0.order < $1.order }) {
            let clonedStep = TimerPresetStep(
                name: step.name,
                duration: step.duration,
                order: step.order
            )
            cloned.steps.append(clonedStep)
        }
        return cloned
    }
}

// MARK: - Timer Preset Step (Template step)

@Model
class TimerPresetStep {
    var name: String
    var duration: TimeInterval // in seconds
    var order: Int

    init(name: String, duration: TimeInterval, order: Int) {
        self.name = name
        self.duration = duration
        self.order = order
    }

    /// Formatted duration string (e.g., "1h 30m" or "45m")
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Active Timer Session

@Model
class BakeTimer {
    var name: String
    var createdDate: Date
    var startedAt: Date?
    var pausedAt: Date?
    var currentStepIndex: Int
    var isCompleted: Bool
    @Relationship(deleteRule: .cascade) var steps: [BakeTimerStep]

    // Optional relationship to the preset it was created from
    var presetName: String?

    init(name: String, presetName: String? = nil) {
        self.name = name
        self.createdDate = Date()
        self.startedAt = nil
        self.pausedAt = nil
        self.currentStepIndex = 0
        self.isCompleted = false
        self.steps = []
        self.presetName = presetName
    }

    /// Create a timer session from a preset
    static func fromPreset(_ preset: TimerPreset) -> BakeTimer {
        let timer = BakeTimer(name: preset.name, presetName: preset.name)

        for presetStep in preset.steps.sorted(by: { $0.order < $1.order }) {
            let step = BakeTimerStep(
                name: presetStep.name,
                duration: presetStep.duration,
                order: presetStep.order
            )
            timer.steps.append(step)
        }

        return timer
    }

    /// Total duration of all steps
    var totalDuration: TimeInterval {
        steps.reduce(0) { $0 + $1.duration }
    }

    /// Current step being timed
    var currentStep: BakeTimerStep? {
        let sortedSteps = steps.sorted { $0.order < $1.order }
        guard currentStepIndex < sortedSteps.count else { return nil }
        return sortedSteps[currentStepIndex]
    }

    /// Whether the timer is currently running
    var isRunning: Bool {
        startedAt != nil && pausedAt == nil && !isCompleted
    }

    /// Whether the timer is paused
    var isPaused: Bool {
        pausedAt != nil && !isCompleted
    }

    /// Time elapsed in current step
    var elapsedInCurrentStep: TimeInterval {
        guard let step = currentStep else { return 0 }
        return step.elapsedTime
    }

    /// Time remaining in current step
    var remainingInCurrentStep: TimeInterval {
        guard let step = currentStep else { return 0 }
        return max(0, step.duration - step.elapsedTime)
    }

    /// Overall progress (0.0 to 1.0)
    var overallProgress: Double {
        guard totalDuration > 0 else { return 0 }

        let completedDuration = steps
            .filter { $0.order < currentStepIndex }
            .reduce(0) { $0 + $1.duration }

        let currentStepProgress = currentStep?.elapsedTime ?? 0

        return (completedDuration + currentStepProgress) / totalDuration
    }
}

// MARK: - Active Timer Step

@Model
class BakeTimerStep {
    var name: String
    var duration: TimeInterval // in seconds
    var order: Int
    var startedAt: Date?
    var pausedAt: Date?
    var accumulatedTime: TimeInterval // time accumulated before pauses
    var isCompleted: Bool

    init(name: String, duration: TimeInterval, order: Int) {
        self.name = name
        self.duration = duration
        self.order = order
        self.startedAt = nil
        self.pausedAt = nil
        self.accumulatedTime = 0
        self.isCompleted = false
    }

    /// Elapsed time in this step
    var elapsedTime: TimeInterval {
        guard let started = startedAt else { return accumulatedTime }

        if let paused = pausedAt {
            // Timer is paused, return accumulated time
            return accumulatedTime
        } else if isCompleted {
            return duration
        } else {
            // Timer is running
            return accumulatedTime + Date().timeIntervalSince(started)
        }
    }

    /// Remaining time in this step
    var remainingTime: TimeInterval {
        max(0, duration - elapsedTime)
    }

    /// Progress of this step (0.0 to 1.0)
    var progress: Double {
        guard duration > 0 else { return 0 }
        return min(1.0, elapsedTime / duration)
    }

    /// Whether this step is currently running
    var isRunning: Bool {
        startedAt != nil && pausedAt == nil && !isCompleted
    }

    /// Formatted duration string
    var formattedDuration: String {
        formatTimeInterval(duration)
    }

    /// Formatted remaining time string
    var formattedRemaining: String {
        formatTimeInterval(remainingTime)
    }

    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

// MARK: - Default Timer Presets

struct DefaultTimerPresets {
    private static let currentVersion = 3  // Updated times from recipe instructions
    private static let versionKey = "builtInTimerPresetsVersion"

    static func seedPresets(in context: ModelContext) {
        let savedVersion = UserDefaults.standard.integer(forKey: versionKey)

        // If version changed, delete old built-in presets
        if savedVersion != currentVersion {
            let descriptor = FetchDescriptor<TimerPreset>(
                predicate: #Predicate { $0.isBuiltIn == true }
            )
            if let existingPresets = try? context.fetch(descriptor) {
                for preset in existingPresets {
                    context.delete(preset)
                }
            }
            try? context.save()
        }

        // Check if presets already exist
        let descriptor = FetchDescriptor<TimerPreset>(
            predicate: #Predicate { $0.isBuiltIn == true }
        )
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0

        guard existingCount == 0 else { return }

        // Basic White Bread (from King Arthur recipe)
        let basicWhite = TimerPreset(
            name: "Basic White Bread",
            descriptionText: "Simple sandwich loaf with yeast",
            isBuiltIn: true
        )
        basicWhite.steps = [
            TimerPresetStep(name: "First Rise", duration: 90 * 60, order: 0),             // 1.5 hours (1-2 hr range)
            TimerPresetStep(name: "Second Rise", duration: 60 * 60, order: 1),            // 1 hour
            TimerPresetStep(name: "Bake", duration: 32 * 60, order: 2),                   // 32 min (30-35 range)
        ]
        context.insert(basicWhite)

        // Sourdough Boule (from King Arthur recipe)
        let sourdough = TimerPreset(
            name: "Sourdough Boule",
            descriptionText: "Artisan sourdough with stretch & fold",
            isBuiltIn: true
        )
        sourdough.steps = [
            TimerPresetStep(name: "Autolyse", duration: 20 * 60, order: 0),               // 20 min
            TimerPresetStep(name: "First Rise + Fold", duration: 60 * 60, order: 1),     // 1 hour
            TimerPresetStep(name: "Second Rise + Fold", duration: 60 * 60, order: 2),    // 1 hour
            TimerPresetStep(name: "Bench Rest", duration: 20 * 60, order: 3),             // 20 min
            TimerPresetStep(name: "Final Proof", duration: 2 * 60 * 60 + 15 * 60, order: 4),  // 2.25 hours
            TimerPresetStep(name: "Bake", duration: 38 * 60, order: 5),                   // 38 min (35-40 range)
        ]
        context.insert(sourdough)

        // Shokupan (Japanese Milk Bread) - from Just One Cookbook
        let shokupan = TimerPreset(
            name: "Shokupan (Milk Bread)",
            descriptionText: "Soft Japanese milk bread",
            isBuiltIn: true
        )
        shokupan.steps = [
            TimerPresetStep(name: "First Rise", duration: 40 * 60, order: 0),             // 40 min (until tripled)
            TimerPresetStep(name: "Shape & Rest", duration: 15 * 60, order: 1),           // 15 min bench rest
            TimerPresetStep(name: "Final Proof", duration: 60 * 60, order: 2),            // 1 hour (75-85% pan height)
            TimerPresetStep(name: "Bake", duration: 28 * 60, order: 3),                   // 28 min (25-30 range)
        ]
        context.insert(shokupan)

        // Brioche (from King Arthur recipe)
        let brioche = TimerPreset(
            name: "Brioche",
            descriptionText: "Rich French butter bread",
            isBuiltIn: true
        )
        brioche.steps = [
            TimerPresetStep(name: "First Rise", duration: 60 * 60, order: 0),             // 1 hour
            TimerPresetStep(name: "Cold Rest (Fridge)", duration: 3 * 60 * 60, order: 1), // 3 hours (several hrs)
            TimerPresetStep(name: "Second Rise", duration: 2 * 60 * 60 + 45 * 60, order: 2),  // 2.75 hours (2.5-3 hr range)
            TimerPresetStep(name: "Bake", duration: 32 * 60, order: 3),                   // 32 min (30-35 range)
        ]
        context.insert(brioche)

        // Focaccia (from King Arthur recipe)
        let focaccia = TimerPreset(
            name: "Focaccia",
            descriptionText: "Italian olive oil flatbread",
            isBuiltIn: true
        )
        focaccia.steps = [
            TimerPresetStep(name: "Rest", duration: 15 * 60, order: 0),                   // 15 min
            TimerPresetStep(name: "Fold 1", duration: 15 * 60, order: 1),                 // 15 min
            TimerPresetStep(name: "Fold 2", duration: 15 * 60, order: 2),                 // 15 min
            TimerPresetStep(name: "Fold 3", duration: 15 * 60, order: 3),                 // 15 min
            TimerPresetStep(name: "Fold 4", duration: 15 * 60, order: 4),                 // 15 min
            TimerPresetStep(name: "First Rise", duration: 60 * 60, order: 5),             // 1 hour
            TimerPresetStep(name: "Second Rise (in pan)", duration: 75 * 60, order: 6),   // 1.25 hours (1-1.5 hr range)
            TimerPresetStep(name: "Bake", duration: 22 * 60, order: 7),                   // 22 min (15-18 + 5-7 crisp)
        ]
        context.insert(focaccia)

        try? context.save()

        UserDefaults.standard.set(currentVersion, forKey: versionKey)
    }
}
