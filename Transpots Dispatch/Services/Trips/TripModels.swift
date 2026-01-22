import Foundation

// MARK: - Trip Response
struct TripResponse: Codable {
    let trips: [Trip]
    let page: TripPageInfo
}

// MARK: - Trip
struct Trip: Codable, Identifiable, Hashable {
    let tripId: Int
    let userId: String
    let userTripId: String
    let status: String
    let firstDriverName: String?
    let firstDriverId: String?
    let secondDriverName: String?
    let secondDriverId: String?
    let tripTasks: [TripTask]
    
    var id: Int { tripId }
    
    var displayDriverName: String {
        if let name = firstDriverName, !name.trimmingCharacters(in: .whitespaces).isEmpty {
            return name.trimmingCharacters(in: .whitespaces)
        }
        return "No driver assigned"
    }
    
    var pickupTask: TripTask? {
        tripTasks.first(where: { $0.type == "PICKUP" })
    }
    
    var deliveryTask: TripTask? {
        tripTasks.first(where: { $0.type == "DELIVERY" })
    }
    
    var taskCount: Int {
        tripTasks.count
    }
}

// MARK: - Trip Task
struct TripTask: Codable, Identifiable, Hashable {
    let tripTaskId: Int
    let tripId: Int
    let type: String
    let status: String
    let orderEvent: TripOrderEvent?
    let tractorId: String?
    let trailerId: String?
    let name: String
    let address: String
    let startTime: String
    let estimatedTime: String?
    let sequenceId: Int
    
    var id: Int { tripTaskId }
    
    var displayType: String {
        switch type {
        case "PICKUP": return "Pickup"
        case "DELIVERY": return "Delivery"
        case "HOOK_TRACTOR": return "Hook Tractor"
        case "HOOK_TRAILER": return "Hook Trailer"
        case "DROP_TRACTOR": return "Drop Tractor"
        case "DROP_TRAILER": return "Drop Trailer"
        default: return type
        }
    }
}

// MARK: - Trip Order Event (nested in TripTask)
struct TripOrderEvent: Codable, Hashable {
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
    let status: String
}

// MARK: - Trip Page Info
struct TripPageInfo: Codable {
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let number: Int
}
