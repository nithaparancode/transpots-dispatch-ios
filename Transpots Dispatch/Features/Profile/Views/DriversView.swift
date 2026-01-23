import SwiftUI
import TranspotsUI

struct DriversView: View {
    @StateObject private var viewModel = DriversViewModel()
    @Environment(\.theme) var theme
    
    var body: some View {
        contentView
            .navigationTitle("Drivers")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .onAppear {
                if viewModel.state == .idle {
                    viewModel.loadDrivers()
                }
            }
            .refreshable {
                viewModel.loadDrivers()
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
        case .loaded(let drivers):
            driversList(drivers: drivers)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: theme.spacing.lg) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading drivers...")
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                viewModel.loadDrivers()
            }
            .font(theme.fonts.headline)
            .foregroundColor(.white)
            .frame(width: 140, height: 44)
            .background(theme.colors.primary)
            .cornerRadius(theme.radius.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func driversList(drivers: [Driver]) -> some View {
        ScrollView {
            VStack(spacing: theme.spacing.md) {
                if drivers.isEmpty {
                    emptyStateView
                } else {
                    ForEach(drivers) { driver in
                        driverCard(driver)
                    }
                }
            }
            .padding(theme.spacing.lg)
        }
        .background(theme.colors.background)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: theme.spacing.md) {
            AppSymbols.profileUser
                .font(.system(size: 50))
                .foregroundColor(theme.colors.secondaryText)
            
            Text("No Drivers Found")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(theme.colors.text)
            
            Text("There are no drivers available at the moment.")
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, theme.spacing.xl)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, theme.spacing.xl)
    }
    
    private func driverCard(_ driver: Driver) -> some View {
        VStack(spacing: theme.spacing.md) {
            HStack(spacing: theme.spacing.md) {
                // Driver Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [theme.colors.primary, theme.colors.primary.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: theme.colors.primary.opacity(0.3), radius: 8, y: 2)
                    
                    Text(driver.displayName.prefix(1).uppercased())
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Driver Info
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(driver.displayName)
                        .font(theme.fonts.headline)
                        .foregroundColor(theme.colors.text)
                    
                    if !driver.phone.isEmpty {
                        HStack(spacing: theme.spacing.xs) {
                            AppSymbols.commPhone
                                .font(.system(size: 12))
                                .foregroundColor(theme.colors.primary)
                            Text(driver.phone)
                                .font(theme.fonts.caption)
                                .foregroundColor(theme.colors.secondaryText)
                        }
                    }
                    
                    if let address = driver.address, !address.isEmpty {
                        HStack(spacing: theme.spacing.xs) {
                            AppSymbols.locationPin
                                .font(.system(size: 12))
                                .foregroundColor(theme.colors.primary)
                            Text(address)
                                .font(theme.fonts.caption)
                                .foregroundColor(theme.colors.secondaryText)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                // Status Indicator
                if let status = driver.driverAppStatus {
                    VStack(spacing: theme.spacing.xs) {
                        Circle()
                            .fill(status.lowercased() == "active" ? theme.colors.success : theme.colors.secondaryText)
                            .frame(width: 8, height: 8)
                        
                        Text(status.capitalized)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(status.lowercased() == "active" ? theme.colors.success : theme.colors.secondaryText)
                    }
                }
            }
            
            // Additional driver details if available
            if let licenseNumber = driver.licenseNumber, !licenseNumber.isEmpty {
                HStack {
                    AppSymbols.statusInfo
                        .font(.system(size: 12))
                        .foregroundColor(theme.colors.primary)
                    
                    Text("License: \(licenseNumber)")
                        .font(theme.fonts.caption)
                        .foregroundColor(theme.colors.secondaryText)
                    
                    Spacer()
                }
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
struct DriversView_Previews: PreviewProvider {
    static var previews: some View {
        DriversView()
    }
}
#endif
