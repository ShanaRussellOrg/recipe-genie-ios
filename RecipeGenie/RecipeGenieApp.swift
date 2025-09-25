import SwiftUI

@main
struct RecipeGenieApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleDeepLink(url: url)
                }
        }
    }

    private func handleDeepLink(url: URL) {
        print("📱 Received deep link: \(url)")

        // Check if this is an auth callback
        if url.scheme == "recipegenie" && url.host == "auth" {
            handleAuthCallback(url: url)
        }
    }

    private func handleAuthCallback(url: URL) {
        print("🔐 Handling auth callback: \(url)")

        // Extract query parameters
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            print("❌ Could not parse URL components")
            return
        }

        // Look for access token or error
        var accessToken: String?
        var refreshToken: String?
        var errorMessage: String?

        for item in queryItems {
            switch item.name {
            case "access_token":
                accessToken = item.value
            case "refresh_token":
                refreshToken = item.value
            case "error", "error_description":
                errorMessage = item.value
            default:
                break
            }
        }

        if let error = errorMessage {
            print("❌ Auth error: \(error)")
            // Handle authentication error
            return
        }

        if let accessToken = accessToken {
            print("✅ Auth success! Access token received")
            // You could call RealAuthService.shared to update the session
            print("TODO: Update RealAuthService with confirmed session")
        } else {
            print("❌ No access token found in callback")
        }
    }
}