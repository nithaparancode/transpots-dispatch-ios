import Foundation
import Combine

final class ProfileViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var currentTask: Task<Void, Never>?
    
    init() {}
    
    func loadProfile() {
        currentTask?.cancel()
        isLoading = true
        
        currentTask = Task { @MainActor in
            isLoading = false
        }
    }
    
    func logout() {
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
    }
    
    deinit {
        currentTask?.cancel()
    }
}
