import SwiftUI
import TranspotsUI

struct ForgotPasswordView: View {
    @StateObject var viewModel: ForgotPasswordViewModel
    @ObservedObject var coordinator: AuthCoordinator
    @Environment(\.theme) var theme
    
    var body: some View {
        contentView
            .background(theme.colors.background)
            .navigationTitle("Forgot Password")
            .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Content Views
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .idle, .loading, .failed:
            formView
        case .success(let message):
            successView(message: message)
        }
    }
    
    private var formView: some View {
        ScrollView {
            VStack(spacing: theme.spacing.xl) {
                headerSection
                
                formSection
                
                actionButtons
            }
            .padding(theme.spacing.xl)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: theme.spacing.md) {
            ZStack {
                Circle()
                    .fill(theme.colors.primary.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                AppSymbols.statusInfo
                    .font(.system(size: 40))
                    .foregroundColor(theme.colors.primary)
            }
            .padding(.bottom, theme.spacing.sm)
            
            Text("Reset Password")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(theme.colors.text)
            
            Text("Enter your email address and we'll send you instructions to reset your password")
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, theme.spacing.md)
        }
        .padding(.bottom, theme.spacing.md)
    }
    
    private var formSection: some View {
        CustomTextField(
            title: "Email",
            text: $viewModel.email,
            placeholder: "Enter your email",
            keyboardType: .emailAddress,
            autocapitalization: .never
        )
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
                title: "Send Reset Link",
                isLoading: viewModel.state == .loading,
                action: {
                    viewModel.sendResetEmail()
                }
            )
            .disabled(viewModel.state == .loading)
            
            Button(action: {
                coordinator.pop()
            }) {
                Text("Back to Sign In")
                    .font(theme.fonts.subheadline)
                    .foregroundColor(theme.colors.primary)
            }
            .padding(.top, theme.spacing.sm)
        }
    }
    
    private func successView(message: String) -> some View {
        VStack(spacing: theme.spacing.xl) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(theme.colors.success.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(theme.colors.success)
            }
            
            VStack(spacing: theme.spacing.md) {
                Text("Email Sent!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(theme.colors.text)
                
                Text(message)
                    .font(theme.fonts.body)
                    .foregroundColor(theme.colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, theme.spacing.xl)
            }
            
            Spacer()
            
            PrimaryButton(
                title: "Back to Sign In",
                isLoading: false,
                action: {
                    coordinator.pop()
                }
            )
            .padding(.horizontal, theme.spacing.xl)
            .padding(.bottom, theme.spacing.xl)
        }
    }
}
