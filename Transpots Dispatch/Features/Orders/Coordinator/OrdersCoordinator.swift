import SwiftUI
import Combine

enum OrdersRoute: Hashable {
    case orderDetail(orderId: Int)
}

final class OrdersCoordinator: Coordinator, ObservableObject {
    @Published var path = NavigationPath()
    
    func push(_ route: OrdersRoute) {
        path.append(route)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    @ViewBuilder
    func view(for route: OrdersRoute) -> some View {
        switch route {
        case .orderDetail(let orderId):
            OrderDetailView(
                viewModel: OrderDetailViewModel(
                    orderId: orderId,
                    orderService: OrderService()
                )
            )
        }
    }
}
