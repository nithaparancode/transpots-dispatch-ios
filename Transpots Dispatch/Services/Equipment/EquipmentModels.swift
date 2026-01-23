import Foundation

struct Equipment: Codable, Identifiable, Equatable {
    let equipmentId: Int
    let unitNumber: String
    let equipmentType: String
    let address: String
    
    var id: Int { equipmentId }
    
    var displayType: String {
        switch equipmentType {
        case "TRACTOR": return "Tractor"
        case "TRAILER": return "Trailer"
        default: return equipmentType
        }
    }
}

enum EquipmentType: String {
    case tractor = "TRACTOR"
    case trailer = "TRAILER"
}
