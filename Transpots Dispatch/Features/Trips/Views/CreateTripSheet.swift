import SwiftUI
import TranspotsUI

struct CreateTripSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.theme) var theme
    @StateObject private var viewModel: CreateTripViewModel
    
    init() {
        let userId = TokenManager.shared.userId ?? ""
        _viewModel = StateObject(wrappedValue: CreateTripViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: theme.spacing.lg) {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        tripTasksSection
                        
                        ordersSection
                        equipmentsSection
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(theme.colors.error)
                            .font(theme.fonts.caption)
                            .padding()
                    }
                }
                .padding(theme.spacing.md)
            }
            .background(theme.colors.background)
            .navigationTitle("Create Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .task {
                await viewModel.loadData()
            }
            .sheet(isPresented: $viewModel.showDriverSelection) {
                driverSelectionSheet
            }
        }
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button(viewModel.isCreating ? "Creating..." : "Create Trip") {
                createTrip()
            }
            .fontWeight(.semibold)
            .disabled(viewModel.isCreating || viewModel.selectedDriver == nil || viewModel.tripTasks.isEmpty)
        }
    }
    
    // MARK: - Driver Selection
    
    private var driverSelectionSheet: some View {
        NavigationStack {
            List(viewModel.drivers) { driver in
                driverRow(driver)
            }
            .navigationTitle("Select Driver")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.showDriverSelection = false
                    }
                }
            }
        }
    }
    
    private func driverRow(_ driver: Driver) -> some View {
        Button(action: {
            viewModel.selectedDriver = driver
            viewModel.showDriverSelection = false
        }) {
            HStack {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(driver.displayName)
                        .font(theme.fonts.headline)
                        .foregroundColor(theme.colors.text)
                    
                    Text(driver.phone)
                        .font(theme.fonts.caption)
                        .foregroundColor(theme.colors.secondaryText)
                }
                
                Spacer()
                
                if viewModel.selectedDriver?.id == driver.id {
                    AppSymbols.actionCheckmark
                        .foregroundColor(theme.colors.primary)
                }
            }
        }
    }
    
    // MARK: - Trip Tasks Section
    
    private var tripTasksSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack {
                Text("Trip Tasks (\(viewModel.tripTasks.count))")
                    .font(theme.fonts.title3)
                    .foregroundColor(theme.colors.text)
                
                Spacer()
                
                Button(action: {
                    viewModel.showDriverSelection = true
                }) {
                    HStack(spacing: theme.spacing.xs) {
                        AppSymbols.tripDriver
                            .foregroundColor(theme.colors.primary)
                        
                        if let driver = viewModel.selectedDriver {
                            Text(driver.displayName)
                                .font(theme.fonts.caption)
                                .foregroundColor(theme.colors.text)
                                .lineLimit(1)
                        } else {
                            Text("Select Driver")
                                .font(theme.fonts.caption)
                                .foregroundColor(theme.colors.secondaryText)
                        }
                        
                        AppSymbols.chevronDown
                            .font(.system(size: 10))
                            .foregroundColor(theme.colors.secondaryText)
                    }
                    .padding(.horizontal, theme.spacing.sm)
                    .padding(.vertical, theme.spacing.xs)
                    .background(theme.colors.secondaryBackground)
                    .cornerRadius(theme.radius.sm)
                }
            }
            
            if viewModel.tripTasks.isEmpty {
                VStack(spacing: theme.spacing.sm) {
                    AppSymbols.tripTasks
                        .font(.system(size: 40))
                        .foregroundColor(theme.colors.secondaryText)
                    
                    Text("No tasks added yet")
                        .font(theme.fonts.body)
                        .foregroundColor(theme.colors.secondaryText)
                    
                    Text("Add equipment and order events below")
                        .font(theme.fonts.caption)
                        .foregroundColor(theme.colors.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(theme.spacing.xl)
            } else {
                ForEach(viewModel.tripTasks) { task in
                    HStack(spacing: theme.spacing.md) {
                        Text("\(task.sequenceId + 1)")
                            .font(theme.fonts.caption)
                            .foregroundColor(theme.colors.secondaryText)
                            .frame(width: 24)
                        
                        Image(systemName: task.icon)
                            .foregroundColor(theme.colors.primary)
                        
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            Text(task.displayType)
                                .font(theme.fonts.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(theme.colors.text)
                            
                            Text(task.name)
                                .font(theme.fonts.caption)
                                .foregroundColor(theme.colors.secondaryText)
                            
                            if !task.address.isEmpty {
                                Text(task.address)
                                    .font(theme.fonts.caption)
                                    .foregroundColor(theme.colors.secondaryText)
                                    .lineLimit(1)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.removeTask(task)
                        }) {
                            AppSymbols.actionRemoveCircle
                                .foregroundColor(theme.colors.error)
                        }
                    }
                    .padding(theme.spacing.sm)
                    .background(theme.colors.secondaryBackground)
                    .cornerRadius(theme.radius.md)
                }
            }
        }
        .padding(theme.spacing.md)
        .background(theme.colors.secondaryBackground.opacity(0.5))
        .cornerRadius(theme.radius.lg)
    }
    
    // MARK: - Orders Section
    
    private var ordersSection: some View {
        let ordersWithNewEvents = viewModel.orders.filter { order in
            order.orderEvents.contains { $0.status == "NEW" }
        }
        
        return ExpandableView(
            leadingContent: {
                HStack {
                    Text("Orders")
                        .font(theme.fonts.title3)
                        .foregroundColor(theme.colors.text)
                    
                    Spacer()
                    
                    Text("\(ordersWithNewEvents.count)")
                        .font(theme.fonts.caption)
                        .foregroundColor(theme.colors.secondaryText)
                        .padding(.horizontal, theme.spacing.sm)
                        .padding(.vertical, theme.spacing.xs)
                        .background(theme.colors.secondaryBackground)
                        .cornerRadius(theme.radius.sm)
                }
            },
            expandedContent: {
                VStack(spacing: theme.spacing.md) {
                    ForEach(ordersWithNewEvents) { order in
                        orderCard(order)
                    }
                }
                .padding(.top, theme.spacing.md)
            }
        )
        .padding(theme.spacing.md)
        .background(theme.colors.secondaryBackground)
        .cornerRadius(theme.radius.lg)
    }
    
    // MARK: - Equipments Section
    
    private var equipmentsSection: some View {
        ExpandableView(
            leadingContent: {
                HStack {
                    Text("Equipments")
                        .font(theme.fonts.title3)
                        .foregroundColor(theme.colors.text)
                    
                    Spacer()
                    
                    Text("\(viewModel.equipments.count)")
                        .font(theme.fonts.caption)
                        .foregroundColor(theme.colors.secondaryText)
                        .padding(.horizontal, theme.spacing.sm)
                        .padding(.vertical, theme.spacing.xs)
                        .background(theme.colors.secondaryBackground)
                        .cornerRadius(theme.radius.sm)
                }
            },
            expandedContent: {
                VStack(spacing: theme.spacing.md) {
                    ForEach(viewModel.equipments) { equipment in
                        equipmentCard(equipment)
                    }
                }
                .padding(.top, theme.spacing.md)
            }
        )
        .padding(theme.spacing.md)
        .background(theme.colors.secondaryBackground)
        .cornerRadius(theme.radius.lg)
    }
    
    private func orderCard(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(order.userOrderId)
                        .font(theme.fonts.headline)
                        .foregroundColor(theme.colors.text)
                    
                    Text(order.customerName)
                        .font(theme.fonts.caption)
                        .foregroundColor(theme.colors.secondaryText)
                }
                
                Spacer()
            }
            
            Divider()
            
            ForEach(order.orderEvents.filter { $0.status == "NEW" }) { event in
                orderEventRow(event)
            }
        }
        .padding(theme.spacing.md)
        .background(theme.colors.background)
        .cornerRadius(theme.radius.md)
    }
    
    private func orderEventRow(_ event: OrderEvent) -> some View {
        let isAdded = viewModel.isOrderEventAdded(event)
        
        return HStack(alignment: .top, spacing: theme.spacing.md) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack {
                    (event.eventType == "PICKUP" ? AppSymbols.tripPickup : AppSymbols.tripDelivery)
                        .foregroundColor(event.eventType == "PICKUP" ? theme.colors.primary : theme.colors.success)
                    
                    Text(event.eventType == "PICKUP" ? "Pickup" : "Delivery")
                        .font(theme.fonts.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(isAdded ? theme.colors.secondaryText : theme.colors.text)
                    
                    Text(event.status)
                        .font(theme.fonts.caption)
                        .foregroundColor(theme.colors.secondaryText)
                        .padding(.horizontal, theme.spacing.sm)
                        .padding(.vertical, theme.spacing.xs)
                        .background(theme.colors.secondaryBackground)
                        .cornerRadius(theme.radius.sm)
                }
                
                Text(event.name)
                    .font(theme.fonts.body)
                    .foregroundColor(isAdded ? theme.colors.secondaryText : theme.colors.text)
                
                Text(event.address)
                    .font(theme.fonts.caption)
                    .foregroundColor(theme.colors.secondaryText)
                
                if let startTime = formatDate(event.startTime) {
                    HStack {
                        AppSymbols.timeClock
                            .font(.system(size: 12))
                            .foregroundColor(theme.colors.secondaryText)
                        Text(startTime)
                            .font(theme.fonts.caption)
                            .foregroundColor(theme.colors.secondaryText)
                    }
                }
            }
            
            Spacer()
            
            if isAdded {
                AppSymbols.actionCheckmark
                    .font(.system(size: 24))
                    .foregroundColor(theme.colors.success)
            } else {
                Button(action: {
                    viewModel.addOrderEventToTrip(event)
                }) {
                    AppSymbols.actionAddCircle
                        .font(.system(size: 24))
                        .foregroundColor(theme.colors.primary)
                }
            }
        }
        .padding(theme.spacing.sm)
        .background(theme.colors.secondaryBackground.opacity(isAdded ? 0.3 : 0.5))
        .cornerRadius(theme.radius.sm)
        .opacity(isAdded ? 0.6 : 1.0)
    }
    
    private func equipmentCard(_ equipment: Equipment) -> some View {
        let isAdded = viewModel.isEquipmentAdded(equipment)
        
        return HStack(spacing: theme.spacing.md) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(equipment.unitNumber)
                    .font(theme.fonts.headline)
                    .foregroundColor(isAdded ? theme.colors.secondaryText : theme.colors.text)
                
                Text(equipment.displayType)
                    .font(theme.fonts.caption)
                    .foregroundColor(theme.colors.secondaryText)
            }
            
            Spacer()
            
            if isAdded {
                AppSymbols.actionCheckmark
                    .font(.system(size: 24))
                    .foregroundColor(theme.colors.success)
            } else {
                Button(action: {
                    viewModel.addEquipmentToTrip(equipment)
                }) {
                    AppSymbols.actionAddCircle
                        .font(.system(size: 24))
                        .foregroundColor(theme.colors.primary)
                }
            }
        }
        .padding(theme.spacing.md)
        .background(theme.colors.background)
        .cornerRadius(theme.radius.md)
        .opacity(isAdded ? 0.6 : 1.0)
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ dateString: String) -> String? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: dateString) else {
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: dateString) else {
                return nil
            }
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
    
    // MARK: - Actions
    
    private func createTrip() {
        Task {
            let success = await viewModel.createTrip()
            if success {
                dismiss()
            }
        }
    }
}

#if DEBUG
struct CreateTripSheet_Previews: PreviewProvider {
    static var previews: some View {
        CreateTripSheet()
    }
}
#endif
