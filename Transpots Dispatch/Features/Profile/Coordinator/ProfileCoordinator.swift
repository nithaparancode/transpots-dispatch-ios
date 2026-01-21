import SwiftUI
import Combine

enum ProfileRoute: Hashable {
    case settings
    case editProfile
}

final class ProfileCoordinator: Coordinator {
    typealias Route = ProfileRoute
    
    @Published var path = NavigationPath()
    
    @ViewBuilder
    func view(for route: ProfileRoute) -> some View {
        switch route {
        case .settings:
            Text("Settings")
                .navigationTitle("Settings")
        case .editProfile:
            Text("Edit Profile")
                .navigationTitle("Edit Profile")
        }
    }
}
