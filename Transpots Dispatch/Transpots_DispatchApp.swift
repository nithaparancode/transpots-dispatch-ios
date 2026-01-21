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
    @StateObject private var homeCoordinator = HomeCoordinator()
    @Environment(\.theme) var theme
    
    var body: some View {
        HomeView(
            viewModel: HomeViewModel(dashboardService: DashboardService()),
            coordinator: homeCoordinator
        )
        .onReceive(NotificationCenter.default.publisher(for: .userDidLogout)) { _ in
            TokenManager.shared.clearTokens()
            homeCoordinator.popToRoot()
        }
    }
}
