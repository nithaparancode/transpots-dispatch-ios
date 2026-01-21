//
//  Transpots_DispatchApp.swift
//  Transpots Dispatch
//
//  Created by Nithaparan Francis on 2026-01-20.
//

import SwiftUI
import Foundation
import Combine
import TranspotsUI

@main
struct Transpots_DispatchApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var appTheme = AppTheme.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(appTheme)
                .environment(\.theme, appTheme.currentTheme == .light ? Theme.light : Theme.dark)
        }
    }
}

final class AppState: ObservableObject {
    @Published var isLaunchScreenActive = true
    
    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isLaunchScreenActive = false
        }
    }
}

struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        if appState.isLaunchScreenActive {
            LaunchScreenView()
        } else {
            MainTabView()
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var homeCoordinator = HomeCoordinator()
    @StateObject private var ordersCoordinator = OrdersCoordinator()
    @StateObject private var profileCoordinator = ProfileCoordinator()
    @Environment(\.theme) var theme
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: HomeViewModel(), coordinator: homeCoordinator)
                .tabItem {
                    Label("Home", systemImage: AppSymbols.tabHomeName)
                }
                .tag(0)
            
            OrdersView(viewModel: OrdersViewModel(), coordinator: ordersCoordinator)
                .tabItem {
                    Label("Orders", systemImage: AppSymbols.tabOrdersName)
                }
                .tag(1)
            
            ProfileView(viewModel: ProfileViewModel(), coordinator: profileCoordinator)
                .tabItem {
                    Label("Profile", systemImage: AppSymbols.tabProfileName)
                }
                .tag(2)
        }
        .tint(theme.colors.primary)
        .onReceive(NotificationCenter.default.publisher(for: .userDidLogout)) { _ in
            TokenManager.shared.clearTokens()
            homeCoordinator.popToRoot()
            ordersCoordinator.popToRoot()
            profileCoordinator.popToRoot()
        }
    }
}
