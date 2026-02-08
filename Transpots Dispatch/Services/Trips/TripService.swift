import Foundation
import TranspotsNetworking

protocol TripServiceProtocol: Service {
    func fetchTrips(status: String, page: Int, size: Int) async throws -> TripResponse
    func createTrip(request: CreateTripRequest) async throws -> Trip
    func endTrip(tripId: Int) async throws
    func deleteTrip(tripId: Int) async throws
}

final class TripService: TripServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = NetworkManagerFactory.shared) {
        self.networkManager = networkManager
    }
    
    func fetchTrips(status: String, page: Int, size: Int) async throws -> TripResponse {
        print("📡 Fetching trips - Status: \(status), Page: \(page), Size: \(size)")
        let response: TripResponse = try await networkManager.request(
            APIEndpoint.fetchTrips(status: status, page: page, size: size, sortBy: "tripId"),
            method: .get
        )
        print("✅ Trips fetched: \(response.trips.count) trips")
        return response
    }
    
    func createTrip(request: CreateTripRequest) async throws -> Trip {
        print("📡 Creating trip with \(request.tripTasks.count) tasks")
        
        do {
            let trip: Trip = try await networkManager.request(
                APIEndpoint.createTrip,
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
    
    func endTrip(tripId: Int) async throws {
        print("🏁 Ending trip: \(tripId)")
        
        do {
            try await networkManager.request(
                APIEndpoint.endTrip(tripId: tripId),
                method: .post
            )
            print("✅ Trip ended successfully")
        } catch {
            print("❌ End trip error: \(error)")
            throw error
        }
    }
    
    func deleteTrip(tripId: Int) async throws {
        print("🗑️ Deleting trip: \(tripId)")
        
        do {
            try await networkManager.request(
                APIEndpoint.deleteTrip(tripId: tripId),
                method: .delete
            )
            print("✅ Trip deleted successfully")
        } catch {
            print("❌ Delete trip error: \(error)")
            throw error
        }
    }
}
