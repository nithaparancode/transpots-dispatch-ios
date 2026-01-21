import Foundation
import Alamofire

final class NetworkManager {
    static let shared = NetworkManager()
    
    private let session: Session
    private let interceptor: AuthInterceptor
    
    private init() {
        self.interceptor = AuthInterceptor()
        
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        
        self.session = Session(
            configuration: configuration,
            interceptor: interceptor
        )
    }
    
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        headers: HTTPHeaders? = nil
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            session.request(
                endpoint.url,
                method: method,
                parameters: parameters,
                encoding: encoding,
                headers: headers
            )
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: self.handleError(error, response: response.response))
                }
            }
        }
    }
    
    func request(
        _ endpoint: APIEndpoint,
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
