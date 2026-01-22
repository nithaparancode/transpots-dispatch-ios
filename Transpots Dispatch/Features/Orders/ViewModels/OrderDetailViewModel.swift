import Foundation
import Combine

final class OrderDetailViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded(Order)
        case failed(String)
        case saving
        case saved
    }
    
    enum Tab: String, CaseIterable {
        case customer = "Customer"
        case rate = "Rate"
        case pickup = "Pickup"
        case delivery = "Delivery"
        case notes = "Notes"
    }
    
    @Published var state: ViewState = .idle
    @Published var selectedTab: Tab = .customer
    @Published var isEditMode: Bool = false
    @Published var editableOrder: Order?
    
    // Editable fields - Customer & Rate
    @Published var customerName: String = ""
    @Published var loadNumber: String = ""
    @Published var billingEmail: String = ""
    @Published var notificationEmail: String = ""
    @Published var accountPayableEmail: String = ""
    @Published var currency: String = "CAD"
    @Published var baseRate: String = ""
    @Published var detentionCharges: String = ""
    @Published var layoverCharges: String = ""
    @Published var fuelSurcharge: String = ""
    @Published var otherCharges: String = ""
    @Published var notes: String = ""
    
    // Editable fields - Pickup Event
    @Published var pickupCompanyName: String = ""
    @Published var pickupAddress: String = ""
    @Published var pickupLoadType: String = ""
    @Published var pickupLoadCount: String = ""
    @Published var pickupTemperature: String = ""
    @Published var pickupHazmat: String = ""
    @Published var pickupNumber: String = ""
    @Published var pickupWeight: String = ""
    @Published var pickupNotes: String = ""
    
    // Editable fields - Delivery Event
    @Published var deliveryCompanyName: String = ""
    @Published var deliveryAddress: String = ""
    @Published var deliveryLoadType: String = ""
    @Published var deliveryLoadCount: String = ""
    @Published var deliveryTemperature: String = ""
    @Published var deliveryHazmat: String = ""
    @Published var deliveryNumber: String = ""
    @Published var deliveryWeight: String = ""
    @Published var deliveryNotes: String = ""
    
    private var currentTask: Task<Void, Never>?
    private let orderService: OrderServiceProtocol
    let orderId: Int
    
    init(orderId: Int, orderService: OrderServiceProtocol) {
        self.orderId = orderId
        self.orderService = orderService
    }
    
    func loadOrderDetail() {
        currentTask?.cancel()
        state = .loading
        
        currentTask = Task { @MainActor in
            do {
                let order = try await orderService.getOrderDetail(orderId: orderId)
                self.editableOrder = order
                self.loadEditableFields(from: order)
                self.state = .loaded(order)
            } catch {
                self.state = .failed(error.localizedDescription)
            }
        }
    }
    
    private func loadEditableFields(from order: Order) {
        // Customer & Rate fields
        customerName = order.customerName
        loadNumber = order.loadNumber ?? ""
        billingEmail = order.billingEmail ?? ""
        notificationEmail = order.notificationEmail ?? ""
        accountPayableEmail = order.accountPayableEmail ?? ""
        currency = order.currency ?? "CAD"
        baseRate = order.baseRate != nil ? "\(Int(order.baseRate!))" : ""
        detentionCharges = order.detentionCharges != nil ? "\(Int(order.detentionCharges!))" : ""
        layoverCharges = order.layoverCharges != nil ? "\(Int(order.layoverCharges!))" : ""
        fuelSurcharge = order.fuelSurcharge != nil ? "\(Int(order.fuelSurcharge!))" : ""
        otherCharges = order.otherCharges != nil ? "\(Int(order.otherCharges!))" : ""
        notes = order.notes ?? ""
        
        // Pickup event fields
        if let pickupEvent = order.orderEvents.first(where: { $0.eventType == "PICKUP" }) {
            pickupCompanyName = pickupEvent.name
            pickupAddress = pickupEvent.address
            pickupLoadType = pickupEvent.loadType ?? ""
            pickupLoadCount = pickupEvent.loadCount != nil ? "\(pickupEvent.loadCount!)" : ""
            pickupTemperature = pickupEvent.temperatureValue != nil ? "\(Int(pickupEvent.temperatureValue!))" : ""
            pickupHazmat = pickupEvent.hazmat ?? ""
            pickupNumber = pickupEvent.pickupNumber ?? ""
            pickupWeight = pickupEvent.weightValue != nil ? "\(Int(pickupEvent.weightValue!))" : ""
            pickupNotes = pickupEvent.notes ?? ""
        }
        
        // Delivery event fields
        if let deliveryEvent = order.orderEvents.first(where: { $0.eventType == "DELIVERY" }) {
            deliveryCompanyName = deliveryEvent.name
            deliveryAddress = deliveryEvent.address
            deliveryLoadType = deliveryEvent.loadType ?? ""
            deliveryLoadCount = deliveryEvent.loadCount != nil ? "\(deliveryEvent.loadCount!)" : ""
            deliveryTemperature = deliveryEvent.temperatureValue != nil ? "\(Int(deliveryEvent.temperatureValue!))" : ""
            deliveryHazmat = deliveryEvent.hazmat ?? ""
            deliveryNumber = deliveryEvent.pickupNumber ?? ""
            deliveryWeight = deliveryEvent.weightValue != nil ? "\(Int(deliveryEvent.weightValue!))" : ""
            deliveryNotes = deliveryEvent.notes ?? ""
        }
    }
    
    func toggleEditMode() {
        isEditMode.toggle()
        if !isEditMode, case .loaded(let order) = state {
            editableOrder = order
        }
    }
    
    func saveOrder() {
        guard let originalOrder = editableOrder else { return }
        
        // Build updated order from editable fields
        let updatedOrder = Order(
            orderId: originalOrder.orderId,
            userOrderId: originalOrder.userOrderId,
            status: originalOrder.status,
            loadNumber: loadNumber.isEmpty ? nil : loadNumber,
            companyId: originalOrder.companyId,
            customerId: originalOrder.customerId,
            customerName: customerName,
            notificationEmail: notificationEmail.isEmpty ? nil : notificationEmail,
            billingEmail: billingEmail.isEmpty ? nil : billingEmail,
            baseRate: Double(baseRate),
            detentionCharges: Double(detentionCharges),
            layoverCharges: Double(layoverCharges),
            fuelSurcharge: Double(fuelSurcharge),
            otherCharges: Double(otherCharges),
            notes: notes.isEmpty ? nil : notes,
            accountPayableEmail: accountPayableEmail.isEmpty ? nil : accountPayableEmail,
            currency: currency.isEmpty ? nil : currency,
            orderEvents: originalOrder.orderEvents,
            exceptions: originalOrder.exceptions
        )
        
        currentTask?.cancel()
        state = .saving
        
        currentTask = Task { @MainActor in
            do {
                let savedOrder = try await orderService.updateOrder(updatedOrder)
                self.editableOrder = savedOrder
                self.loadEditableFields(from: savedOrder)
                self.state = .saved
                self.isEditMode = false
                
                try? await Task.sleep(nanoseconds: 500_000_000)
                self.state = .loaded(savedOrder)
            } catch {
                self.state = .failed(error.localizedDescription)
            }
        }
    }
    
    func cancelEdit() {
        if case .loaded(let order) = state {
            editableOrder = order
            loadEditableFields(from: order)
        }
        isEditMode = false
    }
    
    deinit {
        currentTask?.cancel()
    }
}
