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
    
    private let baseURL = "https://translate.googleapis.com/translate_a/single"
    private let maxTextLength = 4500 // Google's limit
    
    func translate(text: String, from sourceLanguage: String = "auto", to targetLanguage: String) async throws -> String {
        guard !text.isEmpty else { return "" }
        
        // Handle text that's too long by chunking
        if text.count > maxTextLength {
            return try await translateLongText(text: text, from: sourceLanguage, to: targetLanguage)
        }
        
        return try await performTranslation(text: text, from: sourceLanguage, to: targetLanguage)
    }
    
    private func performTranslation(text: String, from sourceLanguage: String, to targetLanguage: String) async throws -> String {
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
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any],
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
    
    private func translateLongText(text: String, from sourceLanguage: String, to targetLanguage: String) async throws -> String {
        let chunks = splitIntoChunks(text: text, maxLength: maxTextLength)
        var translatedChunks: [String] = []
        
        for chunk in chunks {
            let translatedChunk = try await performTranslation(text: chunk, from: sourceLanguage, to: targetLanguage)
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
}