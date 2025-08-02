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
            let available = AppleTranslationServiceWrapper.shared.isAvailable
            print("🔍 Apple Translation isAvailable check: \(available)")
            return available
        }
    }
}

// UserDefaults extension for translation preferences
extension UserDefaults {
    private enum Keys {
        static let selectedTranslationService = "selectedTranslationService"
        static let hasUserManuallySelectedService = "hasUserManuallySelectedService"
        static let hasAutoSelectedServiceForVersion = "hasAutoSelectedServiceForVersion"
    }
    
    var selectedTranslationService: TranslationService {
        get {
            // Check if we need to auto-select based on iOS version
            if !hasUserManuallySelectedService {
                // Auto-select based on iOS version and service availability
                let defaultService: TranslationService
                if #available(iOS 17.4, *), AppleTranslationServiceWrapper.shared.isAvailable {
                    // Set Apple Translation as default for iOS 17.4+ when available
                    defaultService = .apple
                } else {
                    // Set Google as default for older versions or when Apple Translation is not available
                    defaultService = .google
                }
                
                // Save the auto-selected service
                set(defaultService.rawValue, forKey: Keys.selectedTranslationService)
                return defaultService
            }
            
            guard let rawValue = string(forKey: Keys.selectedTranslationService),
                  let service = TranslationService(rawValue: rawValue) else {
                // Default to Google if not set
                return .google
            }
            
            // Fallback to Google if selected service is not available
            return service.isAvailable ? service : .google
        }
        set {
            set(newValue.rawValue, forKey: Keys.selectedTranslationService)
            // Mark that user has manually selected a service
            hasUserManuallySelectedService = true
        }
    }
    
    var hasUserManuallySelectedService: Bool {
        get {
            return bool(forKey: Keys.hasUserManuallySelectedService)
        }
        set {
            set(newValue, forKey: Keys.hasUserManuallySelectedService)
        }
    }
    
    var hasAutoSelectedServiceForVersion: Bool {
        get {
            return bool(forKey: Keys.hasAutoSelectedServiceForVersion)
        }
        set {
            set(newValue, forKey: Keys.hasAutoSelectedServiceForVersion)
        }
    }
    
    func resetTranslationServiceSelection() {
        removeObject(forKey: Keys.selectedTranslationService)
        hasUserManuallySelectedService = false
        hasAutoSelectedServiceForVersion = false
    }
}