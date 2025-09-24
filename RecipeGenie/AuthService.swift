import Foundation
#if canImport(Supabase)
import Supabase
#endif
import Combine

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    
    #if canImport(Supabase)
    private var supabase: SupabaseClient? {
        return SupabaseManager.shared.client
    }
    #else
    private var supabase: AnyObject? {
        return nil
    }
    #endif
    
    private init() {
        checkAuthState()
    }
    
    private func checkAuthState() {
        #if canImport(Supabase)
        Task {
            do {
                let session = try await supabase?.auth.session
                if let session = session {
                    let user = session.user
                    await MainActor.run {
                        self.user = User(id: user.id.uuidString, email: user.email ?? "")
                        self.isAuthenticated = true
                    }
                }
            } catch {
                print("No active session: \(error)")
            }
        }
        #endif
    }
    
    func signup(with credentials: AuthCredentials) async throws {
        #if canImport(Supabase)
        isLoading = true
        
        do {
            let authResponse = try await supabase?.auth.signUp(
                email: credentials.email,
                password: credentials.password
            )
            
            if let user = authResponse?.user {
                await MainActor.run {
                    self.user = User(id: user.id.uuidString, email: user.email ?? "")
                    self.isAuthenticated = true
                }
            }
        } catch {
            isLoading = false
            throw error
        }
        #else
        throw NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Supabase package not available"])
        #endif
    }
    
    func login(with credentials: AuthCredentials) async throws {
        #if canImport(Supabase)
        isLoading = true
        
        do {
            let session = try await supabase?.auth.signIn(
                email: credentials.email,
                password: credentials.password
            )
            
            if let session = session {
                let user = session.user
                await MainActor.run {
                    self.user = User(id: user.id.uuidString, email: user.email ?? "")
                    self.isAuthenticated = true
                }
            }
        } catch {
            isLoading = false
            throw error
        }
        #else
        throw NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Supabase package not available"])
        #endif
    }
    
    func logout() async throws {
        #if canImport(Supabase)
        do {
            try await supabase?.auth.signOut()
            await MainActor.run {
                self.user = nil
                self.isAuthenticated = false
            }
        } catch {
            throw error
        }
        #else
        await MainActor.run {
            self.user = nil
            self.isAuthenticated = false
        }
        #endif
    }
    
    func resendConfirmationEmail(to email: String) async throws {
        #if canImport(Supabase)
        do {
            try await supabase?.auth.resend(
                email: email,
                type: .signup
            )
        } catch {
            throw error
        }
        #else
        // Do nothing if Supabase is not available
        #endif
    }
}