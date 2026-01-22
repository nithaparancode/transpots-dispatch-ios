import Foundation

struct RefreshTokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
}
