import Foundation
import Combine

final class TripDetailViewModel: ObservableObject {
    @Published var trip: Trip
    
    init(trip: Trip) {
        self.trip = trip
    }
    
    var sortedTasks: [TripTask] {
        trip.tripTasks.sorted { $0.sequenceId < $1.sequenceId }
    }
    
    var pickupTasks: [TripTask] {
        sortedTasks.filter { $0.type == "PICKUP" }
    }
    
    var deliveryTasks: [TripTask] {
        sortedTasks.filter { $0.type == "DELIVERY" }
    }
    
    var hookTasks: [TripTask] {
        sortedTasks.filter { $0.type == "HOOK_TRACTOR" || $0.type == "HOOK_TRAILER" }
    }
    
    var dropTasks: [TripTask] {
        sortedTasks.filter { $0.type == "DROP_TRACTOR" || $0.type == "DROP_TRAILER" }
    }
    
    func formatDate(_ dateString: String) -> String? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = isoFormatter.date(from: dateString) else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
