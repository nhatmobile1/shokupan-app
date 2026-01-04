//
//  ContentView.swift
//  Shokupanios
//
//  Created by Nhat Tran on 1/3/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("appTheme") private var appTheme = AppTheme.system.rawValue

    init() {
        // Configure tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        // Use warm cream background
        appearance.backgroundColor = UIColor(Color.flourWhite)

        // Shadow line at top
        appearance.shadowColor = UIColor(Color.panCrumb)

        // Configure item appearance
        let itemAppearance = UITabBarItemAppearance()

        // Normal state
        itemAppearance.normal.iconColor = UIColor(Color.stoneGray)
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.stoneGray),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]

        // Selected state
        itemAppearance.selected.iconColor = UIColor(Color.terracotta)
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.terracotta),
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            RecipeListView()
                .tabItem {
                    Label("Recipes", systemImage: "book.closed")
                }

            TemplateListView()
                .tabItem {
                    Label("Templates", systemImage: "doc.text")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .preferredColorScheme(AppTheme(rawValue: appTheme)?.colorScheme)
        .onAppear {
            DefaultTemplates.seedTemplates(in: modelContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Recipe.self, Ingredient.self, RecipeTemplate.self, TemplateIngredient.self], inMemory: true)
}
