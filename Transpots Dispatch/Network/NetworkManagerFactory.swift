import Foundation
import TranspotsNetworking

/// Factory that creates and holds the shared NetworkManager instance configured for this app.
enum NetworkManagerFactory {
    
    /// The shared NetworkManager instance, configured with the app's token provider and auth refresh logic.
    static let shared: NetworkManager = {
        let tokenProvider = TokenManager.shared
        
        // Create a temporary NetworkManager first (needed by AppAuthTokenRefresher)
        // We use a two-phase setup: interceptor needs refresher, refresher needs manager
        let interceptor = AuthInterceptor(
            tokenProvider: tokenProvider,
            tokenRefresher: DeferredAuthTokenRefresher(),
            onAuthFailure: {
                Task { @MainActor in
                    NotificationCenter.default.post(name: .userDidLogout, object: nil)
                }
            }
        )
        
        let manager = NetworkManager(interceptor: interceptor)
        
        // Now wire up the real refresher with the manager
        let refresher = AppAuthTokenRefresher(
            tokenProvider: tokenProvider,
            networkManager: manager
        )
        DeferredAuthTokenRefresher.resolvedRefresher = refresher
        
        return manager
    }()
}

/// A deferred refresher that delegates to the real refresher once it's been resolved.
/// This breaks the circular dependency: NetworkManager -> AuthInterceptor -> AppAuthTokenRefresher -> NetworkManager
final class DeferredAuthTokenRefresher: AuthTokenRefreshing {
    nonisolated(unsafe) static var resolvedRefresher: AuthTokenRefreshing?
    
    func refreshTokens() async -> Bool {
        guard let refresher = Self.resolvedRefresher else {
            print("❌ Auth token refresher not yet configured")
            return false
        }
        return await refresher.refreshTokens()
    }
}
