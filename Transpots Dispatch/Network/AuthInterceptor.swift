import Foundation
import Alamofire

final class AuthInterceptor: RequestInterceptor {
    
    private let retryLimit = 3
    private var isRefreshing = false
    private var requestsToRetry: [(RetryResult) -> Void] = []
    private let lock = NSLock()
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        if let token = TokenManager.shared.accessToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let userId = TokenManager.shared.userId {
            urlRequest.setValue(userId, forHTTPHeaderField: "userId")
        }
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        // Handle both 401 (Unauthorized) and 403 (Forbidden/Access Denied) errors
        let shouldRetry = (response.statusCode == 401 || response.statusCode == 403) && request.retryCount < retryLimit
        
        guard shouldRetry else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        print("🔄 Received \(response.statusCode) error, attempting token refresh...")
        
        lock.lock()
        requestsToRetry.append(completion)
        let shouldRefresh = !isRefreshing
        if shouldRefresh {
            isRefreshing = true
        }
        lock.unlock()
        
        if shouldRefresh {
            refreshTokens()
        }
    }
    
    private func refreshTokens() {
        guard let refreshToken = TokenManager.shared.refreshToken else {
            print("❌ No refresh token available, logging out...")
            completeRefresh(success: false)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .userDidLogout, object: nil)
            }
            return
        }
        
        print("🔄 Refreshing access token...")
        
        Task {
            do {
                // Create custom headers with refresh token in Authorization header
                var headers = HTTPHeaders()
                headers.add(name: "Authorization", value: "Bearer \(refreshToken)")
                headers.add(name: "Content-Type", value: "application/json")
                
                if let userId = TokenManager.shared.userId {
                    headers.add(name: "userId", value: userId)
                }
                
                // Send refresh token in request body as well (as per API spec)
                let parameters = ["refreshToken": refreshToken]
                
                // Use requestWithoutInterceptor to avoid recursion
                let response: RefreshTokenResponse = try await NetworkManager.shared.requestWithoutInterceptor(
                    .refreshToken,
                    method: .post,
                    parameters: parameters,
                    encoding: JSONEncoding.default,
                    headers: headers
                )
                
                TokenManager.shared.saveTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
                
                print("✅ Token refresh successful, retrying failed requests...")
                completeRefresh(success: true)
            } catch {
                print("❌ Token refresh failed: \(error.localizedDescription)")
                completeRefresh(success: false)
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .userDidLogout, object: nil)
                }
            }
        }
    }
    
    private func completeRefresh(success: Bool) {
        lock.lock()
        isRefreshing = false
        let callbacks = requestsToRetry
        requestsToRetry.removeAll()
        lock.unlock()
        
        let result: RetryResult = success ? .retry : .doNotRetry
        callbacks.forEach { $0(result) }
    }
}
