import Foundation

struct Driver: Codable, Identifiable, Equatable {
    let id: String
    let firstName: String
    let lastName: String
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
        "\(firstName)\(lastName)"
    }
    
    var displayName: String {
        fullName.trimmingCharacters(in: .whitespaces)
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
