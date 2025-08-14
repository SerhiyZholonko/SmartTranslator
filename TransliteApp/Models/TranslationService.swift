import Foundation

enum TranslationService: String, CaseIterable {
    case google = "Google Translate"
    case apple = "Apple Translation"
    case groqAI = "AI Enhanced"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .google:
            return LocalizationManager.shared.localizedString(for: "google_translate")
        case .apple:
            return LocalizationManager.shared.localizedString(for: "apple_translation")
        case .groqAI:
            return LocalizationManager.shared.localizedString(for: "ai_enhanced")
        }
    }
    
    var systemImageName: String {
        switch self {
        case .google:
            return "globe"
        case .apple:
            return "apple.logo"
        case .groqAI:
            return "brain.head.profile"
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
        case .groqAI:
            // For sync context, assume available - will be checked async later
            return true
        }
    }
    
    @MainActor
    func checkAvailability() async -> Bool {
        switch self {
        case .google:
            return true
        case .apple:
            return AppleTranslationServiceWrapper.shared.isAvailable
        case .groqAI:
            return GroqTranslationService.shared.isAvailable
        }
    }
    
    var description: String {
        switch self {
        case .google:
            return "fast_reliable_translation".localized
        case .apple:
            return "privacy_focused_translation".localized
        case .groqAI:
            return LocalizationManager.shared.localizedString(for: "ai_enhanced_multiple_variants")
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
            // First check if there's already a saved service
            if let rawValue = object(forKey: Keys.selectedTranslationService) as? String,
               let service = TranslationService(rawValue: rawValue) {
                return service
            }
            
            // If no service saved, use default based on iOS version
            let defaultService: TranslationService
            if #available(iOS 17.4, *) {
                defaultService = .apple
            } else {
                defaultService = .google
            }
            
            // Save the default service for future use
            set(defaultService.rawValue, forKey: Keys.selectedTranslationService)
            return defaultService
        }
        set {
            set(newValue.rawValue, forKey: Keys.selectedTranslationService)
            set(true, forKey: Keys.hasUserManuallySelectedService)
        }
    }
    
    var hasUserManuallySelectedService: Bool {
        get {
            return object(forKey: Keys.hasUserManuallySelectedService) as? Bool ?? false
        }
        set {
            set(newValue, forKey: Keys.hasUserManuallySelectedService)
        }
    }
    
    var hasAutoSelectedServiceForVersion: Bool {
        get {
            return object(forKey: Keys.hasAutoSelectedServiceForVersion) as? Bool ?? false
        }
        set {
            set(newValue, forKey: Keys.hasAutoSelectedServiceForVersion)
        }
    }
    
    func resetTranslationServiceSelection() {
        removeObject(forKey: Keys.selectedTranslationService)
        // Use direct UserDefaults methods to avoid computed property recursion
        set(false, forKey: Keys.hasUserManuallySelectedService)
        set(false, forKey: Keys.hasAutoSelectedServiceForVersion)
    }
}

// MARK: - Translation Mode (User Choice)

// AI mode removed - AI is only used for flashcard generation
// Regular translation uses Apple/Google services

// TranslationMode removed - AI only used for flashcards