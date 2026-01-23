import Foundation
import Combine

struct TripTaskItem: Identifiable, Equatable {
    let id = UUID()
    let type: String
    let name: String
    let address: String
    let orderEventId: Int?
    let tractorId: String?
    let trailerId: String?
    let startTime: String
    let estimatedTime: String?
    let orderId: String?
    var sequenceId: Int
    
    var displayType: String {
        switch type {
        case "PICKUP": return "Pickup"
        case "DELIVERY": return "Delivery"
        case "HOOK_TRACTOR": return "Hook Tractor"
        case "HOOK_TRAILER": return "Hook Trailer"
        case "DROP_TRACTOR": return "Drop Tractor"
        case "DROP_TRAILER": return "Drop Trailer"
        default: return type
        }
    }
    
    var icon: String {
        switch type {
        case "PICKUP": return "arrow.up.circle.fill"
        case "DELIVERY": return "arrow.down.circle.fill"
        case "HOOK_TRACTOR": return "link.circle.fill"
        case "HOOK_TRAILER": return "link.circle.fill"
        case "DROP_TRACTOR": return "xmark.circle.fill"
        case "DROP_TRAILER": return "xmark.circle.fill"
        default: return "circle.fill"
        }
    }
}

@MainActor
final class CreateTripViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var equipments: [Equipment] = []
    @Published var drivers: [Driver] = []
    @Published var tripTasks: [TripTaskItem] = []
    @Published var selectedDriver: Driver?
    @Published var selectedTractor: Equipment?
    @Published var selectedTrailer: Equipment?
    @Published var isLoading = false
    @Published var isCreating = false
    @Published var errorMessage: String?
    @Published var showDriverSelection = false
    
    private let orderService: OrderServiceProtocol
    private let equipmentService: EquipmentServiceProtocol
    private let driverService: DriverServiceProtocol
    private let tripService: TripServiceProtocol
    private let userId: String
    
    init(
        orderService: OrderServiceProtocol = OrderService(),
        equipmentService: EquipmentServiceProtocol = EquipmentService(),
        driverService: DriverServiceProtocol = DriverService(),
        tripService: TripServiceProtocol = TripService(),
        userId: String = ""
    ) {
        self.orderService = orderService
        self.equipmentService = equipmentService
        self.driverService = driverService
        self.tripService = tripService
        self.userId = userId
    }
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        async let ordersResult = loadOrders()
        async let equipmentsResult = loadEquipments()
        async let driversResult = loadDrivers()
        
        let _ = await (ordersResult, equipmentsResult, driversResult)
        
        isLoading = false
    }
    
    private func loadOrders() async {
        do {
            let response = try await orderService.fetchOrders(
                status: .active,
                page: 0,
                size: 100
            )
            orders = response.orders
        } catch {
            errorMessage = "Failed to load orders: \(error.localizedDescription)"
            print("❌ Failed to load orders: \(error)")
        }
    }
    
    private func loadEquipments() async {
        do {
            equipments = try await equipmentService.fetchEquipments()
        } catch {
            errorMessage = "Failed to load equipments: \(error.localizedDescription)"
            print("❌ Failed to load equipments: \(error)")
        }
    }
    
    private func loadDrivers() async {
        guard !userId.isEmpty else { return }
        
        do {
            drivers = try await driverService.fetchDrivers(userId: userId)
        } catch {
            errorMessage = "Failed to load drivers: \(error.localizedDescription)"
            print("❌ Failed to load drivers: \(error)")
        }
    }
    
    func isOrderEventAdded(_ event: OrderEvent) -> Bool {
        return tripTasks.contains { $0.orderEventId == event.orderEventId }
    }
    
    func isEquipmentAdded(_ equipment: Equipment) -> Bool {
        if equipment.equipmentType == "TRACTOR" {
            return tripTasks.contains { $0.type == "HOOK_TRACTOR" && $0.tractorId == equipment.unitNumber }
        } else if equipment.equipmentType == "TRAILER" {
            return tripTasks.contains { $0.type == "HOOK_TRAILER" && $0.trailerId == equipment.unitNumber }
        }
        return false
    }
    
    func addOrderEventToTrip(_ event: OrderEvent) {
        guard !isOrderEventAdded(event) else {
            print("⚠️ Order event already added: \(event.orderEventId)")
            return
        }
        
        let task = TripTaskItem(
            type: event.eventType,
            name: event.name,
            address: event.address,
            orderEventId: event.orderEventId,
            tractorId: selectedTractor?.unitNumber,
            trailerId: selectedTrailer?.unitNumber,
            startTime: event.startTime,
            estimatedTime: event.endTime,
            orderId: nil,
            sequenceId: tripTasks.count
        )
        tripTasks.append(task)
        reorderTasks()
    }
    
    func addEquipmentToTrip(_ equipment: Equipment) {
        guard !isEquipmentAdded(equipment) else {
            print("⚠️ Equipment already added: \(equipment.unitNumber)")
            return
        }
        
        if equipment.equipmentType == "TRACTOR" {
            selectedTractor = equipment
            addHookTractorTask(equipment)
        } else if equipment.equipmentType == "TRAILER" {
            selectedTrailer = equipment
            addHookTrailerTask(equipment)
        }
    }
    
    private func addHookTractorTask(_ equipment: Equipment) {
        let task = TripTaskItem(
            type: "HOOK_TRACTOR",
            name: equipment.unitNumber,
            address: equipment.address,
            orderEventId: nil,
            tractorId: equipment.unitNumber,
            trailerId: nil,
            startTime: ISO8601DateFormatter().string(from: Date()),
            estimatedTime: ISO8601DateFormatter().string(from: Date()),
            orderId: nil,
            sequenceId: 0
        )
        tripTasks.insert(task, at: 0)
        reorderTasks()
    }
    
    private func addHookTrailerTask(_ equipment: Equipment) {
        let hookTractorIndex = tripTasks.firstIndex(where: { $0.type == "HOOK_TRACTOR" }) ?? -1
        let insertIndex = hookTractorIndex + 1
        
        let task = TripTaskItem(
            type: "HOOK_TRAILER",
            name: equipment.unitNumber,
            address: equipment.address,
            orderEventId: nil,
            tractorId: selectedTractor?.unitNumber,
            trailerId: equipment.unitNumber,
            startTime: ISO8601DateFormatter().string(from: Date()),
            estimatedTime: ISO8601DateFormatter().string(from: Date()),
            orderId: nil,
            sequenceId: insertIndex
        )
        
        if insertIndex >= 0 && insertIndex <= tripTasks.count {
            tripTasks.insert(task, at: insertIndex)
        } else {
            tripTasks.append(task)
        }
        reorderTasks()
    }
    
    func removeTask(_ task: TripTaskItem) {
        tripTasks.removeAll { $0.id == task.id }
        reorderTasks()
    }
    
    private func reorderTasks() {
        for (index, _) in tripTasks.enumerated() {
            tripTasks[index].sequenceId = index
        }
    }
    
    func createTrip() async -> Bool {
        guard let driver = selectedDriver else {
            errorMessage = "Please select a driver"
            return false
        }
        
        guard !tripTasks.isEmpty else {
            errorMessage = "Please add at least one task"
            return false
        }
        
        isCreating = true
        errorMessage = nil
        
        var tasks = tripTasks
        
        if let trailer = selectedTrailer {
            let dropTrailerTask = TripTaskItem(
                type: "DROP_TRAILER",
                name: trailer.unitNumber,
                address: trailer.address,
                orderEventId: nil,
                tractorId: selectedTractor?.unitNumber,
                trailerId: trailer.unitNumber,
                startTime: ISO8601DateFormatter().string(from: Date()),
                estimatedTime: ISO8601DateFormatter().string(from: Date()),
                orderId: nil,
                sequenceId: tasks.count
            )
            tasks.append(dropTrailerTask)
        }
        
        if let tractor = selectedTractor {
            let dropTractorTask = TripTaskItem(
                type: "DROP_TRACTOR",
                name: tractor.unitNumber,
                address: tractor.address,
                orderEventId: nil,
                tractorId: tractor.unitNumber,
                trailerId: nil,
                startTime: ISO8601DateFormatter().string(from: Date()),
                estimatedTime: ISO8601DateFormatter().string(from: Date()),
                orderId: nil,
                sequenceId: tasks.count
            )
            tasks.append(dropTractorTask)
        }
        
        let createTasks = tasks.map { task in
            CreateTripTask(
                orderEventId: task.orderEventId,
                type: task.type,
                sequenceId: task.sequenceId,
                tractorId: task.tractorId,
                trailerId: task.trailerId,
                name: task.name,
                address: task.address,
                startTime: task.startTime,
                estimatedTime: task.estimatedTime,
                orderId: task.orderId
            )
        }
        
        let request = CreateTripRequest(
            userId: userId,
            userTripId: "",
            firstDriverName: driver.displayName,
            firstDriverId: driver.id,
            secondDriverName: " ",
            secondDriverId: "",
            tripTasks: createTasks
        )
        
        do {
            let trip = try await tripService.createTrip(request: request)
            print("✅ Trip created successfully: \(trip.userTripId)")
            isCreating = false
            return true
        } catch {
            errorMessage = "Failed to create trip: \(error.localizedDescription)"
            print("❌ Failed to create trip: \(error)")
            isCreating = false
            return false
        }
    }
}
