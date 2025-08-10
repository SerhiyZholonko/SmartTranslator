import Foundation
import UIKit

@MainActor
class GroqTranslationService: ObservableObject {
    static let shared = GroqTranslationService()
    
    @Published var isAvailable = false
    @Published var isLoading = false
    
    private let baseURL = "https://api.groq.com/openai/v1/chat/completions"
    
    // API keys (можна налаштувати через Settings)
    nonisolated private var apiKeys: [String] {
        // First check UserDefaults for user-provided keys
        if let keysString = UserDefaults.standard.string(forKey: "groq_api_keys") {
            let keys = keysString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            let validKeys = keys.filter { !$0.isEmpty }
            if !validKeys.isEmpty {
                return validKeys
            }
        }
        
        if let singleKey = UserDefaults.standard.string(forKey: "groq_api_key"), !singleKey.isEmpty {
            return [singleKey]
        }
        
        // Fallback to config file keys (ignored by git)
        return loadKeysFromConfig()
    }
    
    // Load API keys from config file (git-ignored)
    nonisolated private func loadKeysFromConfig() -> [String] {
        guard let path = Bundle.main.path(forResource: "GroqApiKeys", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let keys = plist["keys"] as? [String] else {
            return []
        }
        return keys.filter { !$0.isEmpty }
    }
    
    @Published private var currentKeyIndex = 0
    @Published private var keyStatus: [String: KeyStatus] = [:]
    
    enum KeyStatus {
        case active
        case rateLimited
        case invalid
        case unknown
    }
    
    enum GroqModel: String, CaseIterable {
        case llama31_8b = "llama-3.1-8b-instant"
        case llama31_70b = "llama-3.1-70b-versatile"
        case llama3_8b = "llama3-8b-8192"
        
        var displayName: String {
            switch self {
            case .llama31_8b:
                return "Llama 3.1 8B (Fast)"
            case .llama31_70b:
                return "Llama 3.1 70B (Accurate)"
            case .llama3_8b:
                return "Llama 3 8B"
            }
        }
        
        var description: String {
            switch self {
            case .llama31_8b:
                return "Fast and efficient for most translations"
            case .llama31_70b:
                return "Most accurate, slower processing"
            case .llama3_8b:
                return "Good balance of speed and accuracy"
            }
        }
    }
    
    private let usageTrackerKey = "groq_usage_tracker"
    @Published private var usageTracker = GroqUsageTracker()
    @Published private var currentModel: GroqModel = .llama31_8b
    
    private init() {
        loadUsageTracker()
        checkAvailability()
    }
    
    // MARK: - Availability Check
    
    func checkAvailability() {
        Task {
            let hasKeys = !apiKeys.isEmpty
            let canUse = usageTracker.canUseToday
            let hasValidKey = await checkApiKeyValidity()
            
            await MainActor.run {
                isAvailable = hasKeys && canUse && hasValidKey
                print("🔍 GroqTranslationService availability: keys=\(hasKeys), canUse=\(canUse), validKey=\(hasValidKey)")
            }
        }
    }
    
    private func checkApiKeyValidity() async -> Bool {
        guard let key = getCurrentApiKey() else { return false }
        
        // Simple test request to check key validity
        guard let url = URL(string: baseURL) else { return false }
        
        let testMessages = [GroqMessage(role: "user", content: "test")]
        let requestBody = GroqChatRequest(
            model: currentModel.rawValue,
            messages: testMessages,
            temperature: 0.1,
            maxTokens: 10,
            stream: false
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10 // Quick test
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                let isValid = httpResponse.statusCode != 401 && httpResponse.statusCode != 403
                await MainActor.run {
                    keyStatus[key] = isValid ? .active : .invalid
                }
                return isValid
            }
        } catch {
            // Network error doesn't mean invalid key
            return true
        }
        
        return false
    }
    
    // MARK: - Translation Methods
    
    func getEnhancedTranslations(
        text: String,
        from sourceLanguage: String,
        to targetLanguage: String
    ) async throws -> [GoogleTranslateParser.TranslationOption] {
        
        guard isAvailable else {
            throw GroqTranslationError.serviceUnavailable
        }
        
        guard usageTracker.canUseToday else {
            throw GroqTranslationError.dailyLimitExceeded
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Record usage before making the request
            recordUsage()
            
            let response = try await callGroqTranslationAPI(
                text: text,
                from: sourceLanguage,
                to: targetLanguage
            )
            
            let options = parseTranslationResponse(response)
            print("✅ GroqTranslationService: Generated \(options.count) enhanced translations")
            
            return options
            
        } catch {
            print("❌ GroqTranslationService: \(error)")
            throw error
        }
    }
    
    private func callGroqTranslationAPI(
        text: String,
        from sourceLanguage: String,
        to targetLanguage: String
    ) async throws -> String {
        
        guard let url = URL(string: baseURL) else {
            throw GroqTranslationError.invalidURL
        }
        
        var lastError: Error?
        let maxRetries = apiKeys.count
        
        for _ in 0..<maxRetries {
            guard let currentKey = getCurrentApiKey() else {
                throw GroqTranslationError.noValidApiKey
            }
            
            do {
                let response = try await performTranslationRequest(
                    url: url,
                    apiKey: currentKey,
                    text: text,
                    from: sourceLanguage,
                    to: targetLanguage
                )
                
                markKeyAsActive(currentKey)
                return response
                
            } catch GroqTranslationError.rateLimitExceeded {
                markKeyAsRateLimited(currentKey)
                lastError = GroqTranslationError.rateLimitExceeded
                continue
            } catch GroqTranslationError.invalidApiKey {
                markKeyAsInvalid(currentKey)
                lastError = GroqTranslationError.invalidApiKey
                continue
            } catch {
                lastError = error
                continue
            }
        }
        
        throw lastError ?? GroqTranslationError.allKeysFailed
    }
    
    private func performTranslationRequest(
        url: URL,
        apiKey: String,
        text: String,
        from sourceLanguage: String,
        to targetLanguage: String
    ) async throws -> String {
        
        let sourceLangName = getLanguageName(sourceLanguage)
        let targetLangName = getLanguageName(targetLanguage)
        
        // Enhanced prompt для кращого розпізнавання неоднозначних слів
        let systemPrompt = """
        You are a professional translator specializing in ambiguous words and context-sensitive translations.
        
        Rules:
        1. Translate from \(sourceLangName) to \(targetLangName)
        2. If the text contains ambiguous words (like "duck", "bank", "bark", "bat", "bear", etc.), provide ALL possible meanings
        3. Provide 3-6 different translation variants covering different contexts
        4. For ambiguous words, explain the context briefly in parentheses
        5. Order from most common usage to specialized contexts
        6. Each variant should be on a new line, numbered (1., 2., 3., etc.)
        7. Format: [Translation] ([Context if ambiguous])
        
        Examples for ambiguous words:
        - "duck" → "качка (птах)" and "пригнутися (дія)"
        - "bank" → "банк (фінанси)" and "берег (річки)"
        - "bark" → "гавкати (собака)" and "кора (дерева)"
        
        Format:
        1. [Most common translation] ([context if needed])
        2. [Alternative meaning] ([different context])
        3. [Formal/technical variant]
        4. [Colloquial/informal variant]
        """
        
        let userPrompt = "Translate this text:\n\n\(text)"
        
        let apiMessages = [
            GroqMessage(role: "system", content: systemPrompt),
            GroqMessage(role: "user", content: userPrompt)
        ]
        
        let requestBody = GroqChatRequest(
            model: currentModel.rawValue,
            messages: apiMessages,
            temperature: 0.7, // Slightly higher for creativity
            maxTokens: 1024,
            stream: false
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GroqTranslationError.invalidResponse
        }
        
        if httpResponse.statusCode == 429 {
            throw GroqTranslationError.rateLimitExceeded
        } else if httpResponse.statusCode == 401 {
            throw GroqTranslationError.invalidApiKey
        } else if httpResponse.statusCode != 200 {
            if let errorResponse = try? JSONDecoder().decode(GroqError.self, from: data) {
                if errorResponse.error.message.contains("rate limit") || errorResponse.error.message.contains("quota") {
                    throw GroqTranslationError.rateLimitExceeded
                }
                throw GroqTranslationError.apiError(errorResponse.error.message)
            } else {
                throw GroqTranslationError.httpError(httpResponse.statusCode)
            }
        }
        
        let groqResponse = try JSONDecoder().decode(GroqChatResponse.self, from: data)
        
        guard let firstChoice = groqResponse.choices.first else {
            throw GroqTranslationError.noResponse
        }
        
        return firstChoice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func parseTranslationResponse(_ response: String) -> [GoogleTranslateParser.TranslationOption] {
        var options: [GoogleTranslateParser.TranslationOption] = []
        
        let lines = response.components(separatedBy: .newlines)
        var currentIndex = 0
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check if line starts with a number (1., 2., etc.)
            if let range = trimmedLine.range(of: #"^\d+\.\s*"#, options: .regularExpression) {
                let fullTranslation = String(trimmedLine[range.upperBound...])
                
                if !fullTranslation.isEmpty {
                    // Extract translation and context if present
                    let (translation, context) = extractTranslationAndContext(fullTranslation)
                    
                    let category = getTranslationCategory(for: currentIndex, context: context)
                    let confidence = getConfidenceScore(for: currentIndex)
                    
                    let option = GoogleTranslateParser.TranslationOption(
                        text: translation,
                        confidence: confidence,
                        category: category,
                        frequency: currentIndex < 2 ? "High" : "Medium",
                        partOfSpeech: nil
                    )
                    
                    options.append(option)
                    currentIndex += 1
                }
            }
        }
        
        // If parsing failed, create one option from the whole response
        if options.isEmpty && !response.isEmpty {
            let option = GoogleTranslateParser.TranslationOption(
                text: response,
                confidence: 0.9,
                category: .primary,
                frequency: "High",
                partOfSpeech: nil
            )
            options.append(option)
        }
        
        return options
    }
    
    // MARK: - Helper Methods
    
    private func extractTranslationAndContext(_ fullTranslation: String) -> (translation: String, context: String?) {
        // Check if translation has context in parentheses
        if let range = fullTranslation.range(of: #"\s*\([^)]+\)\s*$"#, options: .regularExpression) {
            let translation = String(fullTranslation[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            let contextMatch = String(fullTranslation[range])
            let context = contextMatch.trimmingCharacters(in: CharacterSet(charactersIn: " ()"))
            return (translation, context.isEmpty ? nil : context)
        }
        
        return (fullTranslation, nil)
    }
    
    private func getTranslationCategory(for index: Int, context: String?) -> GoogleTranslateParser.TranslationCategory {
        // If we have context information, categorize based on it
        if let context = context?.lowercased() {
            if context.contains("птах") || context.contains("тварина") || context.contains("об'єкт") {
                return .primary  // Noun context
            } else if context.contains("дія") || context.contains("дієслово") {
                return .alternative  // Verb context  
            } else if context.contains("формаль") || context.contains("офіцій") {
                return .formal
            } else if context.contains("розмов") || context.contains("неформал") {
                return .informal
            } else if context.contains("технічн") || context.contains("термін") {
                return .technical
            }
        }
        
        // Default categorization by position
        switch index {
        case 0:
            return .primary
        case 1:
            return .alternative
        case 2:
            return .synonym
        case 3:
            return .formal
        default:
            return .technical
        }
    }
    
    private func getConfidenceScore(for index: Int) -> Double {
        switch index {
        case 0:
            return 0.95
        case 1:
            return 0.90
        case 2:
            return 0.85
        case 3:
            return 0.80
        default:
            return 0.75
        }
    }
    
    private func getLanguageName(_ code: String) -> String {
        let languageNames: [String: String] = [
            "en": "English",
            "uk": "Ukrainian", 
            "ru": "Russian",
            "es": "Spanish",
            "fr": "French",
            "de": "German",
            "it": "Italian",
            "pt": "Portuguese",
            "zh": "Chinese",
            "ja": "Japanese",
            "ko": "Korean",
            "ar": "Arabic",
            "hi": "Hindi",
            "tr": "Turkish",
            "pl": "Polish",
            "nl": "Dutch",
            "sv": "Swedish",
            "da": "Danish",
            "no": "Norwegian",
            "fi": "Finnish",
            "cs": "Czech",
            "hu": "Hungarian",
            "ro": "Romanian",
            "bg": "Bulgarian",
            "hr": "Croatian",
            "sk": "Slovak",
            "sl": "Slovenian",
            "et": "Estonian",
            "lv": "Latvian",
            "lt": "Lithuanian"
        ]
        
        return languageNames[code] ?? code.uppercased()
    }
    
    private func getCurrentApiKey() -> String? {
        let keys = apiKeys
        guard !keys.isEmpty else { return nil }
        
        // Find active key
        for i in 0..<keys.count {
            let keyIndex = (currentKeyIndex + i) % keys.count
            let key = keys[keyIndex]
            let status = keyStatus[key] ?? .unknown
            
            if status == .active || status == .unknown {
                currentKeyIndex = keyIndex
                return key
            }
        }
        
        // Fallback to first key
        currentKeyIndex = 0
        return keys.first
    }
    
    private func markKeyAsActive(_ key: String) {
        keyStatus[key] = .active
    }
    
    private func markKeyAsRateLimited(_ key: String) {
        keyStatus[key] = .rateLimited
        if apiKeys.count > 1 {
            currentKeyIndex = (currentKeyIndex + 1) % apiKeys.count
        }
    }
    
    private func markKeyAsInvalid(_ key: String) {
        keyStatus[key] = .invalid
    }
    
    // MARK: - Usage Tracking
    
    private func recordUsage() {
        usageTracker.recordUsage()
        saveUsageTracker()
        
        // Update availability status  
        checkAvailability()
    }
    
    private func loadUsageTracker() {
        if let data = UserDefaults.standard.data(forKey: usageTrackerKey),
           let tracker = try? JSONDecoder().decode(GroqUsageTracker.self, from: data) {
            usageTracker = tracker
        }
    }
    
    private func saveUsageTracker() {
        if let data = try? JSONEncoder().encode(usageTracker) {
            UserDefaults.standard.set(data, forKey: usageTrackerKey)
        }
    }
    
    // MARK: - Public Interface
    
    var hasApiKeys: Bool {
        return !apiKeys.isEmpty
    }
    
    var statusMessage: String {
        let keys = apiKeys
        let tracker = usageTracker
        let available = isAvailable
        
        if isLoading {
            return "⚙️ AI перекладає..."
        } else if !keys.isEmpty && !tracker.canUseToday {
            return "❌ Ліміт вичерпано (\(tracker.remainingDailyUsage)/10)"
        } else if keys.isEmpty {
            return "⚠️ Немає API ключів"
        } else if available {
            return "✨ AI доступний (\(tracker.remainingDailyUsage)/10 залишилось)"
        } else {
            return "🔍 Перевіряємо доступність..."
        }
    }
    
    func resetDailyUsage() {
        usageTracker.dailyUsage = 0
        usageTracker.lastResetDate = Date()
        saveUsageTracker()
        checkAvailability()
    }
}

// MARK: - Groq Translation Errors
enum GroqTranslationError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case apiError(String)
    case noResponse
    case rateLimitExceeded
    case invalidApiKey
    case noValidApiKey
    case allKeysFailed
    case serviceUnavailable
    case dailyLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "invalid_url".localized
        case .invalidResponse:
            return "invalid_response".localized
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .apiError(let message):
            return "API error: \(message)"
        case .noResponse:
            return "no_ai_response".localized
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case .invalidApiKey:
            return "Invalid API key"
        case .noValidApiKey:
            return "No valid API key"
        case .allKeysFailed:
            return "All API keys failed"
        case .serviceUnavailable:
            return "ai_service_unavailable".localized
        case .dailyLimitExceeded:
            return "Daily limit exceeded"
        }
    }
}