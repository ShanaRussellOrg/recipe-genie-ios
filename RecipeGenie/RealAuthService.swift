import Foundation
import Combine
#if canImport(Supabase)
import Supabase
#endif

class RealAuthService: ObservableObject {
    static let shared = RealAuthService()

    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var authError: String?
    @Published var signupCompletedSuccessfully = false
    
    #if canImport(Supabase)
    private var supabase: SupabaseClient?
    #else
    private var supabase: AnyObject?
    #endif
    
    private init() {
        setupSupabase()
        checkAuthState()
    }
    
    private func setupSupabase() {
        #if canImport(Supabase)
        guard let supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"],
              let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"] else {
            print("Supabase URL or Key not found in environment variables")
            return
        }
        
        self.supabase = SupabaseClient(supabaseURL: URL(string: supabaseURL)!, supabaseKey: supabaseKey)
        #endif
    }
    
    func checkAuthState() {
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
                await MainActor.run {
                    self.user = nil
                    self.isAuthenticated = false
                }
            }
        }
        #endif
    }
    
    func signup(with credentials: AuthCredentials) async throws {
        #if canImport(Supabase)
        isLoading = true
        authError = nil
        
        do {
            let authResponse = try await supabase?.auth.signUp(
                email: credentials.email,
                password: credentials.password,
                redirectTo: URL(string: "recipegenie://auth/callback")
            )
            
            if let user = authResponse?.user {
                await MainActor.run {
                    // Don't automatically log user in after signup
                    // Supabase requires email confirmation by default
                    self.user = nil
                    self.isAuthenticated = false
                    self.isLoading = false
                    self.signupCompletedSuccessfully = true
                }
                print("Signup successful for \(user.email ?? "user"). Please check your email to confirm your account.")
            }
        } catch let error {
            await MainActor.run {
                self.authError = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
        #else
        await MainActor.run {
            self.authError = "Supabase package not available"
            self.isLoading = false
        }
        throw NSError(domain: "RealAuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Supabase package not available"])
        #endif
    }
    
    func login(with credentials: AuthCredentials) async {
        #if canImport(Supabase)
        isLoading = true
        authError = nil
        
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
                    self.isLoading = false
                }
            }
        } catch let error {
            await MainActor.run {
                self.authError = error.localizedDescription
                self.isLoading = false
            }
        }
        #else
        await MainActor.run {
            self.authError = "Supabase package not available"
            self.isLoading = false
        }
        #endif
    }
    
    func logout() async {
        print("🚪 Logout initiated...")
        #if canImport(Supabase)
        do {
            print("🔓 Signing out from Supabase...")
            try await supabase?.auth.signOut()
            await MainActor.run {
                print("✅ Updating auth state: user set to nil, isAuthenticated = false")
                self.user = nil
                self.isAuthenticated = false
                self.authError = nil
            }
            print("✅ Logout successful!")
        } catch {
            print("❌ Logout error: \(error)")
            // Even if Supabase logout fails, clear local state
            await MainActor.run {
                self.user = nil
                self.isAuthenticated = false
                self.authError = "Logout failed: \(error.localizedDescription)"
            }
        }
        #else
        print("📱 Mock logout (no Supabase)")
        await MainActor.run {
            self.user = nil
            self.isAuthenticated = false
            self.authError = nil
        }
        #endif
    }
    
    func resendConfirmationEmail(to email: String) async {
        #if canImport(Supabase)
        do {
            try await supabase?.auth.resend(
                email: email,
                type: .signup
            )
        } catch {
            print("Failed to resend confirmation email: \(error)")
        }
        #endif
    }

    func resetSignupState() {
        signupCompletedSuccessfully = false
    }
}