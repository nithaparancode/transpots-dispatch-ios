import Foundation
import Combine
import UIKit

final class ProfileViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded(User)
        case failed(String)
    }
    
    @Published var state: ViewState = .idle
    @Published var user: User?
    @Published var showDeleteConfirmation = false
    
    let appearanceManager = AppearanceManager.shared
    let languageManager = LanguageManager.shared
    
    private var currentTask: Task<Void, Never>?
    private let userService: UserServiceProtocol
    private let tokenManager: TokenManager
    private let storageManager: StorageManager
    
    init(
        userService: UserServiceProtocol = UserService(),
        tokenManager: TokenManager = .shared,
        storageManager: StorageManager = .shared
    ) {
        self.userService = userService
        self.tokenManager = tokenManager
        self.storageManager = storageManager
    }
    
    func loadUserProfile() {
        // Get email from stored user data
        guard let email = try? storageManager.get(forKey: "com.transpots.userEmail", as: String.self, from: .secure) else {
            state = .failed("No user email found")
            return
        }
        
        currentTask?.cancel()
        state = .loading
        
        currentTask = Task { @MainActor in
            do {
                let user = try await userService.getUserByEmail(email)
                self.user = user
                self.state = .loaded(user)
            } catch {
                self.state = .failed(error.localizedDescription)
            }
        }
    }
    
    func logout() {
        tokenManager.clearTokens()
        try? storageManager.clearAll()
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
    }
    
    func deleteAccount() {
        // TODO: Call API to delete account
        logout()
    }
    
    // MARK: - App Information
    
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }
    
    var deviceInfo: String {
        let device = UIDevice.current
        return "\(device.model) - \(device.systemName) \(device.systemVersion)"
    }
    
    var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
            ?? Bundle.main.infoDictionary?["CFBundleName"] as? String
            ?? "Transpots"
    }
    
    deinit {
        currentTask?.cancel()
    }
}
