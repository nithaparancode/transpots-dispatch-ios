import Foundation

struct OrdersResponse: Codable {
    let orders: [Order]
    let page: PageInfo
}

struct Order: Codable, Identifiable, Equatable {
    let orderId: Int
    let userOrderId: String
    let status: String
    let loadNumber: String?
    let companyId: String?
    let customerId: String?
    let customerName: String
    let notificationEmail: String?
    let billingEmail: String?
    let baseRate: Double?
    let detentionCharges: Double?
    let layoverCharges: Double?
    let fuelSurcharge: Double?
    let otherCharges: Double?
    let notes: String?
    let accountPayableEmail: String?
    let currency: String?
    let orderEvents: [OrderEvent]
    let exceptions: [String]?
    
    var id: Int { orderId }
    
    var totalRate: Double {
        let base = baseRate ?? 0
        let detention = detentionCharges ?? 0
        let layover = layoverCharges ?? 0
        let fuel = fuelSurcharge ?? 0
        let other = otherCharges ?? 0
        return base + detention + layover + fuel + other
    }
}

struct OrderEvent: Codable, Identifiable, Equatable {
    let orderEventId: Int
    let name: String
    let address: String
    let startTime: String
    let endTime: String?
    let eventType: String
    let loadType: String?
    let loadCount: Int?
    let temperatureValue: Double?
    let temperatureUnit: String?
    let hazmat: String?
    let weightValue: Double?
    let weightUnit: String?
    let pickupNumber: String?
    let notes: String?
    let tractorId: String?
    let isScheduled: Bool?
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
