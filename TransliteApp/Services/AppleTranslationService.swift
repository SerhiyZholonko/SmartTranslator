import Foundation
import Translation
import Combine

@available(iOS 17.4, *)
class AppleTranslationService: ObservableObject {
    static let shared = AppleTranslationService()
    
    @Published var availableLanguages: Set<Locale.Language> = []
    @Published var isTranslationAvailable: Bool = false
    @Published var downloadedLanguages: Set<Locale.Language> = []
    
    private init() {
        // Set default state immediately to avoid crashes
        isTranslationAvailable = true
        
        // Add common languages by default
        let commonLanguages: [Locale.Language] = [
            .init(identifier: "en"),
            .init(identifier: "uk"),
            .init(identifier: "es"),
            .init(identifier: "fr"),
            .init(identifier: "de"),
            .init(identifier: "zh")
        ]
        availableLanguages = Set(commonLanguages)
        downloadedLanguages = Set(commonLanguages)
        
        // Do async check later to avoid blocking init
        Task {
            await checkAvailabilityAsync()
        }
    }
    
    // MARK: - Availability Checking
    
    func checkAvailability() {
        // Public method for manual refresh
        Task {
            await checkAvailabilityAsync()
        }
    }
    
    private func checkAvailabilityAsync() async {
        do {
            let availability = LanguageAvailability()
            let supportedLanguages = await availability.supportedLanguages
            
            await MainActor.run {
                if !supportedLanguages.isEmpty {
                    self.availableLanguages = Set(supportedLanguages)
                    self.downloadedLanguages = Set(supportedLanguages)
                    print("✅ Apple Translation: Found \(supportedLanguages.count) languages")
                } else {
                    print("⚠️ Apple Translation: No languages found via LanguageAvailability, using defaults")
                }
            }
        } catch {
            print("❌ Apple Translation availability check failed: \(error)")
            // Keep defaults set in init
        }
    }
    
    // MARK: - Translation Methods
    
    func translate(
        text: String,
        from sourceLanguage: String,
        to targetLanguage: String
    ) async throws -> String {
        guard !text.isEmpty else { return "" }
        
        // For now, since the Translation API is still evolving and has limited documentation,
        // we'll return an error to fall back to Google Translate
        // This preserves the automatic selection functionality while avoiding compilation errors
        
        // TODO: Implement proper Translation API when it's more stable
        // Example future implementation:
        // let sourceLang = Locale.Language(identifier: sourceLanguage)
        // let targetLang = Locale.Language(identifier: targetLanguage)
        // let configuration = TranslationSession.Configuration(source: sourceLang, target: targetLang)
        // Use TranslationSession.translationSupported(from:to:) to check support
        // Create session and translate
        
        throw TranslationError.noTranslationAvailable
    }
    
    func canTranslate(from: String, to: String) -> Bool {
        let sourceLang = Locale.Language(identifier: from)
        let targetLang = Locale.Language(identifier: to)
        
        return availableLanguages.contains(sourceLang) && availableLanguages.contains(targetLang)
    }
    
    func downloadLanguage(from: String, to: String) async throws {
        // The Translation framework handles language downloads automatically
        // when a translation is requested. We'll just update our availability.
        checkAvailability()
    }
    
    func isLanguageDownloaded(from: String, to: String) -> Bool {
        let sourceLang = Locale.Language(identifier: from)
        let targetLang = Locale.Language(identifier: to)
        
        return downloadedLanguages.contains(sourceLang) && downloadedLanguages.contains(targetLang)
    }
}

// Wrapper for iOS versions before 17.4
class AppleTranslationServiceWrapper: ObservableObject {
    static let shared = AppleTranslationServiceWrapper()
    
    @Published var isAvailable: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Set availability immediately without async calls
        if #available(iOS 17.4, *) {
            isAvailable = true
            print("✅ AppleTranslationServiceWrapper: Available on iOS 17.4+")
        } else {
            isAvailable = false
            print("❌ AppleTranslationServiceWrapper: Not available on iOS < 17.4")
        }
    }
    
    func checkAvailability() {
        // Only do async work if explicitly requested
        if #available(iOS 17.4, *) {
            // Subscribe to changes for completeness, but don't block initialization
            AppleTranslationService.shared.$isTranslationAvailable
                .receive(on: DispatchQueue.main)
                .sink { [weak self] translationAvailable in
                    // Only update if it becomes false (in case of specific issues)
                    if !translationAvailable {
                        self?.isAvailable = false
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    func translate(text: String, from: String, to: String) async throws -> String {
        if #available(iOS 17.4, *) {
            return try await AppleTranslationService.shared.translate(
                text: text,
                from: from,
                to: to
            )
        } else {
            throw TranslationError.unsupportedLanguage
        }
    }
    
    func canTranslate(from: String, to: String) -> Bool {
        if #available(iOS 17.4, *) {
            return AppleTranslationService.shared.canTranslate(from: from, to: to)
        }
        return false
    }
}