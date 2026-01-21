//
//  Transpots_DispatchApp.swift
//  Transpots Dispatch
//
//  Created by Nithaparan Francis on 2026-01-20.
//

import SwiftUI
import Foundation
import SwiftUI
import TranspotsUI
import Combine

@main
struct Transpots_DispatchApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environment(\.theme, AppTheme.shared.currentTheme == .light ? .light : .dark)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            appState.isLaunchScreenActive = false
                        }
                    }
                }
        }
    }
}

class AppState: ObservableObject {
    @Published var isLaunchScreenActive = true
    @Published var isAuthenticated = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        checkAuthentication()
        setupLogoutObserver()
    }
    
    func checkAuthentication() {
        isAuthenticated = TokenManager.shared.accessToken != nil
    }
    
    private func setupLogoutObserver() {
        NotificationCenter.default.publisher(for: .userDidLogout)
            .sink { [weak self] _ in
                self?.isAuthenticated = false
            }
            .store(in: &cancellables)
    }
    
    func login() {
        isAuthenticated = true
    }
}

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var authCoordinator = AuthCoordinator()
    
    var body: some View {
        Group {
            if appState.isLaunchScreenActive {
                LaunchScreenView()
            } else if appState.isAuthenticated {
                MainTabView()
            } else {
                LoginView(
                    viewModel: LoginViewModel(authService: AuthService()),
                    coordinator: authCoordinator
                )
                .onReceive(NotificationCenter.default.publisher(for: .userDidLogin)) { _ in
                    appState.login()
                }
            }
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
