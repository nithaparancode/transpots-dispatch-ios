import SwiftUI
import TranspotsUI

struct TripDetailView: View {
    @StateObject var viewModel: TripDetailViewModel
    @Environment(\.theme) var theme
    
    var body: some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                tripHeader
                
                driverSection
                
                if !viewModel.pickupTasks.isEmpty {
                    taskSection(title: "Pickup Tasks", tasks: viewModel.pickupTasks, icon: "arrow.up.circle.fill", color: theme.colors.success)
                }
                
                if !viewModel.deliveryTasks.isEmpty {
                    taskSection(title: "Delivery Tasks", tasks: viewModel.deliveryTasks, icon: "arrow.down.circle.fill", color: theme.colors.primary)
                }
                
                if !viewModel.hookTasks.isEmpty {
                    taskSection(title: "Hook Tasks", tasks: viewModel.hookTasks, icon: "link.circle.fill", color: .orange)
                }
                
                if !viewModel.dropTasks.isEmpty {
                    taskSection(title: "Drop Tasks", tasks: viewModel.dropTasks, icon: "link.badge.minus", color: .red)
                }
                
                allTasksSection
            }
            .padding(theme.spacing.md)
        }
        .background(theme.colors.background)
        .navigationTitle(viewModel.trip.userTripId)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var tripHeader: some View {
        SimpleCard {
            VStack(spacing: theme.spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Trip Status")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(theme.colors.secondaryText)
                            .textCase(.uppercase)
                        
                        Text(viewModel.trip.status)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(theme.colors.text)
                    }
                    
                    Spacer()
                    
                    statusBadge(viewModel.trip.status)
                }
                
                Divider()
                
                HStack {
                    infoItem(icon: "list.bullet", label: "Total Tasks", value: "\(viewModel.trip.taskCount)")
                    
                    Spacer()
                    
                    infoItem(icon: "person.fill", label: "User ID", value: String(viewModel.trip.userId.prefix(8)))
                }
            }
        }
    }
    
    private var driverSection: some View {
        SimpleCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(theme.colors.primary)
                    
                    Text("Driver Information")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(theme.colors.text)
                }
                
                Divider()
                
                VStack(spacing: theme.spacing.sm) {
                    driverRow(label: "Primary Driver", name: viewModel.trip.firstDriverName, id: viewModel.trip.firstDriverId)
                    
                    if let secondName = viewModel.trip.secondDriverName, !secondName.trimmingCharacters(in: .whitespaces).isEmpty {
                        Divider()
                        driverRow(label: "Secondary Driver", name: secondName, id: viewModel.trip.secondDriverId)
                    }
                }
            }
        }
    }
    
    private func driverRow(label: String, name: String?, id: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(theme.colors.secondaryText)
                .textCase(.uppercase)
            
            if let name = name, !name.trimmingCharacters(in: .whitespaces).isEmpty {
                Text(name.trimmingCharacters(in: .whitespaces))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.colors.text)
                
                if let id = id, !id.isEmpty {
                    Text("ID: \(id)")
                        .font(.system(size: 13))
                        .foregroundColor(theme.colors.secondaryText)
                }
            } else {
                Text("Not assigned")
                    .font(.system(size: 16))
                    .foregroundColor(theme.colors.secondaryText)
                    .italic()
            }
        }
    }
    
    private func taskSection(title: String, tasks: [TripTask], icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(theme.colors.text)
                
                Spacer()
                
                Text("\(tasks.count)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(color))
            }
            .padding(.horizontal, theme.spacing.md)
            
            ForEach(tasks) { task in
                taskCard(task)
            }
        }
    }
    
    private func taskCard(_ task: TripTask) -> some View {
        SimpleCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.displayType)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(theme.colors.text)
                        
                        Text("Sequence: \(task.sequenceId)")
                            .font(.system(size: 12))
                            .foregroundColor(theme.colors.secondaryText)
                    }
                    
                    Spacer()
                    
                    taskStatusBadge(task.status)
                }
                
                if !task.name.isEmpty {
                    infoRow(icon: "building.2", label: "Location", value: task.name)
                }
                
                if !task.address.isEmpty {
                    infoRow(icon: "mappin.circle", label: "Address", value: task.address)
                }
                
                if let formattedDate = viewModel.formatDate(task.startTime) {
                    infoRow(icon: "calendar", label: "Start Time", value: formattedDate)
                }
                
                if let estimatedTime = task.estimatedTime, let formattedEstimate = viewModel.formatDate(estimatedTime) {
                    infoRow(icon: "clock", label: "Estimated Time", value: formattedEstimate)
                }
                
                if let tractorId = task.tractorId, !tractorId.isEmpty {
                    infoRow(icon: "truck.box", label: "Tractor", value: tractorId)
                }
                
                if let trailerId = task.trailerId, !trailerId.isEmpty {
                    infoRow(icon: "trailer", label: "Trailer", value: trailerId)
                }
                
                if let orderEvent = task.orderEvent {
                    Divider()
                    orderEventDetails(orderEvent)
                }
            }
        }
    }
    
    private func orderEventDetails(_ event: TripOrderEvent) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text("Order Event Details")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(theme.colors.text)
                .textCase(.uppercase)
            
            if let loadType = event.loadType {
                infoRow(icon: "truck.box", label: "Load Type", value: loadType)
            }
            
            if let loadCount = event.loadCount {
                infoRow(icon: "number", label: "Load Count", value: "\(loadCount)")
            }
            
            if let temp = event.temperatureValue, let unit = event.temperatureUnit {
                infoRow(icon: "thermometer", label: "Temperature", value: "\(temp)°\(unit)")
            }
            
            if let weight = event.weightValue, let unit = event.weightUnit {
                infoRow(icon: "scalemass", label: "Weight", value: "\(weight) \(unit)")
            }
            
            if let hazmat = event.hazmat, !hazmat.isEmpty {
                infoRow(icon: "exclamationmark.triangle", label: "Hazmat", value: hazmat)
            }
            
            if let notes = event.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "note.text")
                            .font(.system(size: 12))
                            .foregroundColor(theme.colors.secondaryText)
                        Text("Notes")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(theme.colors.secondaryText)
                            .textCase(.uppercase)
                    }
                    Text(notes)
                        .font(.system(size: 14))
                        .foregroundColor(theme.colors.text)
                }
            }
        }
    }
    
    private var allTasksSection: some View {
        SimpleCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                Text("All Tasks Timeline")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(theme.colors.text)
                
                Divider()
                
                ForEach(Array(viewModel.sortedTasks.enumerated()), id: \.element.id) { index, task in
                    HStack(alignment: .top, spacing: theme.spacing.md) {
                        VStack {
                            Circle()
                                .fill(taskTypeColor(task.type))
                                .frame(width: 12, height: 12)
                            
                            if index < viewModel.sortedTasks.count - 1 {
                                Rectangle()
                                    .fill(theme.colors.secondaryText.opacity(0.3))
                                    .frame(width: 2)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.displayType)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(theme.colors.text)
                            
                            if !task.name.isEmpty {
                                Text(task.name)
                                    .font(.system(size: 13))
                                    .foregroundColor(theme.colors.secondaryText)
                            }
                            
                            HStack {
                                Text("Seq: \(task.sequenceId)")
                                    .font(.system(size: 11))
                                    .foregroundColor(theme.colors.secondaryText)
                                
                                taskStatusBadge(task.status)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, theme.spacing.xs)
                    
                    if index < viewModel.sortedTasks.count - 1 {
                        Divider()
                    }
                }
            }
        }
    }
    
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(theme.colors.secondaryText)
                .frame(width: 16)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(theme.colors.secondaryText)
                .textCase(.uppercase)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(theme.colors.text)
                .multilineTextAlignment(.trailing)
        }
    }
    
    private func infoItem(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(theme.colors.secondaryText)
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(theme.colors.secondaryText)
                    .textCase(.uppercase)
            }
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(theme.colors.text)
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
    
    private func taskStatusBadge(_ status: String) -> some View {
        Text(status)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(taskStatusColor(status))
            )
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status.uppercased() {
        case "ACTIVE":
            return theme.colors.success
        case "ARCHIVED":
            return theme.colors.secondaryText
        default:
            return theme.colors.primary
        }
    }
    
    private func taskStatusColor(_ status: String) -> Color {
        switch status.uppercased() {
        case "ASSIGNED":
            return .blue
        case "IN_PROGRESS":
            return .orange
        case "COMPLETED":
            return theme.colors.success
        case "CANCELLED":
            return .red
        default:
            return theme.colors.secondaryText
        }
    }
    
    private func taskTypeColor(_ type: String) -> Color {
        switch type {
        case "PICKUP":
            return theme.colors.success
        case "DELIVERY":
            return theme.colors.primary
        case "HOOK_TRACTOR", "HOOK_TRAILER":
            return .orange
        case "DROP_TRACTOR", "DROP_TRAILER":
            return .red
        default:
            return theme.colors.secondaryText
        }
    }
}

#if DEBUG
struct TripDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TripDetailView(
                viewModel: TripDetailViewModel(
                    trip: Trip(
                        tripId: 292,
                        userId: "test-user",
                        userTripId: "TRIP-0001",
                        status: "ACTIVE",
                        firstDriverName: "John Doe",
                        firstDriverId: "driver-1",
                        secondDriverName: nil,
                        secondDriverId: nil,
                        tripTasks: []
                    )
                )
            )
        }
    }
}
#endif
