import Foundation
import Security

final class TokenManager {
    static let shared = TokenManager()
    
    private let accessTokenKey = "com.transpots.accessToken"
    private let refreshTokenKey = "com.transpots.refreshToken"
    
    private init() {}
    
    var accessToken: String? {
        get { getToken(for: accessTokenKey) }
        set { saveToken(newValue, for: accessTokenKey) }
    }
    
    var refreshToken: String? {
        get { getToken(for: refreshTokenKey) }
        set { saveToken(newValue, for: refreshTokenKey) }
    }
    
    func saveTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    func clearTokens() {
        deleteToken(for: accessTokenKey)
        deleteToken(for: refreshTokenKey)
    }
    
    private func saveToken(_ token: String?, for key: String) {
        guard let token = token else {
            deleteToken(for: key)
            return
        }
        
        let data = Data(token.utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func getToken(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    private func deleteToken(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
