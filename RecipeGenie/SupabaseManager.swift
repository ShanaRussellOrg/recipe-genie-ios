import Foundation
#if canImport(Supabase)
import Supabase
#endif

class SupabaseManager {
    static let shared = SupabaseManager()
    
    #if canImport(Supabase)
    private(set) var client: SupabaseClient?
    #else
    var client: AnyObject? { return nil }
    #endif
    
    private init() {
        initialize()
    }
    
    func initialize() {
        guard let supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"],
              let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"] else {
            print("Supabase URL or Key not found in environment variables")
            return
        }
        
        #if canImport(Supabase)
        self.client = SupabaseClient(supabaseURL: URL(string: supabaseURL)!, supabaseKey: supabaseKey)
        print("Supabase client initialized successfully")
        #else
        print("Supabase package not available - client not initialized")
        #endif
    }
}