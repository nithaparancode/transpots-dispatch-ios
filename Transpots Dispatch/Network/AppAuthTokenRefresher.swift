import Foundation
import TranspotsNetworking

/// App-specific implementation of token refresh logic.
/// Uses the app's APIEndpoint and RefreshTokenResponse model.
final class AppAuthTokenRefresher: AuthTokenRefreshing {
    
    private let tokenProvider: TokenProviding
    private let networkManager: NetworkManager
    
    init(tokenProvider: TokenProviding, networkManager: NetworkManager) {
        self.tokenProvider = tokenProvider
        self.networkManager = networkManager
    }
    
    func refreshTokens() async -> Bool {
        guard let refreshToken = tokenProvider.refreshToken else {
            print("❌ No refresh token available, logging out...")
            return false
        }
        
        print("🔄 Refreshing access token...")
        
        do {
            // Create custom headers with refresh token in Authorization header
            var headers = HTTPHeaders()
            headers.add(name: "Authorization", value: "Bearer \(refreshToken)")
            headers.add(name: "Content-Type", value: "application/json")
            
            if let userId = tokenProvider.userId {
                headers.add(name: "userId", value: userId)
            }
            
            // Send refresh token in request body as well (as per API spec)
            let parameters = ["refreshToken": refreshToken]
            
            // Use requestWithoutInterceptor to avoid recursion
            let response: RefreshTokenResponse = try await networkManager.requestWithoutInterceptor(
                APIEndpoint.refreshToken,
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers
            )
            
            tokenProvider.saveTokens(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
            )
            
            return true
        } catch {
            print("❌ Token refresh failed: \(error.localizedDescription)")
            return false
        }
    }
}
