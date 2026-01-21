import SwiftUI
import Combine

enum OrdersRoute: Hashable {
    case orderDetail(id: String)
}

final class OrdersCoordinator: Coordinator {
    typealias Route = OrdersRoute
    
    @Published var path = NavigationPath()
    
    @ViewBuilder
    func view(for route: OrdersRoute) -> some View {
        switch route {
        case .orderDetail(let id):
            Text("Order detail for: \(id)")
                .navigationTitle("Order Detail")
        }
    }
}
