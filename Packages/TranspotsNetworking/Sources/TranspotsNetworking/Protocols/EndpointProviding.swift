import Foundation

/// Protocol that represents an API endpoint.
/// Each app defines its own endpoint enum conforming to this protocol.
public protocol EndpointProviding {
    var url: String { get }
}
