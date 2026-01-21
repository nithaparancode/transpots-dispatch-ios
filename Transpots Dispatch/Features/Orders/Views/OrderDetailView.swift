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
        VStack(spacing: 0) {
            tabBar
            
            ScrollView {
                VStack(spacing: theme.spacing.lg) {
                    tabContent
                    
                    Divider()
                        .padding(.vertical, theme.spacing.md)
                    
                    trackingSection(order)
                }
                .padding(theme.spacing.md)
            }
            
            if !viewModel.isEditMode {
                bottomButtons
            }
        }
        .background(theme.colors.background)
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
            style: .default
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
                EventTabView(event: pickupEvent, isEditMode: viewModel.isEditMode, eventType: "Pickup")
            }
        case .delivery:
            if let deliveryEvent = viewModel.editableOrder?.orderEvents.first(where: { $0.eventType == "DELIVERY" }) {
                EventTabView(event: deliveryEvent, isEditMode: viewModel.isEditMode, eventType: "Delivery")
            }
        case .notes:
            NotesTabView(viewModel: viewModel, isEditMode: viewModel.isEditMode)
        }
    }
    
    private var bottomButtons: some View {
        VStack(spacing: theme.spacing.sm) {
            Button(action: {
                viewModel.toggleEditMode()
            }) {
                Text("Edit Order")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(theme.colors.primary)
                    .cornerRadius(theme.radius.md)
            }
            
            Button(action: {
                // Delete action
            }) {
                Text("Delete Order")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.colors.error)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(theme.colors.error.opacity(0.1))
                    .cornerRadius(theme.radius.md)
            }
        }
        .padding(theme.spacing.md)
        .background(theme.colors.secondaryBackground)
        .shadow(color: Color.black.opacity(0.1), radius: 8, y: -4)
    }
    
    private func trackingSection(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Tracking")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(theme.colors.text)
            
            ForEach(order.orderEvents) { event in
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    HStack(alignment: .top, spacing: theme.spacing.md) {
                        ZStack {
                            Circle()
                                .fill(event.status == "COMPLETED" ? theme.colors.success.opacity(0.2) : theme.colors.secondaryText.opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            Circle()
                                .fill(event.status == "COMPLETED" ? theme.colors.success : theme.colors.secondaryText)
                                .frame(width: 12, height: 12)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(event.eventType.capitalized)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(theme.colors.text)
                            
                            Text(event.name)
                                .font(.system(size: 14))
                                .foregroundColor(theme.colors.text)
                            
                            if let date = formatDate(event.startTime) {
                                Text(date)
                                    .font(.system(size: 13))
                                    .foregroundColor(theme.colors.secondaryText)
                            }
                            
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14))
                                    Text("Mark As \(event.eventType == "PICKUP" ? "Picked Up" : "Delivered")")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, theme.spacing.md)
                                .padding(.vertical, theme.spacing.sm)
                                .background(theme.colors.primary)
                                .cornerRadius(theme.radius.md)
                            }
                            .padding(.top, 4)
                        }
                        
                        Spacer()
                    }
                    .padding(theme.spacing.md)
                    .background(theme.colors.secondaryBackground)
                    .cornerRadius(theme.radius.md)
                }
            }
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
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            EditableFormField(label: "Customer Name", value: $viewModel.customerName, isEditMode: isEditMode)
            EditableFormField(label: "Load#", value: $viewModel.loadNumber, isEditMode: isEditMode)
            EditableFormField(label: "Invoice & POD Email", value: $viewModel.billingEmail, isEditMode: isEditMode)
            EditableFormField(label: "Notification Email", value: $viewModel.notificationEmail, isEditMode: isEditMode)
            EditableFormField(label: "AP Email", value: $viewModel.accountPayableEmail, isEditMode: isEditMode)
        }
    }
}

// MARK: - Rate Tab
struct RateTabView: View {
    @ObservedObject var viewModel: OrderDetailViewModel
    let isEditMode: Bool
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            EditableFormField(label: "Currency", value: $viewModel.currency, isEditMode: isEditMode)
            EditableFormField(label: "Base Rate", value: $viewModel.baseRate, isEditMode: isEditMode, prefix: "$")
            EditableFormField(label: "Detention Charges", value: $viewModel.detentionCharges, isEditMode: isEditMode, prefix: "$")
            EditableFormField(label: "Layover Charges", value: $viewModel.layoverCharges, isEditMode: isEditMode, prefix: "$")
            EditableFormField(label: "Fuel Surcharge", value: $viewModel.fuelSurcharge, isEditMode: isEditMode, prefix: "$")
            EditableFormField(label: "Other Charges", value: $viewModel.otherCharges, isEditMode: isEditMode, prefix: "$")
        }
    }
}

// MARK: - Event Tab
struct EventTabView: View {
    let event: OrderEvent
    let isEditMode: Bool
    let eventType: String
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            if let date = formatDate(event.startTime) {
                FormField(label: "\(eventType) Date", value: date, isEditMode: isEditMode)
            }
            FormField(label: "\(eventType) Company Name", value: event.name, isEditMode: isEditMode)
            FormField(label: "\(eventType) Company Address", value: event.address, isEditMode: isEditMode)
            
            HStack(spacing: theme.spacing.md) {
                FormField(label: "FTL or LTL", value: event.loadType ?? "FTL", isEditMode: isEditMode)
                FormField(label: "Load Count", value: "\(event.loadCount ?? 0)", isEditMode: isEditMode)
            }
            
            HStack(spacing: theme.spacing.md) {
                FormField(label: "Temp", value: "\(Int(event.temperatureValue ?? 0))", isEditMode: isEditMode)
                FormField(label: "Hazmat", value: event.hazmat ?? "", isEditMode: isEditMode)
            }
            
            HStack(spacing: theme.spacing.md) {
                FormField(label: "\(eventType)#", value: event.pickupNumber ?? "", isEditMode: isEditMode)
                FormField(label: "Weight", value: "\(Int(event.weightValue ?? 0))", isEditMode: isEditMode)
            }
            
            FormField(label: "Shipment Notes", value: event.notes ?? "", isEditMode: isEditMode, isMultiline: true)
        }
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
            Text("Notes")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(theme.colors.text)
            
            if isEditMode {
                TextEditor(text: $viewModel.notes)
                    .frame(minHeight: 400)
                    .padding(theme.spacing.sm)
                    .background(theme.colors.secondaryBackground)
                    .cornerRadius(theme.radius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radius.sm)
                            .stroke(theme.colors.border, lineWidth: 1)
                    )
            } else {
                ScrollView {
                    Text(viewModel.notes.isEmpty ? "No notes" : viewModel.notes)
                        .font(.system(size: 14))
                        .foregroundColor(theme.colors.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(theme.spacing.md)
                        .background(theme.colors.secondaryBackground)
                        .cornerRadius(theme.radius.sm)
                }
            }
        }
    }
}

// MARK: - Editable Form Field Component
struct EditableFormField: View {
    let label: String
    @Binding var value: String
    let isEditMode: Bool
    var isMultiline: Bool = false
    var prefix: String = ""
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !label.isEmpty {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.colors.error)
            }
            
            if isEditMode {
                if isMultiline {
                    TextEditor(text: $value)
                        .frame(minHeight: 100)
                        .padding(theme.spacing.sm)
                        .background(theme.colors.secondaryBackground)
                        .cornerRadius(theme.radius.sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.radius.sm)
                                .stroke(theme.colors.border, lineWidth: 1)
                        )
                } else {
                    HStack {
                        if !prefix.isEmpty {
                            Text(prefix)
                                .foregroundColor(theme.colors.text)
                        }
                        TextField("", text: $value)
                    }
                    .padding(theme.spacing.md)
                    .background(theme.colors.secondaryBackground)
                    .cornerRadius(theme.radius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radius.sm)
                            .stroke(theme.colors.border, lineWidth: 1)
                    )
                }
            } else {
                let displayValue = value.isEmpty ? "-" : (prefix + value)
                Text(displayValue)
                    .font(.system(size: 15))
                    .foregroundColor(theme.colors.text)
                    .padding(theme.spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(theme.colors.secondaryBackground)
                    .cornerRadius(theme.radius.sm)
            }
        }
    }
}

// MARK: - Form Field Component (Read-only)
struct FormField: View {
    let label: String
    let value: String
    let isEditMode: Bool
    var isMultiline: Bool = false
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !label.isEmpty {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.colors.error)
            }
            
            Text(value.isEmpty ? "-" : value)
                .font(.system(size: 15))
                .foregroundColor(theme.colors.text)
                .padding(theme.spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(theme.colors.secondaryBackground)
                .cornerRadius(theme.radius.sm)
        }
    }
}
