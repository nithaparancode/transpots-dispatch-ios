import SwiftUI
import Combine

enum ProfileRoute: Hashable {
    case drivers
}

final class ProfileCoordinator: Coordinator {
    typealias Route = ProfileRoute
    @Published var path = NavigationPath()
    
    func push(_ route: Route) {
        path.append(route)
    }
    
    @ViewBuilder
    func view(for route: ProfileRoute) -> some View {
        switch route {
        case .drivers:
            DriversView()
        }
    }
}
