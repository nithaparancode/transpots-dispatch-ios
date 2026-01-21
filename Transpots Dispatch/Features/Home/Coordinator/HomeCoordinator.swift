import SwiftUI
import Combine

enum HomeRoute: Hashable {
    case detail(id: String)
}

final class HomeCoordinator: Coordinator {
    typealias Route = HomeRoute
    
    @Published var path = NavigationPath()
    
    @ViewBuilder
    func view(for route: HomeRoute) -> some View {
        switch route {
        case .detail(let id):
            Text("Detail view for: \(id)")
                .navigationTitle("Detail")
        }
    }
}
