import Foundation
import Alamofire

final class AuthInterceptor: RequestInterceptor {
    
    private let retryLimit = 3
    private var isRefreshing = false
    private var requestsToRetry: [(RetryResult) -> Void] = []
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        if let token = TokenManager.shared.accessToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401,
              request.retryCount < retryLimit else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        requestsToRetry.append(completion)
        
        if !isRefreshing {
            refreshTokens()
        }
    }
    
    private func refreshTokens() {
        guard let refreshToken = TokenManager.shared.refreshToken else {
            completeRefresh(success: false)
            NotificationCenter.default.post(name: .userDidLogout, object: nil)
            return
        }
        
        isRefreshing = true
        
        Task {
            do {
                let response: RefreshTokenResponse = try await NetworkManager.shared.request(
                    .refreshToken,
                    method: .post,
                    parameters: ["refreshToken": refreshToken]
                )
                
                TokenManager.shared.saveTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
                
                completeRefresh(success: true)
            } catch {
                completeRefresh(success: false)
                NotificationCenter.default.post(name: .userDidLogout, object: nil)
            }
        }
    }
    
    private func completeRefresh(success: Bool) {
        isRefreshing = false
        
        let result: RetryResult = success ? .retry : .doNotRetry
        requestsToRetry.forEach { $0(result) }
        requestsToRetry.removeAll()
    }
}
