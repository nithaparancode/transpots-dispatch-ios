//
//  MainTabView.swift
//  Transpots Dispatch
//
//  Created by Nithaparan Francis on 2026-01-22.
//

import SwiftUI
import TranspotsUI

struct MainTabView: View {
    @StateObject private var homeCoordinator = HomeCoordinator()
    @StateObject private var ordersCoordinator = OrdersCoordinator()
    @StateObject private var tripsCoordinator = TripsCoordinator()
    @StateObject private var profileViewModel = ProfileViewModel()
    @Environment(\.theme) var theme
    
    private var shouldHideTabBar: Bool {
        homeCoordinator.path.count > 0 || ordersCoordinator.path.count > 0 || tripsCoordinator.path.count > 0
    }
    
    var body: some View {
        Group {
            if shouldHideTabBar {
                // Show only the active navigation stack without tab bar
                if homeCoordinator.path.count > 0 {
                    NavigationStack(path: $homeCoordinator.path) {
                        Color.clear
                            .navigationDestination(for: HomeRoute.self) { route in
                                homeCoordinator.view(for: route)
                            }
                    }
                } else if ordersCoordinator.path.count > 0 {
                    NavigationStack(path: $ordersCoordinator.path) {
                        Color.clear
                            .navigationDestination(for: OrdersRoute.self) { route in
                                ordersCoordinator.view(for: route)
                            }
                    }
                } else if tripsCoordinator.path.count > 0 {
                    NavigationStack(path: $tripsCoordinator.path) {
                        Color.clear
                            .navigationDestination(for: TripsRoute.self) { route in
                                tripsCoordinator.view(for: route)
                            }
                    }
                }
            } else {
                // Show full TabView when at root
                TabView {
                    NavigationStack(path: $homeCoordinator.path) {
                        HomeView(
                            viewModel: HomeViewModel(dashboardService: DashboardService()),
                            coordinator: homeCoordinator
                        )
                        .navigationDestination(for: HomeRoute.self) { route in
                            homeCoordinator.view(for: route)
                        }
                    }
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    
                    NavigationStack(path: $ordersCoordinator.path) {
                        OrdersView(
                            viewModel: OrdersViewModel(orderService: OrderService()),
                            coordinator: ordersCoordinator
                        )
                        .navigationDestination(for: OrdersRoute.self) { route in
                            ordersCoordinator.view(for: route)
                        }
                    }
                    .tabItem {
                        Label("Orders", systemImage: "doc.text.fill")
                    }
                    
                    NavigationStack(path: $tripsCoordinator.path) {
                        TripsView(
                            viewModel: TripsViewModel(tripService: TripService()),
                            coordinator: tripsCoordinator
                        )
                        .navigationDestination(for: TripsRoute.self) { route in
                            tripsCoordinator.view(for: route)
                        }
                    }
                    .tabItem {
                        Label("Trips", systemImage: "truck.box.fill")
                    }
                    
                    ProfileView(viewModel: profileViewModel)
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                }
                .tint(theme.colors.primary)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .userDidLogout)) { _ in
            TokenManager.shared.clearTokens()
            homeCoordinator.popToRoot()
        }
    }
}
