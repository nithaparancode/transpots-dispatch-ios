import Foundation

struct DriverResponse: Codable {
    let data: [Driver]
}

struct EmptyResponse: Codable {
    // Empty response for delete operations
}

struct CreateDriverRequest: Codable {
    let firstName: String
    let lastName: String
    let phone: String
    let owner: CreateDriverOwner
}

struct CreateDriverOwner: Codable {
    let id: String
    let companyAddress: String
    let companyName: String
    let email: String
    let password: String
}

struct Driver: Codable, Identifiable, Equatable {
    let id: String
    let firstName: String?
    let lastName: String?
    let phone: String
    let address: String?
    let licenseNumber: String?
    let dateOfIssue: String?
    let expiryDate: String?
    let driverReferenceNumber: String?
    let sex: String?
    let licenseClass: String?
    let restrictions: String?
    let dateOfBirth: String?
    let height: String?
    let typeOfLicense: String?
    let province: String?
    let tractorId: String?
    let trailerId: String?
    let verified: String?
    let createdAt: String?
    let modifiedAt: String?
    let otp: Int?
    let driverAppStatus: String?
    
    var fullName: String {
        let first = firstName ?? ""
        let last = lastName ?? ""
        return "\(first)\(last)"
    }
    
    var displayName: String {
        let name = fullName.trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? phone : name
    }
}

struct CreateTripRequest: Codable {
    let userId: String
    let userTripId: String
    let firstDriverName: String
    let firstDriverId: String
    let secondDriverName: String
    let secondDriverId: String
    let tripTasks: [CreateTripTask]
}

struct CreateTripTask: Codable {
    let orderEventId: Int?
    let type: String
    let sequenceId: Int
    let tractorId: String?
    let trailerId: String?
    let name: String
    let address: String
    let startTime: String
    let estimatedTime: String?
    let orderId: String?
}
