import SwiftUI
import TranspotsUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @Environment(\.theme) var theme
    
    var body: some View {
        NavigationView {
            contentView
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    if case .idle = viewModel.state {
                        viewModel.loadUserProfile()
                    }
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
            Image(systemName: "exclamationmark.triangle.fill")
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
                
                userInfoSection(user)
                
                companyInfoSection(user)
                
                accountInfoSection(user)
                
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
    
    private func userInfoSection(_ user: User) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            sectionHeader(title: "Personal Information", icon: "person.fill")
            
            sectionCard {
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
            }
        }
    }
    
    private func companyInfoSection(_ user: User) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            sectionHeader(title: "Company Information", icon: "building.2.fill")
            
            sectionCard {
                VStack(spacing: theme.spacing.lg) {
                    ReadOnlyFormField(
                        label: "Company Name",
                        value: user.companyName ?? "",
                        icon: "building.2"
                    )
                    
                    ReadOnlyFormField(
                        label: "Company ID",
                        value: user.companyId != nil ? "\(user.companyId!)" : "",
                        icon: "number"
                    )
                }
            }
        }
    }
    
    private func accountInfoSection(_ user: User) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            sectionHeader(title: "Account Information", icon: "info.circle.fill")
            
            sectionCard {
                VStack(spacing: theme.spacing.lg) {
                    ReadOnlyFormField(
                        label: "User ID",
                        value: user.id,
                        icon: "number.circle"
                    )
                    
                    if let status = user.status {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(theme.colors.primary)
                                    Text("Account Status")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(theme.colors.secondaryText)
                                        .textCase(.uppercase)
                                        .tracking(0.5)
                                }
                                
                                Text(status.capitalized)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(status.lowercased() == "active" ? theme.colors.success : theme.colors.secondaryText)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: theme.radius.lg)
                                            .fill(status.lowercased() == "active" ? theme.colors.success.opacity(0.1) : theme.colors.secondaryBackground)
                                    )
                            }
                            Spacer()
                        }
                    }
                    
                    if let createdAt = user.createdAt {
                        ReadOnlyFormField(
                            label: "Member Since",
                            value: formatDate(createdAt),
                            icon: "calendar"
                        )
                    }
                }
            }
        }
    }
    
    private var logoutButton: some View {
        Button(action: {
            viewModel.logout()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "arrow.right.square")
                    .font(.system(size: 18, weight: .semibold))
                Text("Logout")
                    .font(.system(size: 17, weight: .semibold))
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
    
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(theme.colors.primary)
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(theme.colors.text)
        }
    }
    
    @ViewBuilder
    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(theme.spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.xl)
                    .fill(theme.colors.secondaryBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
            )
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
