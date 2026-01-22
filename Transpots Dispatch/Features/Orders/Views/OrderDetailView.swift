import SwiftUI
import TranspotsUI

struct OrderDetailView: View {
    @StateObject var viewModel: OrderDetailViewModel
    @Environment(\.theme) var theme
    
    var body: some View {
        contentView
            .navigationTitle(viewModel.editableOrder?.userOrderId ?? "Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isEditMode {
                        HStack(spacing: 12) {
                            Button("Cancel") {
                                viewModel.cancelEdit()
                            }
                            .foregroundColor(theme.colors.secondaryText)
                            
                            Button("Save") {
                                viewModel.saveOrder()
                            }
                            .fontWeight(.semibold)
                            .foregroundColor(theme.colors.primary)
                        }
                    } else {
                        Button("Edit Order") {
                            viewModel.toggleEditMode()
                        }
                        .foregroundColor(theme.colors.primary)
                    }
                }
            }
            .onAppear {
                if case .idle = viewModel.state {
                    viewModel.loadOrderDetail()
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
        case .loaded(let order):
            orderDetailContent(order)
        case .saving:
            if let order = viewModel.editableOrder {
                orderDetailContent(order)
            }
        case .saved:
            if let order = viewModel.editableOrder {
                orderDetailContent(order)
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading order...")
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
                viewModel.loadOrderDetail()
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 140, height: 44)
            .background(theme.colors.primary)
            .cornerRadius(theme.radius.md)
        }
    }
    
    private func orderDetailContent(_ order: Order) -> some View {
        ZStack {
            theme.colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                orderHeader(order)
                
                tabBar
                
                ScrollView {
                    VStack(spacing: theme.spacing.lg) {
                        tabContent
                            .padding(.horizontal, theme.spacing.md)
                        
                        trackingSection(order)
                            .padding(.horizontal, theme.spacing.md)
                    }
                    .padding(.vertical, theme.spacing.lg)
                }
                
                if !viewModel.isEditMode {
                    bottomButtons
                }
            }
        }
    }
    
    private func orderHeader(_ order: Order) -> some View {
        VStack(spacing: theme.spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.userOrderId)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(theme.colors.text)
                    
                    Text(order.customerName)
                        .font(.system(size: 15))
                        .foregroundColor(theme.colors.secondaryText)
                }
                
                Spacer()
                
                statusBadge(order.status)
            }
            .padding(theme.spacing.lg)
            .background(
                LinearGradient(
                    colors: [theme.colors.primary.opacity(0.08), theme.colors.primary.opacity(0.02)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
    
    private func statusBadge(_ status: String) -> some View {
        Text(status)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(statusColor(status))
            )
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status {
        case "ACTIVE": return theme.colors.success
        case "COMPLETED": return theme.colors.primary
        case "CANCELLED": return theme.colors.error
        default: return theme.colors.secondaryText
        }
    }
    
    private var tabBar: some View {
        TabBar(
            selectedTab: Binding(
                get: { viewModel.selectedTab.rawValue },
                set: { newValue in
                    if let tab = OrderDetailViewModel.Tab(rawValue: newValue) {
                        viewModel.selectedTab = tab
                    }
                }
            ),
            items: OrderDetailViewModel.Tab.allCases.map { tab in
                TabBarItem(id: tab.rawValue, title: tab.rawValue)
            },
            style: .modern
        )
    }
    
    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.selectedTab {
        case .customer:
            CustomerTabView(viewModel: viewModel, isEditMode: viewModel.isEditMode)
        case .rate:
            RateTabView(viewModel: viewModel, isEditMode: viewModel.isEditMode)
        case .pickup:
            if let pickupEvent = viewModel.editableOrder?.orderEvents.first(where: { $0.eventType == "PICKUP" }) {
                EventTabView(viewModel: viewModel, event: pickupEvent, isEditMode: viewModel.isEditMode, eventType: "Pickup")
            }
        case .delivery:
            if let deliveryEvent = viewModel.editableOrder?.orderEvents.first(where: { $0.eventType == "DELIVERY" }) {
                EventTabView(viewModel: viewModel, event: deliveryEvent, isEditMode: viewModel.isEditMode, eventType: "Delivery")
            }
        case .notes:
            NotesTabView(viewModel: viewModel, isEditMode: viewModel.isEditMode)
        }
    }
    
    private var bottomButtons: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: theme.spacing.md) {
                Button(action: {
                    // Delete action
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Delete")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(theme.colors.error)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(theme.colors.error.opacity(0.1))
                    .cornerRadius(theme.radius.lg)
                }
                
                Button(action: {
                    viewModel.toggleEditMode()
                }) {
                    HStack {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Edit Order")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [theme.colors.primary, theme.colors.primary.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(theme.radius.lg)
                    .shadow(color: theme.colors.primary.opacity(0.3), radius: 8, y: 4)
                }
            }
            .padding(theme.spacing.lg)
            .background(theme.colors.background)
        }
    }
    
    private func trackingSection(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            HStack {
                Image(systemName: "map")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(theme.colors.primary)
                Text("Shipment Tracking")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(theme.colors.text)
            }
            
            VStack(spacing: theme.spacing.md) {
                ForEach(Array(order.orderEvents.enumerated()), id: \.element.id) { index, event in
                    HStack(alignment: .top, spacing: 0) {
                        VStack(spacing: 0) {
                            ZStack {
                                Circle()
                                    .fill(event.status == "COMPLETED" ? theme.colors.success : theme.colors.secondaryText.opacity(0.3))
                                    .frame(width: 32, height: 32)
                                
                                if event.status == "COMPLETED" {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                } else {
                                    Circle()
                                        .fill(theme.colors.secondaryText)
                                        .frame(width: 12, height: 12)
                                }
                            }
                            
                            if index < order.orderEvents.count - 1 {
                                Rectangle()
                                    .fill(theme.colors.border)
                                    .frame(width: 2)
                                    .frame(height: 60)
                            }
                        }
                        .frame(width: 32)
                        
                        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(event.eventType.capitalized)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(theme.colors.text)
                                    
                                    Text(event.name)
                                        .font(.system(size: 14))
                                        .foregroundColor(theme.colors.secondaryText)
                                    
                                    if let date = formatDate(event.startTime) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "clock")
                                                .font(.system(size: 12))
                                            Text(date)
                                                .font(.system(size: 13))
                                        }
                                        .foregroundColor(theme.colors.secondaryText)
                                    }
                                }
                                
                                Spacer()
                                
                                if event.status == "COMPLETED" {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(theme.colors.success)
                                }
                            }
                            
                            if event.status != "COMPLETED" {
                                Button(action: {}) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Mark As \(event.eventType == "PICKUP" ? "Picked Up" : "Delivered")")
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        LinearGradient(
                                            colors: [theme.colors.primary, theme.colors.primary.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(theme.radius.lg)
                                    .shadow(color: theme.colors.primary.opacity(0.3), radius: 4, y: 2)
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(.leading, theme.spacing.md)
                        .padding(.vertical, 4)
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
    
    private func formatDate(_ dateString: String) -> String? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        
        guard let date = formatter.date(from: dateString) else { return nil }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM d, yyyy hh:mm a"
        return displayFormatter.string(from: date)
    }
}

// MARK: - Customer Tab
struct CustomerTabView: View {
    @ObservedObject var viewModel: OrderDetailViewModel
    let isEditMode: Bool
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            sectionCard {
                VStack(spacing: theme.spacing.lg) {
                    ModernFormField(
                        label: "Customer Name",
                        value: $viewModel.customerName,
                        isEditMode: isEditMode,
                        icon: "person.fill",
                        placeholder: "Enter customer name"
                    )
                    ModernFormField(
                        label: "Load Number",
                        value: $viewModel.loadNumber,
                        isEditMode: isEditMode,
                        icon: "number",
                        placeholder: "Enter load number"
                    )
                }
            }
            
            sectionCard {
                VStack(spacing: theme.spacing.lg) {
                    ModernFormField(
                        label: "Invoice & POD Email",
                        value: $viewModel.billingEmail,
                        isEditMode: isEditMode,
                        icon: "envelope.fill",
                        placeholder: "billing@example.com",
                        keyboardType: .emailAddress
                    )
                    ModernFormField(
                        label: "Notification Email",
                        value: $viewModel.notificationEmail,
                        isEditMode: isEditMode,
                        icon: "bell.fill",
                        placeholder: "notifications@example.com",
                        keyboardType: .emailAddress
                    )
                    ModernFormField(
                        label: "AP Email",
                        value: $viewModel.accountPayableEmail,
                        isEditMode: isEditMode,
                        icon: "dollarsign.circle.fill",
                        placeholder: "ap@example.com",
                        keyboardType: .emailAddress
                    )
                }
            }
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
}

// MARK: - Rate Tab
struct RateTabView: View {
    @ObservedObject var viewModel: OrderDetailViewModel
    let isEditMode: Bool
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            sectionCard {
                VStack(spacing: theme.spacing.lg) {
                    ModernFormField(
                        label: "Currency",
                        value: $viewModel.currency,
                        isEditMode: isEditMode,
                        icon: "dollarsign.circle",
                        placeholder: "CAD"
                    )
                    ModernFormField(
                        label: "Base Rate",
                        value: $viewModel.baseRate,
                        isEditMode: isEditMode,
                        prefix: "$",
                        icon: "banknote",
                        placeholder: "0",
                        keyboardType: .numberPad
                    )
                }
            }
            
            sectionCard {
                VStack(spacing: theme.spacing.lg) {
                    ModernFormField(
                        label: "Detention Charges",
                        value: $viewModel.detentionCharges,
                        isEditMode: isEditMode,
                        prefix: "$",
                        icon: "clock.fill",
                        placeholder: "0",
                        keyboardType: .numberPad
                    )
                    ModernFormField(
                        label: "Layover Charges",
                        value: $viewModel.layoverCharges,
                        isEditMode: isEditMode,
                        prefix: "$",
                        icon: "bed.double.fill",
                        placeholder: "0",
                        keyboardType: .numberPad
                    )
                    ModernFormField(
                        label: "Fuel Surcharge",
                        value: $viewModel.fuelSurcharge,
                        isEditMode: isEditMode,
                        prefix: "$",
                        icon: "fuelpump.fill",
                        placeholder: "0",
                        keyboardType: .numberPad
                    )
                    ModernFormField(
                        label: "Other Charges",
                        value: $viewModel.otherCharges,
                        isEditMode: isEditMode,
                        prefix: "$",
                        icon: "plus.circle.fill",
                        placeholder: "0",
                        keyboardType: .numberPad
                    )
                }
            }
            
            totalCard
        }
    }
    
    private var totalCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Total Amount")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.colors.secondaryText)
                
                Text("$\(calculateTotal())")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(theme.colors.text)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 40))
                .foregroundColor(theme.colors.success.opacity(0.3))
        }
        .padding(theme.spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.xl)
                .fill(
                    LinearGradient(
                        colors: [theme.colors.primary.opacity(0.1), theme.colors.primary.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
        )
    }
    
    private func calculateTotal() -> Int {
        let base = Int(viewModel.baseRate) ?? 0
        let detention = Int(viewModel.detentionCharges) ?? 0
        let layover = Int(viewModel.layoverCharges) ?? 0
        let fuel = Int(viewModel.fuelSurcharge) ?? 0
        let other = Int(viewModel.otherCharges) ?? 0
        return base + detention + layover + fuel + other
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
}

// MARK: - Event Tab
struct EventTabView: View {
    @ObservedObject var viewModel: OrderDetailViewModel
    let event: OrderEvent
    let isEditMode: Bool
    let eventType: String
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            sectionCard {
                VStack(spacing: theme.spacing.lg) {
                    if let date = formatDate(event.startTime) {
                        ReadOnlyFormField(
                            label: "\(eventType) Date",
                            value: date,
                            icon: "calendar"
                        )
                    }
                    
                    if eventType == "Pickup" {
                        ModernFormField(
                            label: "\(eventType) Company Name",
                            value: $viewModel.pickupCompanyName,
                            isEditMode: isEditMode,
                            icon: "building.2",
                            placeholder: "Enter company name"
                        )
                        ModernFormField(
                            label: "\(eventType) Company Address",
                            value: $viewModel.pickupAddress,
                            isEditMode: isEditMode,
                            icon: "mappin.circle",
                            placeholder: "Enter address"
                        )
                    } else {
                        ModernFormField(
                            label: "\(eventType) Company Name",
                            value: $viewModel.deliveryCompanyName,
                            isEditMode: isEditMode,
                            icon: "building.2",
                            placeholder: "Enter company name"
                        )
                        ModernFormField(
                            label: "\(eventType) Company Address",
                            value: $viewModel.deliveryAddress,
                            isEditMode: isEditMode,
                            icon: "mappin.circle",
                            placeholder: "Enter address"
                        )
                    }
                }
            }
            
            sectionCard {
                VStack(spacing: theme.spacing.lg) {
                    HStack(spacing: theme.spacing.md) {
                        if eventType == "Pickup" {
                            ModernFormField(
                                label: "FTL or LTL",
                                value: $viewModel.pickupLoadType,
                                isEditMode: isEditMode,
                                icon: "truck.box",
                                placeholder: "FTL"
                            )
                            ModernFormField(
                                label: "Load Count",
                                value: $viewModel.pickupLoadCount,
                                isEditMode: isEditMode,
                                icon: "number",
                                placeholder: "0",
                                keyboardType: .numberPad
                            )
                        } else {
                            ModernFormField(
                                label: "FTL or LTL",
                                value: $viewModel.deliveryLoadType,
                                isEditMode: isEditMode,
                                icon: "truck.box",
                                placeholder: "FTL"
                            )
                            ModernFormField(
                                label: "Load Count",
                                value: $viewModel.deliveryLoadCount,
                                isEditMode: isEditMode,
                                icon: "number",
                                placeholder: "0",
                                keyboardType: .numberPad
                            )
                        }
                    }
                    
                    HStack(spacing: theme.spacing.md) {
                        if eventType == "Pickup" {
                            ModernFormField(
                                label: "Temperature",
                                value: $viewModel.pickupTemperature,
                                isEditMode: isEditMode,
                                icon: "thermometer",
                                placeholder: "0",
                                emptyText: "0°",
                                keyboardType: .numberPad
                            )
                            ModernFormField(
                                label: "Hazmat",
                                value: $viewModel.pickupHazmat,
                                isEditMode: isEditMode,
                                icon: "exclamationmark.triangle",
                                placeholder: "None"
                            )
                        } else {
                            ModernFormField(
                                label: "Temperature",
                                value: $viewModel.deliveryTemperature,
                                isEditMode: isEditMode,
                                icon: "thermometer",
                                placeholder: "0",
                                emptyText: "0°",
                                keyboardType: .numberPad
                            )
                            ModernFormField(
                                label: "Hazmat",
                                value: $viewModel.deliveryHazmat,
                                isEditMode: isEditMode,
                                icon: "exclamationmark.triangle",
                                placeholder: "None"
                            )
                        }
                    }
                    
                    HStack(spacing: theme.spacing.md) {
                        if eventType == "Pickup" {
                            ModernFormField(
                                label: "\(eventType) Number",
                                value: $viewModel.pickupNumber,
                                isEditMode: isEditMode,
                                icon: "number.circle",
                                placeholder: "Enter number"
                            )
                            ModernFormField(
                                label: "Weight",
                                value: $viewModel.pickupWeight,
                                isEditMode: isEditMode,
                                icon: "scalemass",
                                placeholder: "0",
                                emptyText: "0 lbs",
                                keyboardType: .numberPad
                            )
                        } else {
                            ModernFormField(
                                label: "\(eventType) Number",
                                value: $viewModel.deliveryNumber,
                                isEditMode: isEditMode,
                                icon: "number.circle",
                                placeholder: "Enter number"
                            )
                            ModernFormField(
                                label: "Weight",
                                value: $viewModel.deliveryWeight,
                                isEditMode: isEditMode,
                                icon: "scalemass",
                                placeholder: "0",
                                emptyText: "0 lbs",
                                keyboardType: .numberPad
                            )
                        }
                    }
                }
            }
            
            sectionCard {
                if eventType == "Pickup" {
                    ModernFormField(
                        label: "Shipment Notes",
                        value: $viewModel.pickupNotes,
                        isEditMode: isEditMode,
                        isMultiline: true,
                        icon: "note.text",
                        placeholder: "Enter shipment notes...",
                        emptyText: "No notes"
                    )
                } else {
                    ModernFormField(
                        label: "Shipment Notes",
                        value: $viewModel.deliveryNotes,
                        isEditMode: isEditMode,
                        isMultiline: true,
                        icon: "note.text",
                        placeholder: "Enter shipment notes...",
                        emptyText: "No notes"
                    )
                }
            }
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
    
    private func formatDate(_ dateString: String) -> String? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        
        guard let date = formatter.date(from: dateString) else { return nil }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM d, yyyy"
        return displayFormatter.string(from: date)
    }
}

// MARK: - Notes Tab
struct NotesTabView: View {
    @ObservedObject var viewModel: OrderDetailViewModel
    let isEditMode: Bool
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            sectionCard {
                ModernFormField(
                    label: "Order Notes",
                    value: $viewModel.notes,
                    isEditMode: isEditMode,
                    isMultiline: true,
                    icon: "note.text",
                    placeholder: "Enter order notes...",
                    emptyText: "No notes added"
                )
            }
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
}

