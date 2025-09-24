import SwiftUI

// @main  // Commented out to avoid conflict with main RecipeGenieApp
struct CleanRecipeGenieApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// ContentView moved to separate file to avoid conflicts
// See RecipeGenie/ContentView.swift for the main ContentView