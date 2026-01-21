import Foundation

enum APIEndpoint {
    case login
    case register
    case forgotPassword(email: String)
    case refreshToken
    case getUserByEmail(email: String)
    case dashboardSummary
    
    private var baseURL: String {
        switch self {
        case .login, .register, .forgotPassword, .getUserByEmail:
            return "https://transpots.ca/oapi/v1"
        default:
            return "https://transpots.ca/osapi/v1"
        }
    }
    
    private var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .register:
            return "/auth/register"
        case .forgotPassword(let email):
            return "/auth/forgot-password/\(email)"
        case .refreshToken:
            return "/auth/refresh"
        case .getUserByEmail(let email):
            return "/users/email/\(email)"
        case .dashboardSummary:
            return "/dashboard/summary"
        }
    }
    
    var url: String {
        return baseURL + path
    }
}
