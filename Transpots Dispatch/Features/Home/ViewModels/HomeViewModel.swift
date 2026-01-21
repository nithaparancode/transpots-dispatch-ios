import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var currentTask: Task<Void, Never>?
    
    init() {}
    
    func loadData() {
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
