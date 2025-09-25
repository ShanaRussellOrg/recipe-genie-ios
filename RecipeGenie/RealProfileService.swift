import Foundation
#if canImport(Supabase)
import Supabase
#endif

class RealProfileService {
    static let shared = RealProfileService()
    
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
            print("Supabase client not initialized")
            throw ProfileError.clientNotInitialized
        }
        
        do {
            let response = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
            
            guard let data = response.value as? [String: Any] else {
                print("Failed to cast response.value to [String: Any], got: \(type(of: response.value))")
                return nil
            }
            
            // Handle extraction_count which might be stored as String or Int
            let extractionCount: Int
            if let countString = data["extraction_count"] as? String {
                extractionCount = Int(countString) ?? 0
            } else if let countInt = data["extraction_count"] as? Int {
                extractionCount = countInt
            } else {
                extractionCount = 0
            }

            return Profile(
                id: data["id"] as? String ?? "",
                extractionCount: extractionCount,
                subscriptionStatus: data["subscription_status"] as? String ?? "free"
            )
        } catch {
            print("Error getting profile: \(error)")
            throw error
        }
        #else
        throw ProfileError.clientNotInitialized
        #endif
    }
    
    func createProfile(for user: User) async throws -> Profile {
        #if canImport(Supabase)
        guard let supabase = supabase else {
            print("Supabase client not initialized")
            throw ProfileError.clientNotInitialized
        }
        
        do {
            let response = try await supabase
                .from("profiles")
                .insert([
                    "id": user.id,
                    "extraction_count": "0",
                    "subscription_status": "free"
                ])
                .select()
                .single()
                .execute()

            guard let profileData = response.value as? [String: Any] else {
                print("Failed to cast insert response.value to [String: Any], got: \(type(of: response.value))")
                throw ProfileError.profileNotFound
            }
            
            // Handle extraction_count which might be stored as String or Int
            let extractionCount: Int
            if let countString = profileData["extraction_count"] as? String {
                extractionCount = Int(countString) ?? 0
            } else if let countInt = profileData["extraction_count"] as? Int {
                extractionCount = countInt
            } else {
                extractionCount = 0
            }

            return Profile(
                id: profileData["id"] as? String ?? "",
                extractionCount: extractionCount,
                subscriptionStatus: profileData["subscription_status"] as? String ?? "free"
            )
        } catch {
            print("Error creating profile: \(error)")
            throw error
        }
        #else
        throw ProfileError.clientNotInitialized
        #endif
    }
    
    func incrementExtractionCount(for userId: String) async throws -> Int {
        #if canImport(Supabase)
        guard let supabase = supabase else {
            print("Supabase client not initialized")
            throw ProfileError.clientNotInitialized
        }
        
        do {
            // First get current count
            let currentResponse = try await supabase
                .from("profiles")
                .select("extraction_count")
                .eq("id", value: userId)
                .single()
                .execute()

            guard let currentData = currentResponse.value as? [String: Any] else {
                print("Failed to cast currentResponse.value to [String: Any], got: \(type(of: currentResponse.value))")
                throw ProfileError.updateFailed
            }

            // Handle extraction_count which might be stored as String or Int
            let count: Int
            if let countString = currentData["extraction_count"] as? String {
                count = Int(countString) ?? 0
            } else if let countInt = currentData["extraction_count"] as? Int {
                count = countInt
            } else {
                count = 0
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
            print("Error incrementing extraction count: \(error)")
            throw error
        }
        #else
        throw ProfileError.clientNotInitialized
        #endif
    }
}