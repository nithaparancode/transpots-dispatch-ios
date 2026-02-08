import Foundation
import TranspotsNetworking

protocol DashboardServiceProtocol: Service {
    func fetchDashboardSummary() async throws -> DashboardSummary
}

final class DashboardService: DashboardServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = NetworkManagerFactory.shared) {
        self.networkManager = networkManager
    }
    
    func fetchDashboardSummary() async throws -> DashboardSummary {
        print("📡 Fetching dashboard from API: \(APIEndpoint.dashboardSummary.url)")
        
        do {
            let summary: DashboardSummary = try await networkManager.request(APIEndpoint.dashboardSummary, method: .get)
            print("✅ Dashboard API success")
            return summary
        } catch {
            print("❌ Dashboard API error: \(error)")
            throw error
        }
    }
}
