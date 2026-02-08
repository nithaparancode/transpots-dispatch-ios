import Foundation
import Alamofire

public final class NetworkManager: Sendable {
    
    private let session: Session
    private let sessionWithoutInterceptor: Session
    
    /// Creates a NetworkManager with the given interceptor for authenticated requests.
    /// - Parameter interceptor: The auth interceptor that handles token injection and refresh.
    public init(interceptor: AuthInterceptor) {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        
        self.session = Session(
            configuration: configuration,
            interceptor: interceptor
        )
        
        // Separate session without interceptor for refresh token calls
        self.sessionWithoutInterceptor = Session(configuration: configuration)
    }
    
    // MARK: - Request with Dictionary Parameters (Decodable response)
    
    public func request<T: Decodable>(
        _ endpoint: some EndpointProviding,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        headers: HTTPHeaders? = nil
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            let request = session.request(
                endpoint.url,
                method: method,
                parameters: parameters,
                encoding: encoding,
                headers: headers
            )
            
            request
                .cURLDescription { description in
                    print("🔵 cURL Request:\n\(description)")
                }
                .validate()
                .responseDecodable(of: T.self) { response in
                    if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                        print("🔵 Response Body: \(responseString)")
                    }
                    if let httpResponse = response.response {
                        print("🔵 Status Code: \(httpResponse.statusCode)")
                        print("🔵 Response Headers: \(httpResponse.allHeaderFields)")
                    }
                    
                    switch response.result {
                    case .success(let value):
                        continuation.resume(returning: value)
                    case .failure(let error):
                        continuation.resume(throwing: self.handleError(error, response: response.response))
                    }
                }
        }
    }
    
    // MARK: - Request with Encodable Parameters (Decodable response)
    
    public func request<T: Decodable, E: Encodable>(
        _ endpoint: some EndpointProviding,
        method: HTTPMethod = .get,
        parameters: E? = nil,
        headers: HTTPHeaders? = nil
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            let request = session.request(
                endpoint.url,
                method: method,
                parameters: parameters,
                encoder: JSONParameterEncoder.default,
                headers: headers
            )
            
            // Debug logging
            print("🌐 API Request: \(method.rawValue) \(endpoint.url)")
            if let parameters = parameters {
                if let jsonData = try? JSONEncoder().encode(parameters),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("📦 Request Body: \(jsonString)")
                }
            }
            request.cURLDescription { description in
                print("🔧 cURL: \(description)")
            }
            
            request
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    print("✅ Response received for \(endpoint.url)")
                    if let data = response.data,
                       let jsonString = String(data: data, encoding: .utf8) {
                        print("📥 Response Body: \(jsonString)")
                    }
                    continuation.resume(returning: value)
                case .failure(let error):
                    print("❌ Request failed for \(endpoint.url): \(error)")
                    continuation.resume(throwing: self.handleError(error, response: response.response))
                }
            }
        }
    }
    
    // MARK: - Request with no response body
    
    public func request(
        _ endpoint: some EndpointProviding,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        headers: HTTPHeaders? = nil
    ) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            session.request(
                endpoint.url,
                method: method,
                parameters: parameters,
                encoding: encoding,
                headers: headers
            )
            .validate()
            .response { response in
                if let error = response.error {
                    continuation.resume(throwing: self.handleError(error, response: response.response))
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    // MARK: - Request without interceptor (for refresh token calls)
    
    public func requestWithoutInterceptor<T: Decodable>(
        _ endpoint: some EndpointProviding,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        headers: HTTPHeaders? = nil
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            let request = sessionWithoutInterceptor.request(
                endpoint.url,
                method: method,
                parameters: parameters,
                encoding: encoding,
                headers: headers
            )
            
            request
                .cURLDescription { description in
                    print("🔵 cURL Request (No Interceptor):\n\(description)")
                }
                .validate()
                .responseDecodable(of: T.self) { response in
                    if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                        print("🔵 Response Body: \(responseString)")
                    }
                    if let httpResponse = response.response {
                        print("🔵 Status Code: \(httpResponse.statusCode)")
                    }
                    
                    switch response.result {
                    case .success(let value):
                        continuation.resume(returning: value)
                    case .failure(let error):
                        continuation.resume(throwing: self.handleError(error, response: response.response))
                    }
                }
        }
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ error: AFError, response: HTTPURLResponse?) -> NetworkError {
        if let statusCode = response?.statusCode {
            switch statusCode {
            case 401:
                return .unauthorized
            case 403:
                return .forbidden
            case 404:
                return .notFound
            case 500...599:
                return .serverError(statusCode)
            default:
                break
            }
        }
        
        if error.isSessionTaskError {
            return .noInternetConnection
        }
        
        return .unknown(error.localizedDescription)
    }
}
