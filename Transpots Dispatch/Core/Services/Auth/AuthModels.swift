import Foundation

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String?
    let userId: String?
}

struct RegisterRequest: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let address: String
}

struct RegisterResponse: Codable {
    let accessToken: String
    let refreshToken: String?
    let userId: String?
}

struct ForgotPasswordResponse: Codable {
    let message: String
}
