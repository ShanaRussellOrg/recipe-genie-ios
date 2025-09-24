import Foundation
#if canImport(Supabase)
import Supabase
#endif

/*
 This file contains simple tests you can run to verify your Supabase setup.
 
 To use these tests:
 1. Make sure you've set up your environment variables (SUPABASE_URL and SUPABASE_KEY)
 2. Uncomment the test functions you want to run
 3. Call them from your app's initialization or a test button
*/

class SupabaseSetupTester {
    static let shared = SupabaseSetupTester()
    
    #if canImport(Supabase)
    private var supabase: SupabaseClient?
    #else
    private var supabase: AnyObject? // Placeholder when Supabase is not available
    #endif
    
    private init() {
        setupSupabase()
    }
    
    private func setupSupabase() {
        #if canImport(Supabase)
        guard let supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"],
              let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"] else {
            print("❌ Missing Supabase environment variables")
            print("   Please set SUPABASE_URL and SUPABASE_KEY in your Xcode scheme")
            return
        }
        
        self.supabase = SupabaseClient(supabaseURL: URL(string: supabaseURL)!, supabaseKey: supabaseKey)
        print("✅ Supabase client initialized")
        print("   URL: \(supabaseURL)")
        print("   Key: " + String(repeating: "*", count: supabaseKey.count))
        #else
        print("⚠️ Supabase package not available - tests will be skipped")
        #endif
    }
    
    // Test 1: Basic connection test
    func testBasicConnection() {
        #if canImport(Supabase)
        guard let supabase = self.supabase else {
            print("❌ Supabase client not initialized")
            return
        }
        
        print("\n=== Testing Basic Connection ===")
        
        Task {
            do {
                // This will throw if the connection fails
                // Simple connection test by checking session
                _ = try await supabase.auth.session
                print("✅ Basic connection test passed")
                print("   Connection verified")
            } catch {
                print("❌ Basic connection test failed:")
                print("   Error: \(error)")
            }
        }
        #else
        print("⚠️ Supabase package not available - skipping basic connection test")
        #endif
    }
    
    // Test 2: Authentication test
    func testAuthentication() {
        #if canImport(Supabase)
        guard let supabase = self.supabase else {
            print("❌ Supabase client not initialized")
            return
        }
        
        print("\n=== Testing Authentication ===")
        
        Task {
            do {
                let session = try await supabase.auth.session
                print("✅ Authentication test passed")
                let email = session.user.email ?? "unknown"
                print("   Current user: \(email)")
            } catch {
                print("❌ Authentication test failed:")
                print("   Error: \(error)")
            }
        }
        #else
        print("⚠️ Supabase package not available - skipping authentication test")
        #endif
    }
    
    // Test 3: Database connection test
    func testDatabaseConnection() {
        #if canImport(Supabase)
        guard let supabase = self.supabase else {
            print("❌ Supabase client not initialized")
            return
        }
        
        print("\n=== Testing Database Connection ===")
        
        Task {
            do {
                // Try to query a simple table (this will fail if the table doesn't exist, which is fine)
                _ = try await supabase
                    .from("profiles")
                    .select()
                    .limit(1)
                    .execute()
                
                print("✅ Database connection test passed")
                print("   Query succeeded (table may be empty)")
            } catch let databaseError {
                // Check if this is a "relation doesn't exist" error, which is expected if tables aren't created yet
                let errorMessage = String(describing: databaseError)
                if errorMessage.contains("does not exist") {
                    print("⚠️  Database connection test: Table doesn't exist yet")
                    print("   This is expected if you haven't run the database schema yet")
                    print("   Error: \(errorMessage)")
                } else {
                    print("❌ Database connection test failed:")
                    print("   Error: \(databaseError)")
                }
            } catch {
                print("❌ Database connection test failed:")
                print("   Unexpected error: \(error)")
            }
        }
        #else
        print("⚠️ Supabase package not available - skipping database connection test")
        #endif
    }
    
    // Test 4: Full integration test
    func runAllTests() {
        print("🚀 Starting Supabase setup tests...")
        
        #if canImport(Supabase)
        // Run all tests
        testBasicConnection()
        testAuthentication()
        testDatabaseConnection()
        #else
        print("⚠️ Supabase package not available - skipping all tests")
        #endif
        
        print("\n📋 Tests completed. Check the output above for results.")
        print("   If all tests pass, your Supabase setup is ready to go!")
    }
}

// Convenience functions for quick testing
func runSupabaseTests() {
    #if canImport(Supabase)
    SupabaseSetupTester.shared.runAllTests()
    #else
    print("⚠️ Supabase package not available - skipping tests")
    #endif
}

func testSupabaseConnection() {
    #if canImport(Supabase)
    SupabaseSetupTester.shared.testBasicConnection()
    #else
    print("⚠️ Supabase package not available - skipping connection test")
    #endif
}

func testSupabaseAuth() {
    #if canImport(Supabase)
    SupabaseSetupTester.shared.testAuthentication()
    #else
    print("⚠️ Supabase package not available - skipping auth test")
    #endif
}

func testSupabaseDatabase() {
    #if canImport(Supabase)
    SupabaseSetupTester.shared.testDatabaseConnection()
    #else
    print("⚠️ Supabase package not available - skipping database test")
    #endif
}