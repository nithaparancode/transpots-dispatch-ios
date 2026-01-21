import Foundation
import Combine

final class OrdersViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded([Order])
        case failed(String)
    }
    
    @Published var state: ViewState = .idle
    @Published var selectedStatus: OrderStatus = .active
    
    private var currentTask: Task<Void, Never>?
    private let orderService: OrderServiceProtocol
    private let pageSize = 10
    
    init(orderService: OrderServiceProtocol) {
        self.orderService = orderService
    }
    
    func loadOrders() {
        currentTask?.cancel()
        state = .loading
        
        currentTask = Task { @MainActor in
            do {
                let response = try await orderService.fetchOrders(
                    status: selectedStatus,
                    page: 0,
                    size: pageSize
                )
                self.state = .loaded(response.orders)
            } catch {
                self.state = .failed(error.localizedDescription)
            }
        }
    }
    
    func switchStatus(to status: OrderStatus) {
        selectedStatus = status
        loadOrders()
    }
    
    deinit {
        currentTask?.cancel()
    }
}
