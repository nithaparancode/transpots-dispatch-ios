import SwiftUI
import TranspotsUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    @ObservedObject var coordinator: AuthCoordinator
    @Environment(\.theme) var theme
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            contentView
                .background(theme.colors.background)
                .navigationBarHidden(true)
                .navigationDestination(for: AuthRoute.self) { route in
                    coordinator.view(for: route)
                }
        }
    }
    
    // MARK: - Content Views
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(spacing: theme.spacing.xl) {
                headerSection
                
                formSection
                
                actionButtons
                
                footerLinks
            }
            .padding(theme.spacing.xl)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: theme.spacing.md) {
            AppSymbols.launchTruck
                .font(.system(size: 60))
                .foregroundColor(theme.colors.primary)
                .padding(.top, theme.spacing.xxl)
            
            Text("Welcome Back")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(theme.colors.text)
            
            Text("Sign in to continue")
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.secondaryText)
        }
        .padding(.bottom, theme.spacing.lg)
    }
    
    private var formSection: some View {
        VStack(spacing: theme.spacing.lg) {
            CustomTextField(
                title: "Email",
                text: $viewModel.email,
                placeholder: "Enter your email",
                keyboardType: .emailAddress,
                autocapitalization: .never
            )
            
            CustomTextField(
                title: "Password",
                text: $viewModel.password,
                placeholder: "Enter your password",
                isSecure: true
            )
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: theme.spacing.md) {
            if case .failed(let error) = viewModel.state {
                Text(error)
                    .font(theme.fonts.caption)
                    .foregroundColor(theme.colors.error)
                    .padding(.horizontal, theme.spacing.md)
                    .multilineTextAlignment(.center)
            }
            
            PrimaryButton(
                title: "Sign In",
                isLoading: viewModel.state == .loading,
                action: {
                    viewModel.login()
                }
            )
            .disabled(viewModel.state == .loading)
        }
    }
    
    private var footerLinks: some View {
        VStack(spacing: theme.spacing.lg) {
            Button(action: {
                coordinator.push(.forgotPassword)
            }) {
                Text("Forgot Password?")
                    .font(theme.fonts.subheadline)
                    .foregroundColor(theme.colors.primary)
            }
            
            HStack(spacing: theme.spacing.xs) {
                Text("Don't have an account?")
                    .font(theme.fonts.body)
                    .foregroundColor(theme.colors.secondaryText)
                
                Button(action: {
                    coordinator.push(.signUp)
                }) {
                    Text("Sign Up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.colors.primary)
                }
            }
        }
        .padding(.top, theme.spacing.lg)
    }
}
