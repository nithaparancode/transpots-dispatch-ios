import SwiftUI
import TranspotsUI

struct OrdersView: View {
    @StateObject var viewModel: OrdersViewModel
    @ObservedObject var coordinator: OrdersCoordinator
    @Environment(\.theme) var theme
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ZStack {
                theme.colors.secondaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: theme.spacing.lg) {
                    AppSymbols.tabOrders
                        .font(.system(size: 60))
                        .foregroundColor(theme.colors.primary)
                    
                    Text("Orders")
                        .font(theme.fonts.title)
                        .foregroundColor(theme.colors.text)
                    
                    Text("Your orders will appear here")
                        .font(theme.fonts.subheadline)
                        .foregroundColor(theme.colors.secondaryText)
                    
                    Spacer()
                        .frame(height: theme.spacing.xl)
                    
                    Button("View Order Detail") {
                        coordinator.push(.orderDetail(id: "ORD-001"))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(theme.colors.primary)
                }
                .padding(theme.spacing.md)
            }
            .navigationTitle("Orders")
            .navigationDestination(for: OrdersRoute.self) { route in
                coordinator.view(for: route)
            }
        }
    }
}
