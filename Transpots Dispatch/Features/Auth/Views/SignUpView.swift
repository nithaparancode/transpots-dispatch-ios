import SwiftUI
import TranspotsUI

struct SignUpView: View {
    @StateObject var viewModel: SignUpViewModel
    @ObservedObject var coordinator: AuthCoordinator
    @Environment(\.theme) var theme
    
    var body: some View {
        contentView
            .background(theme.colors.background)
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Content Views
    
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
        VStack(spacing: theme.spacing.sm) {
            Text("Join Transpots")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(theme.colors.text)
            
            Text("Create your account to get started")
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.secondaryText)
        }
        .padding(.bottom, theme.spacing.md)
    }
    
    private var formSection: some View {
        VStack(spacing: theme.spacing.lg) {
            HStack(spacing: theme.spacing.md) {
                CustomTextField(
                    title: "First Name",
                    text: $viewModel.firstName,
                    placeholder: "First name"
                )
                
                CustomTextField(
                    title: "Last Name",
                    text: $viewModel.lastName,
                    placeholder: "Last name"
                )
            }
            
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
                placeholder: "Create a password",
                isSecure: true
            )
            
            CustomTextField(
                title: "Address (Optional)",
                text: $viewModel.address,
                placeholder: "Enter your address"
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
                title: "Create Account",
                isLoading: viewModel.state == .loading,
                action: {
                    viewModel.signUp()
                }
            )
            .disabled(viewModel.state == .loading)
        }
    }
    
    private var footerLinks: some View {
        HStack(spacing: theme.spacing.xs) {
            Text("Already have an account?")
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.secondaryText)
            
            Button(action: {
                coordinator.pop()
            }) {
                Text("Sign In")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.colors.primary)
            }
        }
        .padding(.top, theme.spacing.lg)
    }
}
