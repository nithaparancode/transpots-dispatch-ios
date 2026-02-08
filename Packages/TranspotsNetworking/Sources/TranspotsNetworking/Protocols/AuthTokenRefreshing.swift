import Foundation

/// Protocol that handles token refresh logic.
/// The app implements this to define how tokens are refreshed (endpoint, response model, etc.).
public protocol AuthTokenRefreshing: Sendable {
    /// Attempts to refresh the access token. Returns `true` on success, `false` on failure.
    func refreshTokens() async -> Bool
}
