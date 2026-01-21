import Foundation
import Combine

final class SignUpViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle
        case loading
        case success
        case failed(String)
    }
    
    @Published var state: ViewState = .idle
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var address: String = ""
    
    private var currentTask: Task<Void, Never>?
    private let authService: AuthServiceProtocol
    private let userService: UserServiceProtocol
    
    init(authService: AuthServiceProtocol, userService: UserServiceProtocol = UserService()) {
        self.authService = authService
        self.userService = userService
    }
    
    func signUp() {
        guard !email.isEmpty, !password.isEmpty else {
            state = .failed("Please enter email and password")
            return
        }
        
        currentTask?.cancel()
        state = .loading
        
        currentTask = Task { @MainActor in
            do {
                let response = try await authService.register(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    password: password,
                    address: address
                )
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
