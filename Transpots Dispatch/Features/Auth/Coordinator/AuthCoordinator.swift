import SwiftUI
import Combine

enum AuthRoute: Hashable {
    case signUp
    case forgotPassword
}

final class AuthCoordinator: Coordinator, ObservableObject {
    @Published var path = NavigationPath()
    
    func push(_ route: AuthRoute) {
        path.append(route)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    @ViewBuilder
    func view(for route: AuthRoute) -> some View {
        switch route {
        case .signUp:
            SignUpView(
                viewModel: SignUpViewModel(authService: AuthService()),
                coordinator: self
            )
        case .forgotPassword:
            ForgotPasswordView(
                viewModel: ForgotPasswordViewModel(authService: AuthService()),
                coordinator: self
            )
        }
    }
}
