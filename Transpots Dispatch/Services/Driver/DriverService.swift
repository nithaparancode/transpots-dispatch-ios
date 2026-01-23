import Foundation
import Alamofire

protocol DriverServiceProtocol {
    func fetchDrivers(userId: String) async throws -> [Driver]
    func createDriver(request: CreateDriverRequest) async throws -> Driver
    func deleteDriver(driverId: String) async throws
}

final class DriverService: DriverServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func fetchDrivers(userId: String) async throws -> [Driver] {
        print("📡 Fetching drivers for userId: \(userId)")
        
        do {
            let endpoint = APIEndpoint.fetchDrivers(userId: userId)
            let drivers: [Driver] = try await networkManager.request(
                endpoint,
                method: .get
            )
            print("✅ Drivers fetched: \(drivers.count) drivers")
            return drivers
        } catch {
            print("❌ Drivers API error: \(error)")
            throw error
        }
    }
    
    func createDriver(request: CreateDriverRequest) async throws -> Driver {
        print("📡 Creating driver with phone: \(request.phone)")
        
        do {
            let endpoint = APIEndpoint.createDriver
            let driver: Driver = try await networkManager.request(
                endpoint,
                method: .post,
                parameters: request
            )
            print("✅ Driver created: \(driver.id)")
            return driver
        } catch {
            print("❌ Create driver error: \(error)")
            throw error
        }
    }
    
    func deleteDriver(driverId: String) async throws {
        print("🗑️ Deleting driver: \(driverId)")
        
        do {
            let endpoint = APIEndpoint.deleteDriver(driverId: driverId)
            let _: EmptyResponse = try await networkManager.request(
                endpoint,
                method: .delete
            )
            print("✅ Driver deleted successfully")
        } catch {
            print("❌ Delete driver error: \(error)")
            throw error
        }
    }
}
