import Foundation

final class UserDefaultsStorage: StorageProtocol {
    static let shared = UserDefaultsStorage()
    
    private let userDefaults: UserDefaults
    private let suiteName: String?
    
    init(suiteName: String? = nil) {
        self.suiteName = suiteName
        self.userDefaults = suiteName != nil ? UserDefaults(suiteName: suiteName)! : .standard
    }
    
    func save<T: Codable>(_ value: T, forKey key: String) throws {
        if let stringValue = value as? String {
            userDefaults.set(stringValue, forKey: key)
        } else if let intValue = value as? Int {
            userDefaults.set(intValue, forKey: key)
        } else if let boolValue = value as? Bool {
            userDefaults.set(boolValue, forKey: key)
        } else if let doubleValue = value as? Double {
            userDefaults.set(doubleValue, forKey: key)
        } else {
            let encoder = JSONEncoder()
            guard let data = try? encoder.encode(value) else {
                throw StorageError.encodingFailed
            }
            userDefaults.set(data, forKey: key)
        }
        userDefaults.synchronize()
    }
    
    func get<T: Codable>(forKey key: String, as type: T.Type) throws -> T? {
        if T.self == String.self {
            return userDefaults.string(forKey: key) as? T
        } else if T.self == Int.self {
            return userDefaults.integer(forKey: key) as? T
        } else if T.self == Bool.self {
            return userDefaults.bool(forKey: key) as? T
        } else if T.self == Double.self {
            return userDefaults.double(forKey: key) as? T
        } else {
            guard let data = userDefaults.data(forKey: key) else {
                return nil
            }
            let decoder = JSONDecoder()
            guard let decoded = try? decoder.decode(T.self, from: data) else {
                throw StorageError.decodingFailed
            }
            return decoded
        }
    }
    
    func delete(forKey key: String) throws {
        userDefaults.removeObject(forKey: key)
        userDefaults.synchronize()
    }
    
    func clear() throws {
        if let suiteName = suiteName {
            userDefaults.removePersistentDomain(forName: suiteName)
        } else {
            if let bundleID = Bundle.main.bundleIdentifier {
                userDefaults.removePersistentDomain(forName: bundleID)
            }
        }
        userDefaults.synchronize()
    }
}
