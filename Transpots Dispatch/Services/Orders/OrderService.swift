import Foundation
import TranspotsNetworking

protocol OrderServiceProtocol: Service {
    func fetchOrders(status: OrderStatus, page: Int, size: Int) async throws -> OrdersResponse
    func getOrderDetail(orderId: Int) async throws -> Order
    func updateOrder(_ order: Order) async throws -> Order
}

final class OrderService: OrderServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = NetworkManagerFactory.shared) {
        self.networkManager = networkManager
    }
    
    func fetchOrders(status: OrderStatus, page: Int, size: Int) async throws -> OrdersResponse {
        print("📡 Fetching \(status.rawValue) orders - page: \(page), size: \(size)")
        
        do {
            let response: OrdersResponse = try await networkManager.request(
                APIEndpoint.fetchOrders(status: status.rawValue, page: page, size: size),
                method: .get
            )
            print("✅ Orders fetched: \(response.orders.count) orders")
            return response
        } catch {
            print("❌ Orders API error: \(error)")
            throw error
        }
    }
    
    func getOrderDetail(orderId: Int) async throws -> Order {
        print("📡 Fetching order detail for ID: \(orderId)")
        
        do {
            let order: Order = try await networkManager.request(
                APIEndpoint.getOrderDetail(orderId: orderId),
                method: .get
            )
            print("✅ Order detail fetched: \(order.userOrderId)")
            return order
        } catch {
            print("❌ Order detail API error: \(error)")
            throw error
        }
    }
    
    func updateOrder(_ order: Order) async throws -> Order {
        print("📡 Updating order: \(order.userOrderId)")
        
        do {
            let updatedOrder: Order = try await networkManager.request(
                APIEndpoint.updateOrder(orderId: order.orderId),
                method: .put,
                parameters: order
            )
            print("✅ Order updated successfully")
            return updatedOrder
        } catch {
            print("❌ Update order API error: \(error)")
            throw error
        }
    }
}
