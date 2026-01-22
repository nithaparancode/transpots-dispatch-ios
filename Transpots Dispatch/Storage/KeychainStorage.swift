import Foundation
import Security

final class KeychainStorage: StorageProtocol {
    static let shared = KeychainStorage()
    
    private let service: String
    
    init(service: String = Bundle.main.bundleIdentifier ?? "com.transpots.dispatch") {
        self.service = service
    }
    
    func save<T: Codable>(_ value: T, forKey key: String) throws {
        let data: Data
        
        if let stringValue = value as? String {
            data = Data(stringValue.utf8)
        } else {
            let encoder = JSONEncoder()
            guard let encoded = try? encoder.encode(value) else {
                throw StorageError.encodingFailed
            }
            data = encoded
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw StorageError.saveFailed
        }
    }
    
    func get<T: Codable>(forKey key: String, as type: T.Type) throws -> T? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw StorageError.unknown("Keychain read failed with status: \(status)")
        }
        
        guard let data = result as? Data else {
            throw StorageError.decodingFailed
        }
        
        if T.self == String.self {
            return String(data: data, encoding: .utf8) as? T
        } else {
            let decoder = JSONDecoder()
            guard let decoded = try? decoder.decode(T.self, from: data) else {
                throw StorageError.decodingFailed
            }
            return decoded
        }
    }
    
    func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw StorageError.deleteFailed
        }
    }
    
    func clear() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw StorageError.deleteFailed
        }
    }
}
