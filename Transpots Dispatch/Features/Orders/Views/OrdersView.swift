import SwiftUI
import TranspotsUI

struct OrdersView: View {
    @StateObject var viewModel: OrdersViewModel
    @ObservedObject var coordinator: OrdersCoordinator
    @Environment(\.theme) var theme
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            contentView
                .background(theme.colors.background)
                .navigationTitle("Orders")
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        statusSegmentedControl
                    }
                }
                .navigationDestination(for: OrdersRoute.self) { route in
                    coordinator.view(for: route)
                }
                .onAppear {
                    viewModel.loadOrders()
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
        case .loaded(let orders):
            ordersList(orders)
        }
    }
    
    private var statusSegmentedControl: some View {
        Picker("Status", selection: $viewModel.selectedStatus) {
            Text("Active").tag(OrderStatus.active)
            Text("Archived").tag(OrderStatus.archived)
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.selectedStatus) { _, newValue in
            viewModel.switchStatus(to: newValue)
        }
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading orders...")
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.secondaryText)
                .padding(.top, theme.spacing.md)
            Spacer()
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: theme.spacing.lg) {
            Spacer()
            
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
            
            Button(action: {
                viewModel.loadOrders()
            }) {
                Text("Try Again")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 140, height: 44)
                    .background(theme.colors.primary)
                    .cornerRadius(theme.radius.md)
            }
            
            Spacer()
        }
    }
    
    private func ordersList(_ orders: [Order]) -> some View {
        Group {
            if orders.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: theme.spacing.md) {
                        ForEach(orders) { order in
                            OrderRowView(order: order) {
                                coordinator.push(.orderDetail(orderId: order.orderId))
                            }
                        }
                    }
                    .padding(theme.spacing.md)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: theme.spacing.lg) {
            Spacer()
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(theme.colors.secondaryText.opacity(0.5))
            
            Text("No \(viewModel.selectedStatus.rawValue.lowercased()) orders")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(theme.colors.text)
            
            Text("Orders will appear here when available")
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.secondaryText)
            
            Spacer()
        }
    }
}

struct OrderRowView: View {
    @Environment(\.theme) var theme
    let order: Order
    var onTap: () -> Void = {}
    
    var body: some View {
        Button(action: onTap) {
            rowContent
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var rowContent: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack {
                Text(order.userOrderId)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(theme.colors.text)
                
                Spacer()
                
                Text(order.status)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, theme.spacing.sm)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.1))
                    .cornerRadius(12)
            }
            
            Text(order.customerName)
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.secondaryText)
            
            if let firstEvent = order.orderEvents.first {
                Divider()
                    .padding(.vertical, theme.spacing.xs)
                
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    Image(systemName: eventIcon(firstEvent.eventType))
                        .font(.system(size: 14))
                        .foregroundColor(theme.colors.primary)
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(firstEvent.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(theme.colors.text)
                        
                        Text(firstEvent.address)
                            .font(.system(size: 12))
                            .foregroundColor(theme.colors.secondaryText)
                            .lineLimit(2)
                    }
                }
            }
            
            if order.orderEvents.count > 1 {
                Text("+\(order.orderEvents.count - 1) more event\(order.orderEvents.count - 1 > 1 ? "s" : "")")
                    .font(.system(size: 12))
                    .foregroundColor(theme.colors.primary)
            }
        }
        .padding(theme.spacing.md)
        .background(theme.colors.secondaryBackground)
        .cornerRadius(theme.radius.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md)
                .strokeBorder(theme.colors.border.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var statusColor: Color {
        switch order.status {
        case "ACTIVE":
            return theme.colors.success
        case "ARCHIVED":
            return theme.colors.secondaryText
        default:
            return theme.colors.primary
        }
    }
    
    private func eventIcon(_ eventType: String) -> String {
        switch eventType {
        case "PICKUP":
            return "arrow.up.circle.fill"
        case "DELIVERY":
            return "arrow.down.circle.fill"
        default:
            return "circle.fill"
        }
    }
}
