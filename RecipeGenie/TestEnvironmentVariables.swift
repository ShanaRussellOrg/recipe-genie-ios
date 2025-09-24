import Foundation

/*
 Temporary test function to verify environment variables are set correctly.
 
 To use this:
 1. Add this function to your RecipeGenieApp.swift file
 2. Call it from the init() method
 3. Run the app and check the Xcode console for the output
 4. Remove this code after verifying everything works
*/

func testEnvironmentVariables() {
    print("\n=== Environment Variable Test ===")
    
    // Test SUPABASE_URL
    if let supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"] {
        print("✅ SUPABASE_URL found: \\(supabaseURL)")
    } else {
        print("❌ SUPABASE_URL not found")
        print("   Please add SUPABASE_URL to your environment variables")
        print("   Product → Scheme → Edit Scheme → Run → Arguments → Environment Variables")
    }
    
    // Test SUPABASE_KEY
    if let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"] {
        print("✅ SUPABASE_KEY found (length: \\(supabaseKey.count))")
        // Don't print the actual key for security
    } else {
        print("❌ SUPABASE_KEY not found")
        print("   Please add SUPABASE_KEY to your environment variables")
        print("   Product → Scheme → Edit Scheme → Run → Arguments → Environment Variables")
    }
    
    // Test GEMINI_API_KEY
    if let geminiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] {
        print("✅ GEMINI_API_KEY found (length: \\(geminiKey.count))")
        // Don't print the actual key for security
    } else {
        print("❌ GEMINI_API_KEY not found")
        print("   Please add GEMINI_API_KEY to your environment variables")
        print("   Product → Scheme → Edit Scheme → Run → Arguments → Environment Variables")
    }
    
    print("==================================\\n")
}

// Example of how to use it in RecipeGenieApp.swift:
/*
@main
struct RecipeGenieApp: App {
    init() {
        // Test environment variables
        testEnvironmentVariables()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/