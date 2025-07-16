import Foundation

enum TranslationError: Error, LocalizedError {
    case invalidURL
    case networkError
    case parsingError
    case noTranslationFound
    case noTranslationAvailable
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError:
            return "Network error occurred"
        case .parsingError:
            return "Failed to parse translation"
        case .noTranslationFound:
            return "No translation found"
        case .noTranslationAvailable:
            return "No translation method is currently available"
        }
    }
}

@MainActor
class GoogleTranslateParser: ObservableObject {
    // Google Translate API має обмеження ~5000 символів на запит
    private static let maxChunkSize = 4500
    
    func translate(text: String, from: String, to: String) async throws -> String {
        // Якщо текст короткий, перекладаємо одним запитом
        if text.count <= Self.maxChunkSize {
            return try await translateChunk(text: text, from: from, to: to)
        }
        
        // Для довгих текстів - розбиваємо на частини
        let chunks = Self.splitTextIntoChunks(text, maxSize: Self.maxChunkSize)
        var translatedChunks: [String] = []
        
        for chunk in chunks {
            let translated = try await translateChunk(text: chunk, from: from, to: to)
            translatedChunks.append(translated)
            
            // Невелика затримка між запитами щоб уникнути блокування
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 секунди
        }
        
        return translatedChunks.joined(separator: " ")
    }
    
    private func translateChunk(text: String, from: String, to: String) async throws -> String {
        let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=\(from)&tl=\(to)&dt=t&q=\(encodedText)"
        
        guard let url = URL(string: urlString) else {
            throw TranslationError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 8.0 // Reasonable timeout for normal use
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        
        // Create custom URLSession with balanced timeout configuration
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 8.0
        config.timeoutIntervalForResource = 8.0
        config.waitsForConnectivity = false
        config.allowsCellularAccess = true
        config.allowsExpensiveNetworkAccess = true // Allow for better translation
        config.allowsConstrainedNetworkAccess = false
        
        let session = URLSession(configuration: config)
        
        // Use TaskGroup to force cancellation after timeout
        return try await withThrowingTaskGroup(of: Data.self) { group in
            // Add the network request task
            group.addTask {
                let (data, _) = try await session.data(for: request)
                return data
            }
            
            // Add a timeout task that will cancel the request
            group.addTask {
                try await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds - enough for translation
                throw URLError(.timedOut)
            }
            
            // Wait for the first task to complete and cancel others
            guard let data = try await group.next() else {
                throw URLError(.timedOut)
            }
            
            group.cancelAll()
            
            // Parse JSON response
            guard let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any],
                  let firstArray = jsonArray.first as? [Any] else {
                throw TranslationError.parsingError
            }
            
            var translatedText = ""
            
            // Extract translated text from nested arrays
            for item in firstArray {
                if let textArray = item as? [Any],
                   textArray.count >= 2,
                   let translation = textArray[0] as? String {
                    translatedText += translation
                }
            }
            
            if translatedText.isEmpty {
                throw TranslationError.noTranslationFound
            }
            
            return translatedText
        }
    }
    
    private static func splitTextIntoChunks(_ text: String, maxSize: Int) -> [String] {
        var chunks: [String] = []
        var currentChunk = ""
        
        // Розбиваємо по реченнях для кращого перекладу
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        
        for sentence in sentences {
            let trimmedSentence = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedSentence.isEmpty { continue }
            
            // Додаємо крапку назад, якщо вона була
            let fullSentence = trimmedSentence + "."
            
            // Якщо речення саме по собі довше за максимум, розбиваємо по словах
            if fullSentence.count > maxSize {
                // Завершуємо поточний chunk
                if !currentChunk.isEmpty {
                    chunks.append(currentChunk.trimmingCharacters(in: .whitespacesAndNewlines))
                    currentChunk = ""
                }
                
                // Розбиваємо довге речення по словах
                let words = fullSentence.components(separatedBy: .whitespacesAndNewlines)
                var wordChunk = ""
                
                for word in words {
                    if wordChunk.count + word.count + 1 > maxSize {
                        if !wordChunk.isEmpty {
                            chunks.append(wordChunk.trimmingCharacters(in: .whitespacesAndNewlines))
                        }
                        wordChunk = word
                    } else {
                        wordChunk += (wordChunk.isEmpty ? "" : " ") + word
                    }
                }
                
                if !wordChunk.isEmpty {
                    chunks.append(wordChunk.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            } else if currentChunk.count + fullSentence.count + 1 > maxSize {
                // Поточний chunk + нове речення перевищує ліміт
                chunks.append(currentChunk.trimmingCharacters(in: .whitespacesAndNewlines))
                currentChunk = fullSentence
            } else {
                // Додаємо речення до поточного chunk
                currentChunk += (currentChunk.isEmpty ? "" : " ") + fullSentence
            }
        }
        
        // Додаємо останній chunk
        if !currentChunk.isEmpty {
            chunks.append(currentChunk.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        return chunks
    }
}