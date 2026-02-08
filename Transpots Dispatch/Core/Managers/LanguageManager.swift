import Foundation
import Combine

final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    enum SupportedLanguage: String, CaseIterable {
        case system
        case english = "en"
        case spanish = "es"
        case french = "fr"
        case tamil = "ta"
        case hindi = "hi"
        
        var displayName: String {
            switch self {
            case .system: return "System"
            case .english: return "English"
            case .spanish: return "Español"
            case .french: return "Français"
            case .tamil: return "தமிழ்"
            case .hindi: return "हिन्दी"
            }
        }
    }
    
    @Published var selectedLanguage: SupportedLanguage {
        didSet {
            saveLanguage()
            applyLanguage()
        }
    }
    
    private let storageKey = "com.transpots.appLanguage"
    private let storageManager: StorageManager
    
    private init(storageManager: StorageManager = .shared) {
        self.storageManager = storageManager
        let savedRaw = (try? storageManager.get(forKey: "com.transpots.appLanguage", as: String.self, from: .standard)) ?? SupportedLanguage.system.rawValue
        self.selectedLanguage = SupportedLanguage(rawValue: savedRaw) ?? .system
    }
    
    private func saveLanguage() {
        try? storageManager.save(selectedLanguage.rawValue, forKey: storageKey, in: .standard)
    }
    
    private func applyLanguage() {
        if selectedLanguage == .system {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.set([selectedLanguage.rawValue], forKey: "AppleLanguages")
        }
    }
}
