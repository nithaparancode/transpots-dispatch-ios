import SwiftUI
import TranspotsUI

struct TripsView: View {
    @StateObject var viewModel: TripsViewModel
    @ObservedObject var coordinator: TripsCoordinator
    @Environment(\.theme) var theme
    @State private var showCreateTripSheet = false
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            contentView
                .background(theme.colors.background)
                .navigationTitle("Trips")
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        statusSegmentedControl
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showCreateTripSheet = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(theme.colors.primary)
                        }
                    }
                }
                .sheet(isPresented: $showCreateTripSheet) {
                    CreateTripSheet()
                }
                .navigationDestination(for: TripsRoute.self) { route in
                    coordinator.view(for: route)
                }
                .onAppear {
                    viewModel.loadTrips()
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
        case .loaded(let trips):
            if trips.isEmpty {
                emptyView
            } else {
                tripsList(trips)
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading trips...")
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
                viewModel.loadTrips()
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 140, height: 44)
            .background(theme.colors.primary)
            .cornerRadius(theme.radius.md)
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: theme.spacing.lg) {
            Image(systemName: "truck.box")
                .font(.system(size: 60))
                .foregroundColor(theme.colors.secondaryText.opacity(0.5))
            
            Text("No \(viewModel.selectedStatus.displayName) Trips")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(theme.colors.text)
            
            Text("There are no \(viewModel.selectedStatus.rawValue.lowercased()) trips at the moment")
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, theme.spacing.xl)
        }
    }
    
    private func tripsList(_ trips: [Trip]) -> some View {
        ScrollView {
            LazyVStack(spacing: theme.spacing.md) {
                ForEach(trips) { trip in
                    TripCard(trip: trip)
                        .onTapGesture {
                            coordinator.push(.tripDetail(trip: trip))
                        }
                }
            }
            .padding(theme.spacing.md)
        }
    }
    
    private var statusSegmentedControl: some View {
        Picker("Status", selection: $viewModel.selectedStatus) {
            ForEach(TripsViewModel.TripStatus.allCases, id: \.self) { status in
                Text(status.displayName).tag(status)
            }
        }
        .pickerStyle(.segmented)
        .frame(width: 200)
        .onChange(of: viewModel.selectedStatus) { _, newValue in
            viewModel.changeStatus(newValue)
        }
    }
}

// MARK: - Trip Card
struct TripCard: View {
    let trip: Trip
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.userTripId)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(theme.colors.text)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 12))
                            .foregroundColor(theme.colors.secondaryText)
                        Text(trip.displayDriverName)
                            .font(.system(size: 14))
                            .foregroundColor(theme.colors.secondaryText)
                    }
                }
                
                Spacer()
                
                statusBadge(trip.status)
            }
            
            Divider()
            
            if let pickupTask = trip.pickupTask {
                taskRow(
                    icon: "arrow.up.circle.fill",
                    title: "Pickup",
                    location: pickupTask.name,
                    address: pickupTask.address
                )
            }
            
            if let deliveryTask = trip.deliveryTask {
                taskRow(
                    icon: "arrow.down.circle.fill",
                    title: "Delivery",
                    location: deliveryTask.name,
                    address: deliveryTask.address
                )
            }
            
            HStack {
                Image(systemName: "list.bullet")
                    .font(.system(size: 12))
                    .foregroundColor(theme.colors.secondaryText)
                Text("\(trip.taskCount) tasks")
                    .font(.system(size: 13))
                    .foregroundColor(theme.colors.secondaryText)
            }
        }
        .padding(theme.spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.xl)
                .fill(theme.colors.secondaryBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
        )
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
        switch status.uppercased() {
        case "ACTIVE":
            return theme.colors.success
        case "ARCHIVED":
            return theme.colors.secondaryText
        default:
            return theme.colors.primary
        }
    }
    
    private func taskRow(icon: String, title: String, location: String, address: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(theme.colors.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.colors.secondaryText)
                    .textCase(.uppercase)
                
                Text(location)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(theme.colors.text)
                
                if !address.isEmpty {
                    Text(address)
                        .font(.system(size: 13))
                        .foregroundColor(theme.colors.secondaryText)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
    }
}

#if DEBUG
struct TripsView_Previews: PreviewProvider {
    static var previews: some View {
        TripsView(
            viewModel: TripsViewModel(),
            coordinator: TripsCoordinator()
        )
    }
}
#endif
