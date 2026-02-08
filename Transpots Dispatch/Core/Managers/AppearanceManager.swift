import SwiftUI
import Combine

final class AppearanceManager: ObservableObject {
    static let shared = AppearanceManager()
    
    enum AppearanceMode: String, CaseIterable {
        case system
        case light
        case dark
        
        var displayName: String {
            switch self {
            case .system: return "System"
            case .light: return "Light"
            case .dark: return "Dark"
            }
        }
        
        var icon: String {
            switch self {
            case .system: return "gear"
            case .light: return "sun.max.fill"
            case .dark: return "moon.fill"
            }
        }
        
        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }
    
    @Published var selectedMode: AppearanceMode {
        didSet {
            saveAppearance()
        }
    }
    
    private let storageKey = "com.transpots.appearanceMode"
    private let storageManager: StorageManager
    
    private init(storageManager: StorageManager = .shared) {
        self.storageManager = storageManager
        let savedRaw = (try? storageManager.get(forKey: "com.transpots.appearanceMode", as: String.self, from: .standard)) ?? AppearanceMode.system.rawValue
        self.selectedMode = AppearanceMode(rawValue: savedRaw) ?? .system
    }
    
    private func saveAppearance() {
        try? storageManager.save(selectedMode.rawValue, forKey: storageKey, in: .standard)
    }
}
