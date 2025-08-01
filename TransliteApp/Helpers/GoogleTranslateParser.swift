
import Foundation

enum TranslationError: LocalizedError {
    case networkError
    case invalidResponse
    case noTranslationAvailable
    case textTooLong
    case unsupportedLanguage
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network connection error"
        case .invalidResponse:
            return "Invalid response from translation service"
        case .noTranslationAvailable:
            return "Translation not available"
        case .textTooLong:
            return "Text is too long to translate"
        case .unsupportedLanguage:
            return "Language not supported"
        }
    }
}

class GoogleTranslateParser: ObservableObject {
    @Published var isTranslating = false
    @Published var translations: [TranslationOption] = []
    
    private let baseURL = "https://translate.googleapis.com/translate_a/single"
    private let maxTextLength = 4500 // Google's limit
    
    // Custom URLSession with longer timeouts
    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60.0  // 60 seconds for request
        configuration.timeoutIntervalForResource = 120.0 // 2 minutes for resource
        configuration.waitsForConnectivity = true
        configuration.allowsCellularAccess = true
        configuration.httpMaximumConnectionsPerHost = 4
        return URLSession(configuration: configuration)
    }()
    
    struct TranslationOption: Identifiable, Hashable {
        let id = UUID()
        let text: String
        let confidence: Double?
        let category: TranslationCategory
        let frequency: String? // Low, Medium, High frequency
        let partOfSpeech: String? // noun, verb, adjective, etc.
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(text)
            hasher.combine(category)
        }
        
        static func == (lhs: TranslationOption, rhs: TranslationOption) -> Bool {
            return lhs.text == rhs.text && lhs.category == rhs.category
        }
    }
    
    enum TranslationCategory: String, CaseIterable {
        case primary = "Primary"
        case synonym = "Synonym"
        case informal = "Informal"
        case formal = "Formal"
        case colloquial = "Colloquial"
        case technical = "Technical"
        case archaic = "Archaic"
        case alternative = "Alternative"
        
        var color: Color {
            switch self {
            case .primary: return .blue
            case .synonym: return .green
            case .informal: return .orange
            case .formal: return .purple
            case .colloquial: return .pink
            case .technical: return .cyan
            case .archaic: return .gray
            case .alternative: return .teal
            }
        }
    }
    
    // MARK: - Main Translation Methods
    
    /// Original translate method - returns single best translation
    func translate(text: String, from sourceLanguage: String = "auto", to targetLanguage: String) async throws -> String {
        guard !text.isEmpty else { return "" }
        
        await MainActor.run {
            isTranslating = true
        }
        
        defer {
            Task { @MainActor in
                isTranslating = false
            }
        }
        
        // Handle text that's too long by chunking
        if text.count > maxTextLength {
            return try await translateLongText(text: text, from: sourceLanguage, to: targetLanguage)
        }
        
        return try await performSingleTranslation(text: text, from: sourceLanguage, to: targetLanguage)
    }
    
    /// Enhanced method - returns multiple translation options
    func translateWithOptions(text: String, from sourceLanguage: String = "auto", to targetLanguage: String) async throws -> [TranslationOption] {
        guard !text.isEmpty else { return [] }
        
        await MainActor.run {
            isTranslating = true
            translations = []
        }
        
        defer {
            Task { @MainActor in
                isTranslating = false
            }
        }
        
        var allTranslations: [TranslationOption] = []
        
        // Get primary translation with alternatives
        let primaryOptions = try await getDetailedTranslations(text: text, from: sourceLanguage, to: targetLanguage)
        allTranslations.append(contentsOf: primaryOptions)
        
        // Get contextual variations
        if let primaryTranslation = primaryOptions.first(where: { $0.category == .primary })?.text {
            let contextual = await getContextualVariations(for: primaryTranslation, targetLanguage: targetLanguage)
            allTranslations.append(contentsOf: contextual)
        }
        
        // Remove duplicates and sort by confidence and category priority
        let uniqueTranslations = Array(Set(allTranslations))
            .sorted { (lhs, rhs) in
                // First sort by category priority
                let lhsPriority = categoryPriority(lhs.category)
                let rhsPriority = categoryPriority(rhs.category)
                
                if lhsPriority != rhsPriority {
                    return lhsPriority < rhsPriority
                }
                
                // Then by confidence
                let lhsConfidence = lhs.confidence ?? 0
                let rhsConfidence = rhs.confidence ?? 0
                return lhsConfidence > rhsConfidence
            }
        
        await MainActor.run {
            self.translations = uniqueTranslations
        }
        
        return uniqueTranslations
    }
    
    // MARK: - Private Translation Methods
    
    private func performSingleTranslation(text: String, from sourceLanguage: String, to targetLanguage: String) async throws -> String {
        return try await performTranslationWithRetry(text: text, from: sourceLanguage, to: targetLanguage)
    }
    
    private func performTranslationWithRetry(text: String, from sourceLanguage: String, to targetLanguage: String, attempt: Int = 1) async throws -> String {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "client", value: "gtx"),
            URLQueryItem(name: "sl", value: sourceLanguage),
            URLQueryItem(name: "tl", value: targetLanguage),
            URLQueryItem(name: "dt", value: "t"),
            URLQueryItem(name: "q", value: text)
        ]
        
        guard let url = components.url else {
            throw TranslationError.networkError
        }
        
        let (data, _) = try await performNetworkRequestWithRetry(url: url, attempt: attempt)
        
        guard let responseString = String(data: data, encoding: .utf8) else {
            throw TranslationError.invalidResponse
        }
        
        return try parseTranslationResponse(responseString)
    }
    
    private func parseTranslationResponse(_ responseString: String) throws -> String {
        
        guard let data = responseString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any],
              let translations = json.first as? [Any] else {
            throw TranslationError.invalidResponse
        }
        
        var translatedText = ""
        for translation in translations {
            if let translationArray = translation as? [Any],
               let text = translationArray.first as? String {
                translatedText += text
            }
        }
        
        return translatedText
    }
    
    private func performNetworkRequestWithRetry(url: URL, attempt: Int = 1) async throws -> (Data, URLResponse) {
        do {
            let result = try await urlSession.data(from: url)
            return result
        } catch {
            print("Network request attempt \(attempt) failed: \(error.localizedDescription)")
            
            // Check if this is a network timeout or connection error
            if let urlError = error as? URLError,
               (urlError.code == .timedOut || urlError.code == .networkConnectionLost || urlError.code == .notConnectedToInternet) {
                
                // Retry up to 3 times with exponential backoff
                if attempt < 3 {
                    let delay = pow(2.0, Double(attempt)) // 2, 4, 8 seconds
                    print("Retrying network request in \(delay) seconds...")
                    
                    try await Task.sleep(for: .seconds(delay))
                    return try await performNetworkRequestWithRetry(url: url, attempt: attempt + 1)
                }
            }
            
            // If all retries failed or it's not a network error, throw the original error
            throw error
        }
    }
    
    private func getDetailedTranslations(text: String, from sourceLanguage: String, to targetLanguage: String) async throws -> [TranslationOption] {
        // Extended Google Translate API call to get more data
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "client", value: "gtx"),
            URLQueryItem(name: "sl", value: sourceLanguage),
            URLQueryItem(name: "tl", value: targetLanguage),
            URLQueryItem(name: "dt", value: "t"),  // Translations
            URLQueryItem(name: "dt", value: "bd"), // Dictionary
            URLQueryItem(name: "dt", value: "rm"), // Romanization
            URLQueryItem(name: "dt", value: "qca"), // Query correction
            URLQueryItem(name: "dt", value: "ss"), // Synonyms
            URLQueryItem(name: "q", value: text)
        ]
        
        guard let url = components.url else {
            throw TranslationError.networkError
        }
        
        let (data, _) = try await performNetworkRequestWithRetry(url: url)
        
        guard let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any] else {
            throw TranslationError.invalidResponse
        }
        
        var translationOptions: [TranslationOption] = []
        
        // Parse primary translation (index 0)
        if let translationsArray = jsonArray.first as? [Any] {
            var primaryText = ""
            for translation in translationsArray {
                if let translationArray = translation as? [Any],
                   let text = translationArray.first as? String {
                    primaryText += text
                }
            }
            
            if !primaryText.isEmpty {
                translationOptions.append(TranslationOption(
                    text: primaryText,
                    confidence: 0.95,
                    category: .primary,
                    frequency: "High",
                    partOfSpeech: nil
                ))
            }
        }
        
        // Parse dictionary/alternative translations (index 1)
        if jsonArray.count > 1, let dictionaryArray = jsonArray[1] as? [Any] {
            for item in dictionaryArray {
                if let itemArray = item as? [Any],
                   itemArray.count > 2,
                   let partOfSpeech = itemArray[0] as? String,
                   let translations = itemArray[2] as? [Any] {
                    
                    for (index, translation) in translations.enumerated() {
                        if let translationArray = translation as? [Any],
                           translationArray.count > 0,
                           let translatedText = translationArray[0] as? String {
                            
                            let confidence = translationArray.count > 3 ? translationArray[3] as? Double : nil
                            let frequency = translationArray.count > 1 ? translationArray[1] as? [String] : nil
                            
                            let category = determineCategoryFromDictionary(
                                confidence: confidence,
                                index: index,
                                partOfSpeech: partOfSpeech
                            )
                            
                            translationOptions.append(TranslationOption(
                                text: translatedText,
                                confidence: confidence,
                                category: category,
                                frequency: frequency?.first,
                                partOfSpeech: partOfSpeech
                            ))
                        }
                    }
                }
            }
        }
        
        return translationOptions
    }
    
    private func translateLongText(text: String, from sourceLanguage: String, to targetLanguage: String) async throws -> String {
        let chunks = splitIntoChunks(text: text, maxLength: maxTextLength)
        var translatedChunks: [String] = []
        
        for chunk in chunks {
            let translatedChunk = try await performSingleTranslation(text: chunk, from: sourceLanguage, to: targetLanguage)
            translatedChunks.append(translatedChunk)
            
            // Add small delay between requests to avoid rate limiting
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        }
        
        return translatedChunks.joined(separator: " ")
    }
    
    private func splitIntoChunks(text: String, maxLength: Int) -> [String] {
        var chunks: [String] = []
        var currentChunk = ""
        
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        
        for sentence in sentences {
            let trimmedSentence = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedSentence.isEmpty { continue }
            
            let sentenceWithPunctuation = trimmedSentence + ". "
            
            if currentChunk.count + sentenceWithPunctuation.count <= maxLength {
                currentChunk += sentenceWithPunctuation
            } else {
                if !currentChunk.isEmpty {
                    chunks.append(currentChunk.trimmingCharacters(in: .whitespaces))
                }
                currentChunk = sentenceWithPunctuation
            }
        }
        
        if !currentChunk.isEmpty {
            chunks.append(currentChunk.trimmingCharacters(in: .whitespaces))
        }
        
        return chunks
    }
    
    // MARK: - Contextual Variations
    
    private func getContextualVariations(for translation: String, targetLanguage: String) async -> [TranslationOption] {
        var variations: [TranslationOption] = []
        
        // Generate grammatical variations
        variations.append(contentsOf: generateGrammaticalVariations(translation, targetLanguage: targetLanguage))
        
        // Generate formality variations
        variations.append(contentsOf: generateFormalityVariations(translation, targetLanguage: targetLanguage))
        
        return variations
    }
    
    private func generateGrammaticalVariations(_ text: String, targetLanguage: String) -> [TranslationOption] {
        var variations: [TranslationOption] = []
        let lowercased = text.lowercased()
        let capitalized = text.capitalized
        
        if text != lowercased {
            variations.append(TranslationOption(
                text: lowercased,
                confidence: 0.8,
                category: .informal,
                frequency: "Medium",
                partOfSpeech: nil
            ))
        }
        
        if text != capitalized {
            variations.append(TranslationOption(
                text: capitalized,
                confidence: 0.85,
                category: .formal,
                frequency: "Medium",
                partOfSpeech: nil
            ))
        }
        
        // Language-specific variations
        if targetLanguage == "en" {
            // Add "the" if it's a noun and doesn't have an article
            if !lowercased.hasPrefix("the ") && !lowercased.hasPrefix("a ") && !lowercased.hasPrefix("an ") {
                variations.append(TranslationOption(
                    text: "the " + lowercased,
                    confidence: 0.7,
                    category: .alternative,
                    frequency: "Low",
                    partOfSpeech: "noun"
                ))
            }
        } else if targetLanguage == "uk" || targetLanguage == "ru" {
            // Add Ukrainian/Russian specific variations
            // This could be expanded with more linguistic rules
        }
        
        return variations
    }
    
    private func generateFormalityVariations(_ text: String, targetLanguage: String) -> [TranslationOption] {
        var variations: [TranslationOption] = []
        
        let formalityMappings: [String: [(formal: String, informal: String)]] = [
            "en": [
                ("hello", "hi"),
                ("goodbye", "bye"),
                ("thank you", "thanks"),
                ("please", "pls"),
                ("you are", "you're"),
                ("cannot", "can't"),
                ("will not", "won't"),
                ("should not", "shouldn't"),
                ("would not", "wouldn't"),
                ("do not", "don't")
            ],
            "uk": [
                ("дякую", "спасибі"),
                ("будь ласка", "будька"),
                ("добрий день", "привіт"),
                ("до побачення", "бувай"),
                ("вибачте", "сорі")
            ],
            "ru": [
                ("спасибо", "спс"),
                ("пожалуйста", "плз"),
                ("здравствуйте", "привет"),
                ("до свидания", "пока")
            ]
        ]
        
        if let mappings = formalityMappings[targetLanguage] {
            for (formal, informal) in mappings {
                if text.lowercased().contains(formal) {
                    let informalVariation = text.replacingOccurrences(of: formal, with: informal, options: .caseInsensitive)
                    variations.append(TranslationOption(
                        text: informalVariation,
                        confidence: 0.75,
                        category: .informal,
                        frequency: "High",
                        partOfSpeech: nil
                    ))
                } else if text.lowercased().contains(informal) {
                    let formalVariation = text.replacingOccurrences(of: informal, with: formal, options: .caseInsensitive)
                    variations.append(TranslationOption(
                        text: formalVariation,
                        confidence: 0.75,
                        category: .formal,
                        frequency: "Medium",
                        partOfSpeech: nil
                    ))
                }
            }
        }
        
        return variations
    }
    
    // MARK: - Helper Methods
    
    private func determineCategoryFromDictionary(confidence: Double?, index: Int, partOfSpeech: String) -> TranslationCategory {
        if let conf = confidence {
            if conf > 0.9 {
                return index == 0 ? .primary : .synonym
            } else if conf > 0.7 {
                return .synonym
            } else if conf > 0.5 {
                return .alternative
            } else {
                return .colloquial
            }
        }
        
        // Fallback based on position and part of speech
        if index == 0 {
            return .primary
        } else if index < 3 {
            return .synonym
        } else {
            return .alternative
        }
    }
    
    private func categoryPriority(_ category: TranslationCategory) -> Int {
        switch category {
        case .primary: return 0
        case .synonym: return 1
        case .formal: return 2
        case .informal: return 3
        case .alternative: return 4
        case .technical: return 5
        case .colloquial: return 6
        case .archaic: return 7
        }
    }
}

// MARK: - SwiftUI Color Extension for compatibility
#if canImport(SwiftUI)
import SwiftUI
#else
// Fallback for when SwiftUI is not available
struct Color {
    static let blue = Color()
    static let green = Color()
    static let orange = Color()
    static let purple = Color()
    static let pink = Color()
    static let cyan = Color()
    static let gray = Color()
    static let teal = Color()
}
#endif
