import Foundation
import Combine

final class LoginViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle
        case loading
        case success
        case failed(String)
    }
    
    @Published var state: ViewState = .idle
    @Published var email: String = ""
    @Published var password: String = ""
    
    private var currentTask: Task<Void, Never>?
    private let authService: AuthServiceProtocol
    private let userService: UserServiceProtocol
    
    init(authService: AuthServiceProtocol, userService: UserServiceProtocol = UserService()) {
        self.authService = authService
        self.userService = userService
    }
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            state = .failed("Please enter both email and password")
            return
        }
        
        currentTask?.cancel()
        state = .loading
        
        currentTask = Task { @MainActor in
            do {
                let response = try await authService.login(username: email, password: password)
                TokenManager.shared.saveTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken ?? ""
                )
                
                let user = try await userService.getUserByEmail(email)
                TokenManager.shared.userId = user.id
                
                self.state = .success
                NotificationCenter.default.post(name: .userDidLogin, object: nil)
            } catch {
                self.state = .failed(error.localizedDescription)
            }
        }
    }
    
    deinit {
        currentTask?.cancel()
    }
}
