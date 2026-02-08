import Foundation

/// Protocol that abstracts token storage and retrieval.
/// Conform your app's TokenManager to this protocol to inject it into the network layer.
public protocol TokenProviding: Sendable {
    var accessToken: String? { get }
    var refreshToken: String? { get }
    var userId: String? { get }
    func saveTokens(accessToken: String, refreshToken: String)
    func clearTokens()
}
