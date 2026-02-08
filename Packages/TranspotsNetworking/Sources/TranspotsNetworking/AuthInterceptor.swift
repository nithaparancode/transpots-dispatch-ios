import Foundation
import Alamofire

public final class AuthInterceptor: RequestInterceptor, @unchecked Sendable {
    
    private let retryLimit = 3
    private var isRefreshing = false
    private var requestsToRetry: [(RetryResult) -> Void] = []
    private let lock = NSLock()
    
    private let tokenProvider: TokenProviding
    private let tokenRefresher: AuthTokenRefreshing
    private let onAuthFailure: @Sendable () -> Void
    
    /// - Parameters:
    ///   - tokenProvider: Provides access/refresh tokens and userId for request headers.
    ///   - tokenRefresher: Handles the token refresh logic (app-specific endpoint/model).
    ///   - onAuthFailure: Called when token refresh fails and the user should be logged out.
    public init(
        tokenProvider: TokenProviding,
        tokenRefresher: AuthTokenRefreshing,
        onAuthFailure: @escaping @Sendable () -> Void
    ) {
        self.tokenProvider = tokenProvider
        self.tokenRefresher = tokenRefresher
        self.onAuthFailure = onAuthFailure
    }
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        if let token = tokenProvider.accessToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let userId = tokenProvider.userId {
            urlRequest.setValue(userId, forHTTPHeaderField: "userId")
        }
        
        completion(.success(urlRequest))
    }
    
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
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
        Task {
            let success = await tokenRefresher.refreshTokens()
            
            if success {
                print("✅ Token refresh successful, retrying failed requests...")
                completeRefresh(success: true)
            } else {
                print("❌ Token refresh failed")
                completeRefresh(success: false)
                onAuthFailure()
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
