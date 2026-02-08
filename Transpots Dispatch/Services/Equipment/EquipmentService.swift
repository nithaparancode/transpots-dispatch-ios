import Foundation
import TranspotsNetworking

protocol EquipmentServiceProtocol: Service {
    func fetchEquipments() async throws -> [Equipment]
}

final class EquipmentService: EquipmentServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = NetworkManagerFactory.shared) {
        self.networkManager = networkManager
    }
    
    func fetchEquipments() async throws -> [Equipment] {
        print("📡 Fetching equipments")
        
        do {
            let equipments: [Equipment] = try await networkManager.request(
                APIEndpoint.fetchEquipments,
                method: .get
            )
            print("✅ Equipments fetched: \(equipments.count) equipments")
            return equipments
        } catch {
            print("❌ Equipments API error: \(error)")
            throw error
        }
    }
}
