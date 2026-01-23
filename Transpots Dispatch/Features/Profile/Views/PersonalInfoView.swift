import SwiftUI
import TranspotsUI

struct PersonalInfoView: View {
    @Environment(\.theme) var theme
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        contentView
            .navigationTitle("Personal Information")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .onAppear {
                if viewModel.state == .idle {
                    viewModel.loadUserProfile()
                }
            }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .idle:
            Color.clear
        case .loading:
            loadingView
        case .failed(let error):
            errorView(message: error)
        case .loaded(let user):
            personalInfoContent(user)
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading personal information...")
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.secondaryText)
                .padding(.top, theme.spacing.md)
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: theme.spacing.lg) {
            AppSymbols.statusError
                .font(.system(size: 50))
                .foregroundColor(theme.colors.error)
            
            Text("Something went wrong")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(theme.colors.text)
            
            Text(message)
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, theme.spacing.xl)
            
            Button("Try Again") {
                viewModel.loadUserProfile()
            }
            .font(theme.fonts.headline)
            .foregroundColor(.white)
            .frame(width: 140, height: 44)
            .background(theme.colors.primary)
            .cornerRadius(theme.radius.md)
        }
    }
    
    private func personalInfoContent(_ user: User) -> some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                profileHeader(user)
                
                personalInfoCard(user)
            }
            .padding(theme.spacing.lg)
        }
        .background(theme.colors.background)
    }
    
    private func profileHeader(_ user: User) -> some View {
        VStack(spacing: theme.spacing.md) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [theme.colors.primary, theme.colors.primary.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: theme.colors.primary.opacity(0.3), radius: 12, y: 4)
                
                Text(user.fullName.prefix(1).uppercased())
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(user.fullName)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(theme.colors.text)
            
            if let role = user.role {
                Text(role.capitalized)
                    .font(theme.fonts.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(theme.colors.primary)
                    )
            }
        }
        .padding(.vertical, theme.spacing.md)
    }
    
    private func personalInfoCard(_ user: User) -> some View {
        VStack(spacing: theme.spacing.lg) {
            ReadOnlyFormField(
                label: "First Name",
                value: user.firstName ?? "",
                icon: "person.fill"
            )
            
            ReadOnlyFormField(
                label: "Last Name",
                value: user.lastName ?? "",
                icon: "person.fill"
            )
            
            ReadOnlyFormField(
                label: "Email Address",
                value: user.email,
                icon: "envelope.fill"
            )
            
            if let phone = user.phoneNumber {
                ReadOnlyFormField(
                    label: "Phone Number",
                    value: phone,
                    icon: "phone.fill"
                )
            }
        }
        .padding(theme.spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.xl)
                .fill(theme.colors.secondaryBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
        )
    }
}

#if DEBUG
struct PersonalInfoView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalInfoView()
    }
}
#endif
