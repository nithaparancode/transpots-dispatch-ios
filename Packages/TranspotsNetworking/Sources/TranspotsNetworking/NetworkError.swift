import Foundation

public enum NetworkError: LocalizedError, Sendable {
    case unauthorized
    case forbidden
    case notFound
    case serverError(Int)
    case noInternetConnection
    case decodingError
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Unauthorized. Please login again."
        case .forbidden:
            return "You don't have permission to access this resource."
        case .notFound:
            return "The requested resource was not found."
        case .serverError(let code):
            return "Server error occurred. Code: \(code)"
        case .noInternetConnection:
            return "No internet connection. Please check your network."
        case .decodingError:
            return "Failed to process server response."
        case .unknown(let message):
            return message
        }
    }
}
