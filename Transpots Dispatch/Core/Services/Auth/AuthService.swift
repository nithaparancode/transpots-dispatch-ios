import Foundation
import Alamofire

protocol AuthServiceProtocol: Service {
    func login(username: String, password: String) async throws -> LoginResponse
    func register(firstName: String, lastName: String, email: String, password: String, address: String) async throws -> RegisterResponse
    func forgotPassword(email: String) async throws -> ForgotPasswordResponse
}

final class AuthService: AuthServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func login(username: String, password: String) async throws -> LoginResponse {
        let request = LoginRequest(username: username, password: password)
        return try await networkManager.request(.login, method: .post, parameters: request)
    }
    
    func register(firstName: String, lastName: String, email: String, password: String, address: String) async throws -> RegisterResponse {
        let request = RegisterRequest(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            address: address
        )
        return try await networkManager.request(.register, method: .post, parameters: request)
    }
    
    func forgotPassword(email: String) async throws -> ForgotPasswordResponse {
        return try await networkManager.request(.forgotPassword(email: email), method: .post)
    }
}
