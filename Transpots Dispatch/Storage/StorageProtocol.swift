import Foundation

protocol StorageProtocol {
    func save<T: Codable>(_ value: T, forKey key: String) throws
    func get<T: Codable>(forKey key: String, as type: T.Type) throws -> T?
    func delete(forKey key: String) throws
    func clear() throws
}

enum StorageError: Error {
    case encodingFailed
    case decodingFailed
    case saveFailed
    case deleteFailed
    case notFound
    case unknown(String)
}
