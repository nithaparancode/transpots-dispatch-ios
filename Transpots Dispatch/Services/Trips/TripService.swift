import Foundation
import Alamofire

protocol TripServiceProtocol: Service {
    func fetchTrips(status: String, page: Int, size: Int) async throws -> TripResponse
    func createTrip(request: CreateTripRequest) async throws -> Trip
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
    
    func createTrip(request: CreateTripRequest) async throws -> Trip {
        print("📡 Creating trip with \(request.tripTasks.count) tasks")
        
        do {
            let trip: Trip = try await networkManager.request(
                .createTrip,
                method: .post,
                parameters: request
            )
            print("✅ Trip created: \(trip.userTripId)")
            return trip
        } catch {
            print("❌ Create trip API error: \(error)")
            throw error
        }
    }
}
