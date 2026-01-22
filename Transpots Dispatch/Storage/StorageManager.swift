import Foundation

final class StorageManager {
    static let shared = StorageManager()
    
    private let keychainStorage: StorageProtocol
    private let userDefaultsStorage: StorageProtocol
    
    enum StorageType {
        case secure
        case standard
    }
    
    private init(
        keychainStorage: StorageProtocol = KeychainStorage.shared,
        userDefaultsStorage: StorageProtocol = UserDefaultsStorage.shared
    ) {
        self.keychainStorage = keychainStorage
        self.userDefaultsStorage = userDefaultsStorage
    }
    
    func save<T: Codable>(_ value: T, forKey key: String, in storageType: StorageType) throws {
        switch storageType {
        case .secure:
            try keychainStorage.save(value, forKey: key)
        case .standard:
            try userDefaultsStorage.save(value, forKey: key)
        }
    }
    
    func get<T: Codable>(forKey key: String, as type: T.Type, from storageType: StorageType) throws -> T? {
        switch storageType {
        case .secure:
            return try keychainStorage.get(forKey: key, as: type)
        case .standard:
            return try userDefaultsStorage.get(forKey: key, as: type)
        }
    }
    
    func delete(forKey key: String, from storageType: StorageType) throws {
        switch storageType {
        case .secure:
            try keychainStorage.delete(forKey: key)
        case .standard:
            try userDefaultsStorage.delete(forKey: key)
        }
    }
    
    func clearAll() throws {
        try keychainStorage.clear()
        try userDefaultsStorage.clear()
    }
    
    func clearSecure() throws {
        try keychainStorage.clear()
    }
    
    func clearStandard() throws {
        try userDefaultsStorage.clear()
    }
}
