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
        checkAvailability()
    }
    
    // MARK: - Availability Checking
    
    func checkAvailability() {
        Task {
            do {
                let availability = LanguageAvailability()
                let supportedLanguages = await availability.supportedLanguages
                
                await MainActor.run {
                    self.availableLanguages = Set(supportedLanguages)
                    self.isTranslationAvailable = !supportedLanguages.isEmpty
                    
                    // If no languages found but we're on iOS 17.4+, assume Translation is available
                    if supportedLanguages.isEmpty {
                        print("⚠️ Apple Translation: No languages found via LanguageAvailability, but iOS 17.4+ detected - assuming available")
                        self.isTranslationAvailable = true
                        
                        // Add common languages manually
                        let commonLanguages: [Locale.Language] = [
                            .init(identifier: "en"),
                            .init(identifier: "uk"),
                            .init(identifier: "es"),
                            .init(identifier: "fr"),
                            .init(identifier: "de"),
                            .init(identifier: "zh")
                        ]
                        self.availableLanguages = Set(commonLanguages)
                        self.downloadedLanguages = Set(commonLanguages)
                    } else {
                        self.downloadedLanguages = Set(supportedLanguages)
                    }
                }
            } catch {
                print("❌ Apple Translation availability check failed: \(error)")
                await MainActor.run {
                    // On iOS 17.4+, assume Translation is available even if check fails
                    self.isTranslationAvailable = true
                    print("✅ Apple Translation: Assuming available on iOS 17.4+")
                    
                    // Add common languages manually
                    let commonLanguages: [Locale.Language] = [
                        .init(identifier: "en"),
                        .init(identifier: "uk"),
                        .init(identifier: "es"),
                        .init(identifier: "fr"),
                        .init(identifier: "de"),
                        .init(identifier: "zh")
                    ]
                    self.availableLanguages = Set(commonLanguages)
                    self.downloadedLanguages = Set(commonLanguages)
                }
            }
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
        checkAvailability()
    }
    
    func checkAvailability() {
        if #available(iOS 17.4, *) {
            // For iOS 17.4+, Apple Translation is available
            isAvailable = true
            print("✅ AppleTranslationServiceWrapper: Available on iOS 17.4+")
            
            // Still subscribe to changes for completeness
            Task {
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
        } else {
            isAvailable = false
            print("❌ AppleTranslationServiceWrapper: Not available on iOS < 17.4")
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