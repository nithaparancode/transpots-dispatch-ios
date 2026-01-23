import Foundation
import Combine

@MainActor
final class DriversViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded([Driver])
        case failed(String)
        
        static func == (lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading):
                return true
            case (.loaded(let lhsDrivers), .loaded(let rhsDrivers)):
                return lhsDrivers.map(\.id) == rhsDrivers.map(\.id)
            case (.failed(let lhsError), .failed(let rhsError)):
                return lhsError == rhsError
            default:
                return false
            }
        }
    }
    
    // MARK: - Published Properties
    @Published var state: ViewState = .idle
    @Published var drivers: [Driver] = []
    
    // MARK: - Private Properties
    private let driverService: DriverServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(driverService: DriverServiceProtocol = DriverService()) {
        self.driverService = driverService
    }
    
    // MARK: - Public Methods
    func loadDrivers() {
        state = .loading
        
        Task {
            await fetchDrivers()
        }
    }
    
    // MARK: - Private Methods
    private func fetchDrivers() async {
        do {
            guard let userId = TokenManager.shared.userId else {
                state = .failed("User ID not found")
                return
            }
            
            let drivers = try await driverService.fetchDrivers(userId: userId)
            
            await MainActor.run {
                self.drivers = drivers
                self.state = .loaded(drivers)
            }
        } catch {
            await MainActor.run {
                self.state = .failed(error.localizedDescription)
            }
        }
    }
    
    deinit {
        cancellables.removeAll()
    }
}
