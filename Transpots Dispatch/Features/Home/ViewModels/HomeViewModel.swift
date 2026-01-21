import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    enum ViewState {
        case idle
        case loading
        case loaded(DashboardSummary)
        case failed(String)
    }
    
    @Published var state: ViewState = .idle
    
    private var currentTask: Task<Void, Never>?
    private let dashboardService: DashboardServiceProtocol
    
    init(dashboardService: DashboardServiceProtocol) {
        self.dashboardService = dashboardService
    }
    
    func loadDashboard() {
        currentTask?.cancel()
        state = .loading
        
        currentTask = Task { @MainActor in
            do {
                let summary = try await dashboardService.fetchDashboardSummary()
                self.state = .loaded(summary)
            } catch {
                self.state = .failed(error.localizedDescription)
            }
        }
    }
    
    deinit {
        currentTask?.cancel()
    }
}
