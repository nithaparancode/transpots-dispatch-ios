import SwiftUI
import TranspotsUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @ObservedObject var coordinator: ProfileCoordinator
    @ObservedObject private var appearanceManager = AppearanceManager.shared
    @ObservedObject private var languageManager = LanguageManager.shared
    @Environment(\.theme) var theme
    
    init(viewModel: ProfileViewModel = ProfileViewModel(), coordinator: ProfileCoordinator = ProfileCoordinator()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._coordinator = ObservedObject(wrappedValue: coordinator)
    }
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            contentView
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    if viewModel.state == .idle {
                        viewModel.loadUserProfile()
                    }
                }
                .navigationDestination(for: ProfileRoute.self) { route in
                    coordinator.view(for: route)
                }
                .alert("Delete Account", isPresented: $viewModel.showDeleteConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        viewModel.deleteAccount()
                    }
                } message: {
                    Text("Are you sure you want to delete your account? This action cannot be undone.")
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
    
    // MARK: - Main Content
    
    private func profileContent(_ user: User) -> some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                driversCard()
                appearanceSection
                languageSection
                logoutButton
                deleteAccountButton
                appInformationSection
            }
            .padding(theme.spacing.md)
        }
        .background(theme.colors.secondaryBackground)
    }
    
    // MARK: - Appearance Section
    
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            sectionHeader(title: "Appearance")
            
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "paintbrush.fill")
                        .font(.system(size: 14))
                        .foregroundColor(theme.colors.primary)
                    Text("Theme")
                        .font(theme.fonts.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.colors.text)
                }
                
                HStack(spacing: theme.spacing.sm) {
                    ForEach(AppearanceManager.AppearanceMode.allCases, id: \.self) { mode in
                        SelectableCardView(
                            title: mode.displayName,
                            icon: mode.icon,
                            isSelected: appearanceManager.selectedMode == mode
                        ) {
                            appearanceManager.selectedMode = mode
                        }
                    }
                }
            }
            .padding(theme.spacing.md)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.xl)
                    .fill(theme.colors.background)
            )
        }
    }
    
    // MARK: - Language Section
    
    private var languageSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            sectionHeader(title: "Language")
            
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "globe")
                        .font(.system(size: 14))
                        .foregroundColor(theme.colors.primary)
                    Text("App Language")
                        .font(theme.fonts.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.colors.text)
                }
                
                let columns = Array(repeating: GridItem(.flexible(), spacing: theme.spacing.sm), count: 3)
                
                LazyVGrid(columns: columns, spacing: theme.spacing.sm) {
                    ForEach(LanguageManager.SupportedLanguage.allCases, id: \.self) { language in
                        SelectableCardView(
                            title: language.displayName,
                            isSelected: languageManager.selectedLanguage == language
                        ) {
                            languageManager.selectedLanguage = language
                        }
                    }
                }
            }
            .padding(theme.spacing.md)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.xl)
                    .fill(theme.colors.background)
            )
        }
    }
    
    // MARK: - Section Header
    
    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(theme.fonts.footnote)
            .fontWeight(.semibold)
            .foregroundColor(theme.colors.primary)
            .textCase(.uppercase)
    }
    
    // MARK: - Drivers Card
    
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
                    .fill(theme.colors.background)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Delete Account
    
    private var deleteAccountButton: some View {
        Button(action: {
            viewModel.showDeleteConfirmation = true
        }) {
            HStack(spacing: theme.spacing.sm) {
                Image(systemName: "trash")
                    .font(.system(size: 16, weight: .semibold))
                Text("Delete Account")
                    .font(theme.fonts.headline)
            }
            .foregroundColor(theme.colors.error)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(theme.spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.xl)
                    .fill(theme.colors.background)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - App Information
    
    private var appInformationSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            sectionHeader(title: "App Information")
            
            VStack(spacing: 0) {
                infoRow(icon: "doc.text", title: "App Version", value: viewModel.appVersion)
                Divider().padding(.horizontal, theme.spacing.md)
                infoRow(icon: "iphone", title: "Device", value: viewModel.deviceInfo)
                Divider().padding(.horizontal, theme.spacing.md)
                infoRow(icon: "app.badge", title: "App Name", value: viewModel.appName)
            }
            .background(
                RoundedRectangle(cornerRadius: theme.radius.xl)
                    .fill(theme.colors.background)
            )
        }
    }
    
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(theme.colors.secondaryText)
                .frame(width: 24)
            
            Text(title)
                .font(theme.fonts.subheadline)
                .foregroundColor(theme.colors.text)
            
            Spacer()
            
            Text(value)
                .font(theme.fonts.subheadline)
                .foregroundColor(theme.colors.secondaryText)
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm + 4)
    }
    
    // MARK: - Logout
    
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
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel())
    }
}
#endif
