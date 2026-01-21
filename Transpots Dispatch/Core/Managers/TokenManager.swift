import Foundation

final class TokenManager {
    static let shared = TokenManager()
    
    private let storageManager: StorageManager
    private let accessTokenKey = "com.transpots.accessToken"
    private let refreshTokenKey = "com.transpots.refreshToken"
    
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
    
    func saveTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    func clearTokens() {
        try? storageManager.delete(forKey: accessTokenKey, from: .secure)
        try? storageManager.delete(forKey: refreshTokenKey, from: .secure)
    }
}
