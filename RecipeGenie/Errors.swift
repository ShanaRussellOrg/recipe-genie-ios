import Foundation

enum ProfileError: Error, LocalizedError {
    case notImplemented
    case profileNotFound
    case updateFailed
    case clientNotInitialized
    
    var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "Profile service not fully implemented yet"
        case .profileNotFound:
            return "Profile not found"
        case .updateFailed:
            return "Failed to update profile"
        case .clientNotInitialized:
            return "Client not properly initialized"
        }
    }
}