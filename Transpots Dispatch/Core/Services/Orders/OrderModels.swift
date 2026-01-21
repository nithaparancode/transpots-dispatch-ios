import Foundation

struct OrdersResponse: Codable {
    let orders: [Order]
    let page: PageInfo
}

struct Order: Codable, Identifiable, Equatable {
    let orderId: Int
    let userOrderId: String
    let status: String
    let customerName: String
    let orderEvents: [OrderEvent]
    let exceptions: [String]
    
    var id: Int { orderId }
}

struct OrderEvent: Codable, Identifiable, Equatable {
    let orderEventId: Int
    let name: String
    let address: String
    let startTime: String
    let endTime: String?
    let eventType: String
    let tractorId: String?
    let isScheduled: Bool
    let status: String
    
    var id: Int { orderEventId }
}

struct PageInfo: Codable {
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let number: Int
}

enum OrderStatus: String {
    case active = "ACTIVE"
    case archived = "ARCHIVED"
}
