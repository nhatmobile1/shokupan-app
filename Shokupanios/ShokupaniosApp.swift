//
//  ShokupaniosApp.swift
//  Shokupanios
//
//  Created by Nhat Tran on 1/3/26.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct ShokupaniosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Recipe.self,
            Ingredient.self,
            RecipeTemplate.self,
            TemplateIngredient.self,
            TimerPreset.self,
            TimerPresetStep.self,
            BakeTimer.self,
            BakeTimerStep.self
        ])
    }
}

// MARK: - App Delegate for Notification Handling

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }

    // Handle notification actions
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let actionIdentifier = response.actionIdentifier

        await MainActor.run {
            TimerManager.shared.handleNotificationAction(actionIdentifier)
        }
    }
}
