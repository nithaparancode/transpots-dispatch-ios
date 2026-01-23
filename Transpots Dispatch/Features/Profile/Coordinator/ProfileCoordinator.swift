import SwiftUI
import Combine

enum ProfileRoute: Hashable {
    case personalInfo
    case companyInfo
    case accountInfo
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
        case .personalInfo:
            PersonalInfoView()
        case .companyInfo:
            CompanyInfoView()
        case .accountInfo:
            AccountInfoView()
        case .drivers:
            DriversView()
        }
    }
}
