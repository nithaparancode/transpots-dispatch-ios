import Foundation

struct User: Codable, Equatable {
    let id: String
    let companyName: String?
    let streetNumber: String?
    let unitNumber: String?
    let streetName: String?
    let city: String?
    let state: String?
    let zipCode: String?
    let country: String?
    let email: String
    let taxNumber: String?
    let taxPercentage: Double?
    let orderStartNumber: Int?
    let tripPrefix: String?
    let tripStartNumber: Int?
    let invoicePrefix: String?
    let invoiceStartNumber: Int?
    let orderPrefix: String?
    let deletedAt: String?
    let createdAt: String?
    let modifiedAt: String?
    let outMail: String?
    let verified: Bool?
    let otp: Int?
    
    // Profile-related fields
    let userId: Int?
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
    let companyId: Int?
    let role: String?
    let status: String?
    let updatedAt: String?
    
    var fullName: String {
        let first = firstName ?? ""
        let last = lastName ?? ""
        if first.isEmpty && last.isEmpty {
            return companyName ?? "User"
        }
        return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
    }
}
