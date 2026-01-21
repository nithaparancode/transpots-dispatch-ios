import SwiftUI
import TranspotsUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @ObservedObject var coordinator: HomeCoordinator
    @Environment(\.theme) var theme
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ZStack {
                theme.colors.secondaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: theme.spacing.lg) {
                    AppSymbols.tabHome
                        .font(.system(size: 60))
                        .foregroundColor(theme.colors.primary)
                    
                    Text("Home")
                        .font(theme.fonts.title)
                        .foregroundColor(theme.colors.text)
                    
                    Text("Welcome to Transpots Dispatch")
                        .font(theme.fonts.subheadline)
                        .foregroundColor(theme.colors.secondaryText)
                    
                    Spacer()
                        .frame(height: theme.spacing.xl)
                    
                    Button("Go to Detail") {
                        coordinator.push(.detail(id: "123"))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(theme.colors.primary)
                }
                .padding(theme.spacing.md)
            }
            .navigationTitle("Home")
            .navigationDestination(for: HomeRoute.self) { route in
                coordinator.view(for: route)
            }
        }
    }
}
