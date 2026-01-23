import Foundation
import Alamofire

protocol DriverServiceProtocol: Service {
    func fetchDrivers(userId: String) async throws -> [Driver]
}

final class DriverService: DriverServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func fetchDrivers(userId: String) async throws -> [Driver] {
        print("📡 Fetching drivers for userId: \(userId)")
        
        do {
            let drivers: [Driver] = try await networkManager.request(
                .fetchDrivers(userId: userId),
                method: .get
            )
            print("✅ Drivers fetched: \(drivers.count) drivers")
            return drivers
        } catch {
            print("❌ Drivers API error: \(error)")
            throw error
        }
    }
}
