import Foundation
#if canImport(Supabase)
import Supabase
#endif

class ProfileService {
    static let shared = ProfileService()
    
    #if canImport(Supabase)
    private var supabase: SupabaseClient? {
        return SupabaseManager.shared.client
    }
    #else
    private var supabase: AnyObject? {
        return nil
    }
    #endif
    
    private init() {}
    
    func getProfile(for userId: String) async throws -> Profile? {
        #if canImport(Supabase)
        guard let supabase = supabase else {
            throw ProfileError.notImplemented
        }
        
        do {
            let response = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
            
            guard let data = response.value as? [String: Any] else {
                return nil
            }
            
            return Profile(
                id: data["id"] as? String ?? "",
                extractionCount: data["extraction_count"] as? Int ?? 0,
                subscriptionStatus: data["subscription_status"] as? String ?? "free"
            )
        } catch {
            throw error
        }
        #else
        throw ProfileError.notImplemented
        #endif
    }
    
    func createProfile(for user: User) async throws -> Profile {
        #if canImport(Supabase)
        guard let supabase = supabase else {
            throw ProfileError.notImplemented
        }
        
        do {
            let response = try await supabase
                .from("profiles")
                .insert([
                    "id": user.id,
                    "extraction_count": "0",
                    "subscription_status": "free"
                ])
                .execute()
            
            guard let data = response.value as? [[String: Any]],
                  let profileData = data.first else {
                throw ProfileError.profileNotFound
            }
            
            return Profile(
                id: profileData["id"] as? String ?? "",
                extractionCount: profileData["extraction_count"] as? Int ?? 0,
                subscriptionStatus: profileData["subscription_status"] as? String ?? "free"
            )
        } catch {
            throw error
        }
        #else
        throw ProfileError.notImplemented
        #endif
    }
    
    func incrementExtractionCount(for userId: String) async throws -> Int {
        #if canImport(Supabase)
        guard let supabase = supabase else {
            throw ProfileError.notImplemented
        }
        
        do {
            // First get current count
            let currentResponse = try await supabase
                .from("profiles")
                .select("extraction_count")
                .eq("id", value: userId)
                .single()
                .execute()

            guard let currentData = currentResponse.value as? [String: Any],
                  let currentCount = currentData["extraction_count"] as? String,
                  let count = Int(currentCount) else {
                throw ProfileError.updateFailed
            }

            let newCount = count + 1

            // Update with new count
            _ = try await supabase
                .from("profiles")
                .update(["extraction_count": "\(newCount)"])
                .eq("id", value: userId)
                .execute()

            return newCount
        } catch {
            throw error
        }
        #else
        throw ProfileError.notImplemented
        #endif
    }
}