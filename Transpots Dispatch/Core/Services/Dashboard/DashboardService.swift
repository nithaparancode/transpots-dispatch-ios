import Foundation

protocol DashboardServiceProtocol: Service {
    func fetchDashboardSummary() async throws -> DashboardSummary
}

final class DashboardService: DashboardServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func fetchDashboardSummary() async throws -> DashboardSummary {
        // For now, return mock data
        // When ready to use real API, uncomment the line below and remove mock data
        
        // Real API call:
        // return try await networkManager.request(.dashboardSummary, method: .get)
        
        // Mock data with delay to simulate network call
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
        
        return DashboardSummary(
            activeOrders: 1,
            activeTrips: 1,
            pendingInvoices: 0,
            equipmentAvailable: 2,
            todayOrders: [
                TodayOrder(
                    userOrderId: "ORDR-0001",
                    status: "ASSIGNED",
                    orderEventPairs: [
                        OrderEventPair(
                            pickupPlace: "Dexterra Millcreek",
                            deliveryPlace: "OLG Corporate Office",
                            pickupDate: "2025-08-27T00:00:00"
                        )
                    ]
                )
            ],
            todayTrips: [
                TodayTrip(
                    userTripId: "TRIP-0001",
                    status: "ACTIVE",
                    userOrderId: "ORDR-0001",
                    firstDriverName: "Nithaparan  Francis "
                )
            ],
            recentActivity: [
                "Trip TRIP-0001 created 2 min ago",
                "Order ORDR-0001 created 8 min ago"
            ]
        )
    }
}
