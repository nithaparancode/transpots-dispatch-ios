import SwiftUI
import Combine

enum TripsRoute: Hashable {
    case tripDetail(trip: Trip)
}

final class TripsCoordinator: Coordinator, ObservableObject {
    @Published var path = NavigationPath()
    
    func push(_ route: TripsRoute) {
        path.append(route)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    @ViewBuilder
    func view(for route: TripsRoute) -> some View {
        switch route {
        case .tripDetail(let trip):
            TripDetailView(
                viewModel: TripDetailViewModel(trip: trip)
            )
        }
    }
}
