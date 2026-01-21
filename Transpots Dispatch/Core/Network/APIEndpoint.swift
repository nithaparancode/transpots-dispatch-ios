import Foundation

enum APIEndpoint {
    case refreshToken
    
    private var baseURL: String {
        return "https://api.transpots.com"
    }
    
    private var path: String {
        switch self {
        case .refreshToken:
            return "/auth/refresh"
        }
    }
    
    var url: String {
        return baseURL + path
    }
}
