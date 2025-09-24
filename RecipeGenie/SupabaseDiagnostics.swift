import Foundation

/*
 This file helps diagnose Supabase package installation issues
 */

class SupabaseDiagnostics {
    static func checkSupabaseInstallation() {
        print("\n=== Supabase Installation Diagnostics ===")
        
        // Check environment variables
        let supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"]
        let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"]
        let geminiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"]
        
        if let url = supabaseURL {
            print("✅ SUPABASE_URL found: \(url)")
        } else {
            print("❌ SUPABASE_URL not found in environment variables")
        }
        
        if let key = supabaseKey {
            print("✅ SUPABASE_KEY found (length: \(key.count))")
        } else {
            print("❌ SUPABASE_KEY not found in environment variables")
        }
        
        if let key = geminiKey {
            print("✅ GEMINI_API_KEY found (length: \(key.count))")
        } else {
            print("❌ GEMINI_API_KEY not found in environment variables")
        }
        
        // Check if Supabase package is available
        #if canImport(Supabase)
        print("✅ Supabase Swift package is installed and available")
        #else
        print("❌ Supabase Swift package is NOT installed")
        print("   Please add the Supabase package to your project:")
        print("   1. File → Add Package Dependencies to Project...")
        print("   2. Enter URL: https://github.com/supabase/supabase-swift")
        print("   3. Add the package to your project")
        #endif
        
        print("========================================\n")
    }
}