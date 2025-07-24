import SwiftUI

@MainActor
final class OfflineTranslationViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var sourceText = ""
    @Published var translatedText = ""
    @Published var sourceLanguage = "en"
    @Published var targetLanguage = "uk"
    @Published var showLanguagePicker = false
    @Published var isSelectingSourceLanguage = true
    @Published var isOfflineMode = true
    
    // MARK: - Services
    private let offlineTranslation = BasicOfflineTranslation.shared
    
    // MARK: - Properties
    let supportedLanguages = ["en", "uk", "ru", "es", "fr", "de"]
    var availableWordCount: Int {
        offlineTranslation.getDictionarySize()
    }
    
    // MARK: - Public Methods
    func translate() {
        guard !sourceText.isEmpty else {
            translatedText = ""
            return
        }
        
        clearError()
        
        Task {
            if let result = offlineTranslation.translate(
                text: sourceText,
                from: sourceLanguage,
                to: targetLanguage
            ) {
                translatedText = result
            } else {
                // Show partial translation or error
                if let partialResult = translateWords() {
                    translatedText = partialResult
                    showError("partial_translation_available".localized)
                } else {
                    translatedText = ""
                    showError("translation_not_available".localized)
                }
            }
        }
    }
    
    func swapLanguages() {
        let temp = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = temp
        
        if !translatedText.isEmpty {
            sourceText = translatedText
            translate()
        }
    }
    
    func clearAll() {
        sourceText = ""
        translatedText = ""
        clearError()
    }
    
    func selectLanguage(_ language: String, isSource: Bool) {
        if isSource {
            sourceLanguage = language
        } else {
            targetLanguage = language
        }
        
        if !sourceText.isEmpty {
            translate()
        }
    }
    
    func copyTranslation() {
        UIPasteboard.general.string = translatedText
        showError("copied_to_clipboard".localized)
    }
    
    // MARK: - Private Methods
    private func translateWords() -> String? {
        // Try to translate word by word
        let words = sourceText.components(separatedBy: .whitespacesAndNewlines)
        var translatedWords: [String] = []
        var hasTranslation = false
        
        for word in words {
            let cleanWord = word.trimmingCharacters(in: .punctuationCharacters)
            if !cleanWord.isEmpty {
                if let translation = offlineTranslation.translate(
                    text: cleanWord,
                    from: sourceLanguage,
                    to: targetLanguage
                ) {
                    translatedWords.append(translation)
                    hasTranslation = true
                } else {
                    translatedWords.append(word) // Keep original if no translation
                }
            }
        }
        
        return hasTranslation ? translatedWords.joined(separator: " ") : nil
    }
}

// MARK: - Offline Translation Info
struct OfflineTranslationInfo {
    let availableLanguages: [String]
    let dictionarySize: Int
    let lastUpdated: Date?
    
    var formattedDictionarySize: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: dictionarySize)) ?? "\(dictionarySize)"
    }
}