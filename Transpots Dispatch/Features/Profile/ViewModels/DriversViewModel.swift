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
    
    func createDriver(phoneNumber: String) async -> Bool {
        do {
            guard let userId = TokenManager.shared.userId else {
                state = .failed("User ID not found")
                return false
            }
            
            let request = CreateDriverRequest(
                firstName: "",
                lastName: "",
                phone: phoneNumber,
                owner: CreateDriverOwner(
                    id: userId,
                    companyAddress: "",
                    companyName: "",
                    email: "",
                    password: ""
                )
            )
            
            let newDriver = try await driverService.createDriver(request: request)
            
            await MainActor.run {
                self.drivers.append(newDriver)
                self.state = .loaded(self.drivers)
            }
            
            // Refresh the list to get the latest data
            await fetchDrivers()
            
            return true
        } catch {
            await MainActor.run {
                self.state = .failed("Failed to create driver: \(error.localizedDescription)")
            }
            return false
        }
    }
    
    func deleteDriver(_ driver: Driver) async -> Bool {
        do {
            try await driverService.deleteDriver(driverId: driver.id)
            
            await MainActor.run {
                // Remove driver from the list
                self.drivers.removeAll { $0.id == driver.id }
                self.state = .loaded(self.drivers)
            }
            
            return true
        } catch {
            await MainActor.run {
                self.state = .failed("Failed to delete driver: \(error.localizedDescription)")
            }
            return false
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
