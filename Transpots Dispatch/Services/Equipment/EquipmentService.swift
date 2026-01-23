import Foundation
import Alamofire

protocol EquipmentServiceProtocol: Service {
    func fetchEquipments() async throws -> [Equipment]
}

final class EquipmentService: EquipmentServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func fetchEquipments() async throws -> [Equipment] {
        print("📡 Fetching equipments")
        
        do {
            let equipments: [Equipment] = try await networkManager.request(
                .fetchEquipments,
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
