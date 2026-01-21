import SwiftUI
import TranspotsUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @ObservedObject var coordinator: ProfileCoordinator
    @Environment(\.theme) var theme
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ZStack {
                theme.colors.secondaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: theme.spacing.lg) {
                    AppSymbols.tabProfile
                        .font(.system(size: 60))
                        .foregroundColor(theme.colors.primary)
                    
                    Text("Profile")
                        .font(theme.fonts.title)
                        .foregroundColor(theme.colors.text)
                    
                    Text("Your profile information")
                        .font(theme.fonts.subheadline)
                        .foregroundColor(theme.colors.secondaryText)
                    
                    Spacer()
                        .frame(height: theme.spacing.xl)
                    
                    Button("Edit Profile") {
                        coordinator.push(.editProfile)
                    }
                    .buttonStyle(.bordered)
                    .tint(theme.colors.primary)
                    
                    Button("Settings") {
                        coordinator.push(.settings)
                    }
                    .buttonStyle(.bordered)
                    .tint(theme.colors.primary)
                    
                    Spacer()
                        .frame(height: theme.spacing.lg)
                    
                    Button(action: {
                        viewModel.logout()
                    }) {
                        Text("Logout")
                            .font(theme.fonts.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(theme.spacing.md)
                            .background(theme.colors.error)
                            .cornerRadius(theme.radius.md)
                    }
                    .padding(.horizontal, theme.spacing.xl)
                }
                .padding(theme.spacing.md)
            }
            .navigationTitle("Profile")
            .navigationDestination(for: ProfileRoute.self) { route in
                coordinator.view(for: route)
            }
        }
    }
}
