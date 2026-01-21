import Foundation
import Combine

final class ForgotPasswordViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle
        case loading
        case success(String)
        case failed(String)
    }
    
    @Published var state: ViewState = .idle
    @Published var email: String = ""
    
    private var currentTask: Task<Void, Never>?
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func sendResetEmail() {
        guard !email.isEmpty else {
            state = .failed("Please enter your email")
            return
        }
        
        currentTask?.cancel()
        state = .loading
        
        currentTask = Task { @MainActor in
            do {
                let response = try await authService.forgotPassword(email: email)
                self.state = .success(response.message)
            } catch {
                self.state = .failed(error.localizedDescription)
            }
        }
    }
    
    deinit {
        currentTask?.cancel()
    }
}
