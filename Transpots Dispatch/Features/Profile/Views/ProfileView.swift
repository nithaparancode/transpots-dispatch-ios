import SwiftUI
import TranspotsUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @ObservedObject var coordinator: ProfileCoordinator
    @Environment(\.theme) var theme
    
    init(viewModel: ProfileViewModel = ProfileViewModel(), coordinator: ProfileCoordinator = ProfileCoordinator()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._coordinator = ObservedObject(wrappedValue: coordinator)
    }
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            contentView
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    if viewModel.state == .idle {
                        viewModel.loadUserProfile()
                    }
                }
                .navigationDestination(for: ProfileRoute.self) { route in
                    coordinator.view(for: route)
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
            profileContent(user)
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading profile...")
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
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 140, height: 44)
            .background(theme.colors.primary)
            .cornerRadius(theme.radius.md)
        }
    }
    
    private func profileContent(_ user: User) -> some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                profileHeader(user)
                
                managementSection(user)
                informationSection(user)
                
                logoutButton
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
                    .frame(width: 100, height: 100)
                    .shadow(color: theme.colors.primary.opacity(0.3), radius: 12, y: 4)
                
                Text(user.fullName.prefix(1).uppercased())
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(user.fullName)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(theme.colors.text)
            
            Text(user.email)
                .font(.system(size: 15))
                .foregroundColor(theme.colors.secondaryText)
            
            if let role = user.role {
                Text(role.capitalized)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(theme.colors.primary)
                    )
            }
        }
        .padding(.vertical, theme.spacing.lg)
    }
    
    // MARK: - Management Section
    
    private func managementSection(_ user: User) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            sectionHeader(title: "Management", icon: "briefcase.fill")
            
            VStack(spacing: theme.spacing.md) {
                driversCard()
                invoicesCard()
            }
        }
    }
    
    // MARK: - Information Section
    
    private func informationSection(_ user: User) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            sectionHeader(title: "Information", icon: "info.circle.fill")
            
            VStack(spacing: theme.spacing.md) {
                personalInfoCard()
                companyInfoCard()
                accountInfoCard()
            }
        }
    }
    
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: theme.spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(theme.colors.primary)
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(theme.colors.text)
        }
    }
    
    private func personalInfoCard() -> some View {
        Button(action: {
            coordinator.push(.personalInfo)
        }) {
            HStack(spacing: theme.spacing.md) {
                AppSymbols.profileUser
                    .font(.system(size: 24))
                    .foregroundColor(theme.colors.primary)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text("Personal Information")
                        .font(theme.fonts.headline)
                        .foregroundColor(theme.colors.text)
                    
                    Text("Name, email, phone number")
                        .font(theme.fonts.caption)
                        .foregroundColor(theme.colors.secondaryText)
                }
                
                Spacer()
                
                AppSymbols.navForward
                    .font(.system(size: 16))
                    .foregroundColor(theme.colors.secondaryText)
            }
            .padding(theme.spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.xl)
                    .fill(theme.colors.secondaryBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func companyInfoCard() -> some View {
        Button(action: {
            coordinator.push(.companyInfo)
        }) {
            HStack(spacing: theme.spacing.md) {
                AppSymbols.profileSettings
                    .font(.system(size: 24))
                    .foregroundColor(theme.colors.primary)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text("Company Information")
                        .font(theme.fonts.headline)
                        .foregroundColor(theme.colors.text)
                    
                    Text("Company name and ID")
                        .font(theme.fonts.caption)
                        .foregroundColor(theme.colors.secondaryText)
                }
                
                Spacer()
                
                AppSymbols.navForward
                    .font(.system(size: 16))
                    .foregroundColor(theme.colors.secondaryText)
            }
            .padding(theme.spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.xl)
                    .fill(theme.colors.secondaryBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func accountInfoCard() -> some View {
        Button(action: {
            coordinator.push(.accountInfo)
        }) {
            HStack(spacing: theme.spacing.md) {
                AppSymbols.statusInfo
                    .font(.system(size: 24))
                    .foregroundColor(theme.colors.primary)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text("Account Information")
                        .font(theme.fonts.headline)
                        .foregroundColor(theme.colors.text)
                    
                    Text("User ID, status, member since")
                        .font(theme.fonts.caption)
                        .foregroundColor(theme.colors.secondaryText)
                }
                
                Spacer()
                
                AppSymbols.navForward
                    .font(.system(size: 16))
                    .foregroundColor(theme.colors.secondaryText)
            }
            .padding(theme.spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.xl)
                    .fill(theme.colors.secondaryBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func driversCard() -> some View {
        Button(action: {
            coordinator.push(.drivers)
        }) {
            HStack(spacing: theme.spacing.md) {
                AppSymbols.tripDriver
                    .font(.system(size: 24))
                    .foregroundColor(theme.colors.primary)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text("Drivers")
                        .font(theme.fonts.headline)
                        .foregroundColor(theme.colors.text)
                    
                    Text("Manage driver fleet and assignments")
                        .font(theme.fonts.caption)
                        .foregroundColor(theme.colors.secondaryText)
                }
                
                Spacer()
                
                AppSymbols.navForward
                    .font(.system(size: 16))
                    .foregroundColor(theme.colors.secondaryText)
            }
            .padding(theme.spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.xl)
                    .fill(theme.colors.secondaryBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func invoicesCard() -> some View {
        Button(action: {
            // TODO: Implement invoices navigation
        }) {
            HStack(spacing: theme.spacing.md) {
                AppSymbols.actionDocument
                    .font(.system(size: 24))
                    .foregroundColor(theme.colors.primary)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text("Invoices")
                        .font(theme.fonts.headline)
                        .foregroundColor(theme.colors.text)
                    
                    Text("Coming soon - Manage billing and invoices")
                        .font(theme.fonts.caption)
                        .foregroundColor(theme.colors.secondaryText)
                }
                
                Spacer()
                
                VStack(spacing: theme.spacing.xs) {
                    Text("Coming Soon")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(theme.colors.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(theme.colors.primary.opacity(0.1))
                        )
                    
                    AppSymbols.navForward
                        .font(.system(size: 16))
                        .foregroundColor(theme.colors.secondaryText.opacity(0.5))
                }
            }
            .padding(theme.spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.xl)
                    .fill(theme.colors.secondaryBackground.opacity(0.7))
                    .shadow(color: Color.black.opacity(0.03), radius: 4, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(true)
    }
    
    private var logoutButton: some View {
        Button(action: {
            viewModel.logout()
        }) {
            HStack(spacing: theme.spacing.sm) {
                AppSymbols.profileLogout
                    .font(.system(size: 18, weight: .semibold))
                Text("Logout")
                    .font(theme.fonts.headline)
            }
            .foregroundColor(theme.colors.error)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(theme.colors.error.opacity(0.1))
            .cornerRadius(theme.radius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.xl)
                    .stroke(theme.colors.error.opacity(0.3), lineWidth: 1.5)
            )
        }
        .padding(.top, theme.spacing.lg)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM d, yyyy"
        return displayFormatter.string(from: date)
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel())
    }
}
#endif
