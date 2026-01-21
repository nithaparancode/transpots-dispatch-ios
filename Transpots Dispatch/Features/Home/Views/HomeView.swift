import SwiftUI
import TranspotsUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @ObservedObject var coordinator: HomeCoordinator
    @Environment(\.theme) var theme
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            contentView
                .background(theme.colors.background)
                .navigationTitle("Dashboard")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        refreshButton
                    }
                }
                .navigationDestination(for: HomeRoute.self) { route in
                    coordinator.view(for: route)
                }
                .onAppear {
                    if case .idle = viewModel.state {
                        viewModel.loadDashboard()
                    }
                }
        }
    }
    
    // MARK: - Content Views
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .idle:
            Color.clear
            
        case .loading:
            loadingView
            
        case .failed(let errorMessage):
            errorView(message: errorMessage)
            
        case .loaded(let dashboard):
            dashboardContent(dashboard)
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .scaleEffect(1.5)
    }
    
    private func errorView(message: String) -> some View {
        ErrorView(message: message, onRetry: {
            viewModel.loadDashboard()
        })
    }
    
    private func dashboardContent(_ dashboard: DashboardSummary) -> some View {
        ScrollView {
            VStack(spacing: theme.spacing.xl) {
                statsGrid(dashboard)
                
                if !dashboard.todayOrders.isEmpty {
                    todayOrdersSection(dashboard.todayOrders)
                }
                
                if !dashboard.todayTrips.isEmpty {
                    todayTripsSection(dashboard.todayTrips)
                }
                
                if !dashboard.recentActivity.isEmpty {
                    recentActivitySection(dashboard.recentActivity)
                }
            }
            .padding(theme.spacing.lg)
            .padding(.bottom, theme.spacing.xl)
        }
    }
    
    private func statsGrid(_ dashboard: DashboardSummary) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: theme.spacing.md) {
            StatCard(
                title: "Active Orders",
                value: "\(dashboard.activeOrders)",
                icon: AppSymbols.ordersList,
                iconColor: theme.colors.primary
            )
            
            StatCard(
                title: "Active Trips",
                value: "\(dashboard.activeTrips)",
                icon: AppSymbols.locationRoute,
                iconColor: theme.colors.accent
            )
            
            StatCard(
                title: "Pending Invoices",
                value: "\(dashboard.pendingInvoices)",
                icon: AppSymbols.ordersDetail,
                iconColor: theme.colors.warning
            )
            
            StatCard(
                title: "Equipment Available",
                value: "\(dashboard.equipmentAvailable)",
                icon: AppSymbols.launchTruck,
                iconColor: theme.colors.success
            )
        }
    }
    
    private func todayOrdersSection(_ orders: [TodayOrder]) -> some View {
        SectionCard(title: "Today's Orders") {
            VStack(spacing: theme.spacing.sm) {
                ForEach(orders) { order in
                    TodayOrderRowView(order: order)
                }
            }
        }
    }
    
    private func todayTripsSection(_ trips: [TodayTrip]) -> some View {
        SectionCard(title: "Today's Trips") {
            VStack(spacing: theme.spacing.sm) {
                ForEach(trips) { trip in
                    TripRowView(trip: trip)
                }
            }
        }
    }
    
    private func recentActivitySection(_ activities: [String]) -> some View {
        SectionCard(title: "Recent Activity") {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                ForEach(activities, id: \.self) { activity in
                    HStack(spacing: theme.spacing.md) {
                        ZStack {
                            Circle()
                                .fill(theme.colors.primary.opacity(0.1))
                                .frame(width: 36, height: 36)
                            
                            AppSymbols.statusInfo
                                .font(.system(size: 16))
                                .foregroundColor(theme.colors.primary)
                        }
                        
                        Text(activity)
                            .font(theme.fonts.subheadline)
                            .foregroundColor(theme.colors.text)
                        
                        Spacer()
                    }
                    .padding(.vertical, theme.spacing.xs)
                }
            }
        }
    }
    
    private var refreshButton: some View {
        Button(action: {
            viewModel.loadDashboard()
        }) {
            AppSymbols.actionRefresh
                .foregroundColor(theme.colors.primary)
        }
    }
}

// MARK: - Today Order Row View
struct TodayOrderRowView: View {
    @Environment(\.theme) var theme
    let order: TodayOrder
    
    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack {
                Text(order.userOrderId)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.colors.text)
                
                Spacer()
                
                Text(order.status)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.vertical, theme.spacing.xs)
                    .background(statusColor(for: order.status))
                    .cornerRadius(theme.radius.full)
            }
            
            if let firstPair = order.orderEventPairs.first {
                HStack(spacing: theme.spacing.sm) {
                    AppSymbols.locationPin
                        .font(.system(size: 14))
                        .foregroundColor(theme.colors.primary)
                    
                    Text(firstPair.pickupPlace)
                        .font(theme.fonts.subheadline)
                        .foregroundColor(theme.colors.text)
                        .lineLimit(1)
                    
                    AppSymbols.navForward
                        .font(.system(size: 12))
                        .foregroundColor(theme.colors.secondaryText)
                    
                    Text(firstPair.deliveryPlace)
                        .font(theme.fonts.subheadline)
                        .foregroundColor(theme.colors.text)
                        .lineLimit(1)
                }
            }
        }
        .padding(theme.spacing.md)
        .background(theme.colors.background)
        .cornerRadius(theme.radius.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md)
                .stroke(theme.colors.border.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.uppercased() {
        case "ASSIGNED":
            return theme.colors.primary
        case "COMPLETED":
            return theme.colors.success
        case "CANCELLED":
            return theme.colors.error
        default:
            return theme.colors.secondaryText
        }
    }
}

// MARK: - Trip Row View
struct TripRowView: View {
    @Environment(\.theme) var theme
    let trip: TodayTrip
    
    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack {
                Text(trip.userTripId)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.colors.text)
                
                Spacer()
                
                Text(trip.status)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.vertical, theme.spacing.xs)
                    .background(theme.colors.accent)
                    .cornerRadius(theme.radius.full)
            }
            
            HStack(spacing: theme.spacing.sm) {
                AppSymbols.profileUser
                    .font(.system(size: 14))
                    .foregroundColor(theme.colors.primary)
                
                Text(trip.firstDriverName)
                    .font(theme.fonts.subheadline)
                    .foregroundColor(theme.colors.text)
                    .lineLimit(1)
                
                Text("•")
                    .font(.system(size: 12))
                    .foregroundColor(theme.colors.secondaryText)
                
                Text("Order: \(trip.userOrderId)")
                    .font(theme.fonts.subheadline)
                    .foregroundColor(theme.colors.secondaryText)
                    .lineLimit(1)
            }
        }
        .padding(theme.spacing.md)
        .background(theme.colors.background)
        .cornerRadius(theme.radius.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md)
                .stroke(theme.colors.border.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Error View
struct ErrorView: View {
    @Environment(\.theme) var theme
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: theme.spacing.lg) {
            AppSymbols.statusError
                .font(.system(size: 60))
                .foregroundColor(theme.colors.error)
            
            Text("Something went wrong")
                .font(theme.fonts.title)
                .foregroundColor(theme.colors.text)
            
            Text(message)
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.secondaryText)
                .multilineTextAlignment(.center)
            
            Button(action: onRetry) {
                Text("Try Again")
                    .font(theme.fonts.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, theme.spacing.xl)
                    .padding(.vertical, theme.spacing.md)
                    .background(theme.colors.primary)
                    .cornerRadius(theme.radius.md)
            }
        }
        .padding(theme.spacing.xl)
    }
}
