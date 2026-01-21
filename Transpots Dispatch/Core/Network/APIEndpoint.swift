import Foundation

enum APIEndpoint {
    case refreshToken
    case dashboardSummary
    
    private var baseURL: String {
        return "https://transpots.ca/osapi/v1"
    }
    
    private var path: String {
        switch self {
        case .refreshToken:
            return "/auth/refresh"
        case .dashboardSummary:
            return "/dashboard/summary"
        }
    }
    
    var url: String {
        return baseURL + path
    }
}
