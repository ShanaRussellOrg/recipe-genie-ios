import SwiftUI
import Foundation

/*
 This file contains diagnostic tools to help you verify your Recipe Genie setup.
 
 To use these tools:
 1. Add this file to your Xcode project
 2. Call `runDiagnostics()` from your app's initialization
 3. Check the Xcode console for diagnostic output
*/

struct DiagnosticResult {
    let name: String
    let status: DiagnosticStatus
    let message: String
}

enum DiagnosticStatus {
    case passed
    case failed
    case warning
    case info
    
    var emoji: String {
        switch self {
        case .passed: return "✅"
        case .failed: return "❌"
        case .warning: return "⚠️"
        case .info: return "ℹ️"
        }
    }
}

class RecipeGenieDiagnostics {
    static let shared = RecipeGenieDiagnostics()
    
    private init() {}
    
    func runAllDiagnostics() {
        print("\n=== Recipe Genie Setup Diagnostics ===")
        
        let results = [
            checkEnvironmentVariables(),
            checkSupabaseAvailability(),
            checkGeminiApiKey(),
            checkSupabaseCredentials()
        ]
        
        for result in results {
            print("\(result.status.emoji) \(result.name): \(result.message)")
        }
        
        print("=====================================\n")
    }
    
    private func checkEnvironmentVariables() -> DiagnosticResult {
        let supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"]
        let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"]
        let geminiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"]
        
        if supabaseURL != nil && supabaseKey != nil && geminiKey != nil {
            return DiagnosticResult(
                name: "Environment Variables",
                status: .passed,
                message: "All required environment variables found"
            )
        } else {
            var missing = [String]()
            if supabaseURL == nil { missing.append("SUPABASE_URL") }
            if supabaseKey == nil { missing.append("SUPABASE_KEY") }
            if geminiKey == nil { missing.append("GEMINI_API_KEY") }
            
            return DiagnosticResult(
                name: "Environment Variables",
                status: .failed,
                message: "Missing variables: \(missing.joined(separator: ", "))"
            )
        }
    }
    
    private func checkSupabaseAvailability() -> DiagnosticResult {
        #if canImport(Supabase)
        return DiagnosticResult(
            name: "Supabase Package",
            status: .passed,
            message: "Supabase Swift package is installed and available"
        )
        #else
        return DiagnosticResult(
            name: "Supabase Package",
            status: .failed,
            message: "Supabase Swift package is NOT installed. Please follow the instructions in HOW_TO_ADD_SUPABASE_PACKAGE.md"
        )
        #endif
    }
    
    private func checkGeminiApiKey() -> DiagnosticResult {
        guard let geminiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] else {
            return DiagnosticResult(
                name: "Gemini API Key",
                status: .failed,
                message: "GEMINI_API_KEY not found in environment variables"
            )
        }
        
        if geminiKey.count > 10 {
            return DiagnosticResult(
                name: "Gemini API Key",
                status: .passed,
                message: "API key found (length: \(geminiKey.count))"
            )
        } else {
            return DiagnosticResult(
                name: "Gemini API Key",
                status: .warning,
                message: "API key seems too short (length: \(geminiKey.count))"
            )
        }
    }
    
    private func checkSupabaseCredentials() -> DiagnosticResult {
        let supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"]
        let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"]
        
        if let url = supabaseURL, let key = supabaseKey {
            if url.hasPrefix("https://") && url.contains(".supabase.") {
                if key.count > 20 {
                    return DiagnosticResult(
                        name: "Supabase Credentials",
                        status: .passed,
                        message: "URL and key format appear correct"
                    )
                } else {
                    return DiagnosticResult(
                        name: "Supabase Credentials",
                        status: .warning,
                        message: "Key seems too short (length: \(key.count))"
                    )
                }
            } else {
                return DiagnosticResult(
                    name: "Supabase Credentials",
                    status: .warning,
                    message: "URL format may be incorrect"
                )
            }
        } else {
            return DiagnosticResult(
                name: "Supabase Credentials",
                status: .failed,
                message: "Missing SUPABASE_URL or SUPABASE_KEY"
            )
        }
    }
}

// Convenience function to run diagnostics
func runDiagnostics() {
    RecipeGenieDiagnostics.shared.runAllDiagnostics()
}

// Example of how to use in your RecipeGenieApp.swift:
/*
@main
struct RecipeGenieApp: App {
    init() {
        // Run diagnostics when app starts
        runDiagnostics()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/