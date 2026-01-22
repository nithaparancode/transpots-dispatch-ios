import Foundation
import Alamofire

protocol TripServiceProtocol: Service {
    func fetchTrips(status: String, page: Int, size: Int) async throws -> TripResponse
}

final class TripService: TripServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func fetchTrips(status: String, page: Int, size: Int) async throws -> TripResponse {
        print("📡 Fetching trips - Status: \(status), Page: \(page), Size: \(size)")
        let response: TripResponse = try await networkManager.request(
            .fetchTrips(status: status, page: page, size: size, sortBy: "tripId"),
            method: .get
        )
        print("✅ Trips fetched: \(response.trips.count) trips")
        return response
    }
}
