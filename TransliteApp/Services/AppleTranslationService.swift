import Foundation
import Translation

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
                }
                
                // Note: Language download status checking would require specific language pairs
                // For now, we'll assume all supported languages are available
                await MainActor.run {
                    self.downloadedLanguages = Set(supportedLanguages)
                }
            } catch {
                print("Error checking language availability: \(error)")
                await MainActor.run {
                    self.isTranslationAvailable = false
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
        
        // For now, since the Translation API is complex and iOS 17.4+ specific,
        // we'll throw an error to fall back to Google Translate
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
        await checkAvailability()
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
    
    private init() {
        if #available(iOS 17.4, *) {
            // Apple Translation is available but not implemented yet
            // Set to false to avoid repeated failures
            isAvailable = false
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