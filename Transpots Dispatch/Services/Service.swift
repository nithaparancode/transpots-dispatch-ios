import Foundation

/// Base protocol for all services
/// Services handle API calls and business logic, keeping ViewModels clean
protocol Service {
    // Services can define their own methods
}

/// Protocol for services that require initialization
protocol ServiceInitializable {
    init()
}
