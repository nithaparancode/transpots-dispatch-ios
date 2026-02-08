import Foundation
import TranspotsNetworking

final class TokenManager: TokenProviding, @unchecked Sendable {
    static let shared = TokenManager()
    
    private let storageManager: StorageManager
    private let accessTokenKey = "com.transpots.accessToken"
    private let refreshTokenKey = "com.transpots.refreshToken"
    private let userIdKey = "com.transpots.userId"
    
    private init(storageManager: StorageManager = .shared) {
        self.storageManager = storageManager
    }
    
    var accessToken: String? {
        get { try? storageManager.get(forKey: accessTokenKey, as: String.self, from: .secure) }
        set {
            if let token = newValue {
                try? storageManager.save(token, forKey: accessTokenKey, in: .secure)
            } else {
                try? storageManager.delete(forKey: accessTokenKey, from: .secure)
            }
        }
    }
    
    var refreshToken: String? {
        get { try? storageManager.get(forKey: refreshTokenKey, as: String.self, from: .secure) }
        set {
            if let token = newValue {
                try? storageManager.save(token, forKey: refreshTokenKey, in: .secure)
            } else {
                try? storageManager.delete(forKey: refreshTokenKey, from: .secure)
            }
        }
    }
    
    var userId: String? {
        get { try? storageManager.get(forKey: userIdKey, as: String.self, from: .secure) }
        set {
            if let id = newValue {
                try? storageManager.save(id, forKey: userIdKey, in: .secure)
            } else {
                try? storageManager.delete(forKey: userIdKey, from: .secure)
            }
        }
    }
    
    func saveTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    func clearTokens() {
        try? storageManager.delete(forKey: accessTokenKey, from: .secure)
        try? storageManager.delete(forKey: refreshTokenKey, from: .secure)
        try? storageManager.delete(forKey: userIdKey, from: .secure)
    }
}
