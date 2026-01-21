import Foundation
import Combine

final class OrdersViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var currentTask: Task<Void, Never>?
    
    init() {}
    
    func loadOrders() {
        currentTask?.cancel()
        isLoading = true
        
        currentTask = Task { @MainActor in
            isLoading = false
        }
    }
    
    deinit {
        currentTask?.cancel()
    }
}
