import Foundation
import Alamofire

protocol UserServiceProtocol: Service {
    func getUserByEmail(_ email: String) async throws -> User
}

final class UserService: UserServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func getUserByEmail(_ email: String) async throws -> User {
        print("📡 Fetching user profile for: \(email)")
        let user: User = try await networkManager.request(.getUserByEmail(email: email), method: .get)
        print("✅ User profile fetched: \(user.id)")
        return user
    }
}
