import Foundation

struct DashboardSummary: Codable {
    let activeOrders: Int
    let activeTrips: Int
    let pendingInvoices: Int
    let equipmentAvailable: Int
    let todayOrders: [TodayOrder]
    let todayTrips: [TodayTrip]
    let recentActivity: [String]
}

struct TodayOrder: Codable, Identifiable {
    let userOrderId: String
    let status: String
    let orderEventPairs: [OrderEventPair]
    
    var id: String { userOrderId }
}

struct OrderEventPair: Codable {
    let pickupPlace: String
    let deliveryPlace: String
    let pickupDate: String
}

struct TodayTrip: Codable, Identifiable {
    let userTripId: String
    let status: String
    let userOrderId: String?
    let firstDriverName: String
    
    var id: String { userTripId }
}
