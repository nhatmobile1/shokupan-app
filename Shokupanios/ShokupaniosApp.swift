//
//  ShokupaniosApp.swift
//  Shokupanios
//
//  Created by Nhat Tran on 1/3/26.
//

import SwiftUI
import SwiftData

@main
struct ShokupaniosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Recipe.self, Ingredient.self, RecipeTemplate.self, TemplateIngredient.self])
    }
}
