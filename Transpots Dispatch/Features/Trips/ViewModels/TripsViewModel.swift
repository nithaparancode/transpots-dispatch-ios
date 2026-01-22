import Foundation
import Combine

final class TripsViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded([Trip])
        case failed(String)
    }
    
    enum TripStatus: String, CaseIterable {
        case active = "ACTIVE"
        case archived = "ARCHIVED"
        
        var displayName: String {
            switch self {
            case .active: return "Active"
            case .archived: return "Archived"
            }
        }
    }
    
    @Published var state: ViewState = .idle
    @Published var selectedStatus: TripStatus = .active
    @Published var trips: [Trip] = []
    
    private var currentTask: Task<Void, Never>?
    private let tripService: TripServiceProtocol
    private let pageSize = 20
    private var currentPage = 0
    
    init(tripService: TripServiceProtocol = TripService()) {
        self.tripService = tripService
    }
    
    func loadTrips() {
        currentTask?.cancel()
        currentPage = 0
        state = .loading
        
        currentTask = Task { @MainActor in
            do {
                let response = try await tripService.fetchTrips(
                    status: selectedStatus.rawValue,
                    page: currentPage,
                    size: pageSize
                )
                self.trips = response.trips
                self.state = .loaded(response.trips)
            } catch {
                self.state = .failed(error.localizedDescription)
            }
        }
    }
    
    func changeStatus(_ status: TripStatus) {
        guard status != selectedStatus else { return }
        selectedStatus = status
        loadTrips()
    }
    
    deinit {
        currentTask?.cancel()
    }
}
