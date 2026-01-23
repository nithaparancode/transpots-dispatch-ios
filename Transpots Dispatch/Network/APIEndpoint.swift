import Foundation

enum APIEndpoint {
    case login
    case register
    case forgotPassword(email: String)
    case refreshToken
    case getUserByEmail(email: String)
    case dashboardSummary
    case fetchOrders(status: String, page: Int, size: Int)
    case getOrderDetail(orderId: Int)
    case updateOrder(orderId: Int)
    case fetchTrips(status: String, page: Int, size: Int, sortBy: String)
    case fetchEquipments
    case fetchDrivers(userId: String)
    case createDriver
    case deleteDriver(driverId: String)
    case createTrip
    
    private var baseURL: String {
        switch self {
        case .login, .register, .forgotPassword, .getUserByEmail, .refreshToken, .fetchDrivers, .createDriver, .deleteDriver:
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
        case .fetchOrders(let status, let page, let size):
            return "/dispatch?status=\(status)&page=\(page)&size=\(size)"
        case .getOrderDetail(let orderId), .updateOrder(let orderId):
            return "/orders/\(orderId)"
        case .fetchTrips(let status, let page, let size, let sortBy):
            return "/trips?size=\(size)&page=\(page)&sortBy=\(sortBy)&status=\(status)"
        case .fetchEquipments:
            return "/equipments"
        case .fetchDrivers(let userId):
            return "/drivers?userId=\(userId)"
        case .createDriver:
            return "/drivers"
        case .deleteDriver(let driverId):
            return "/driver/\(driverId)"
        case .createTrip:
            return "/trips"
        }
    }
    
    var url: String {
        return baseURL + path
    }
}
