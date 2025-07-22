import Foundation

enum TranslationService: String, CaseIterable {
    case google = "Google Translate"
    case apple = "Apple Translation"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        return self.rawValue
    }
    
    var systemImageName: String {
        switch self {
        case .google:
            return "globe"
        case .apple:
            return "apple.logo"
        }
    }
    
    var isAvailable: Bool {
        switch self {
        case .google:
            return true
        case .apple:
            return AppleTranslationServiceWrapper.shared.isAvailable
        }
    }
}

// UserDefaults extension for translation preferences
extension UserDefaults {
    private enum Keys {
        static let selectedTranslationService = "selectedTranslationService"
    }
    
    var selectedTranslationService: TranslationService {
        get {
            guard let rawValue = string(forKey: Keys.selectedTranslationService),
                  let service = TranslationService(rawValue: rawValue) else {
                // Default to Google if not set or if Apple Translation is not available
                return .google
            }
            
            // Fallback to Google if selected service is not available
            return service.isAvailable ? service : .google
        }
        set {
            set(newValue.rawValue, forKey: Keys.selectedTranslationService)
        }
    }
}