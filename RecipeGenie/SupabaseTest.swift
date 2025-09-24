import Foundation
#if canImport(Supabase)
import Supabase
#endif

class SupabaseTest {
    static func testConnection() {
        #if canImport(Supabase)
        guard let supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"],
              let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"] else {
            print("❌ Supabase URL or Key not found in environment variables")
            return
        }
        
        print("✅ Supabase URL: \(supabaseURL)")
        print("✅ Supabase Key found: \(supabaseKey.prefix(10))...")
        
        let supabase = SupabaseClient(supabaseURL: URL(string: supabaseURL)!, supabaseKey: supabaseKey)
        
        print("✅ Supabase client created successfully")
        print("ℹ️  Testing connection...")
        
        Task {
            do {
                // Try to get the current session
                let session = try await supabase.auth.session
                print("✅ Connection test successful")
                print("ℹ️  Current session exists for user: \(session.user.email ?? "unknown")")
            } catch {
                print("❌ Connection test failed: \(error)")
            }
        }
        #else
        print("⚠️ Supabase package not available - cannot run connection test")
        #endif
    }
}