import Foundation
import SwiftUI

class TranslationHistoryManager: ObservableObject {
    static let shared = TranslationHistoryManager()
    
    @Published var history: [TranslationHistoryItem] = []
    @Published var statistics: TranslationStatistics = .empty
    
    private let historyKey = "translationHistory"
    private let statisticsKey = "translationStatistics"
    private let maxHistoryItems = 1000
    
    private init() {
        // Defer loading to avoid blocking UI on startup
        Task {
            await MainActor.run {
                loadHistory()
                loadStatistics()
            }
        }
    }
    
    // MARK: - History Management
    
    func addTranslation(_ item: TranslationHistoryItem) {
        history.insert(item, at: 0)
        
        // Limit history size
        if history.count > maxHistoryItems {
            history = Array(history.prefix(maxHistoryItems))
        }
        
        updateStatistics(for: item)
        saveHistory()
    }
    
    func toggleFavorite(for id: UUID) {
        guard let index = history.firstIndex(where: { $0.id == id }) else { return }
        
        var updatedItem = history[index]
        updatedItem = TranslationHistoryItem(
            sourceText: updatedItem.sourceText,
            translatedText: updatedItem.translatedText,
            sourceLanguage: updatedItem.sourceLanguage,
            targetLanguage: updatedItem.targetLanguage,
            alternatives: updatedItem.alternatives,
            corrections: updatedItem.corrections,
            isFavorite: !updatedItem.isFavorite
        )
        
        history[index] = updatedItem
        
        if updatedItem.isFavorite {
            statistics.favoriteCount += 1
        } else {
            statistics.favoriteCount -= 1
        }
        
        saveHistory()
        saveStatistics()
    }
    
    func deleteItem(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
        saveHistory()
    }
    
    func clearHistory() {
        history.removeAll()
        statistics = .empty
        saveHistory()
        saveStatistics()
    }
    
    // MARK: - Search and Filter
    
    func searchHistory(query: String) -> [TranslationHistoryItem] {
        guard !query.isEmpty else { return history }
        
        let lowercasedQuery = query.lowercased()
        return history.filter { item in
            item.sourceText.lowercased().contains(lowercasedQuery) ||
            item.translatedText.lowercased().contains(lowercasedQuery)
        }
    }
    
    func getFavorites() -> [TranslationHistoryItem] {
        return history.filter { $0.isFavorite }
    }
    
    func getHistoryByLanguagePair(source: String, target: String) -> [TranslationHistoryItem] {
        return history.filter { $0.sourceLanguage == source && $0.targetLanguage == target }
    }
    
    // MARK: - Learning Insights
    
    func getMostFrequentPhrases(limit: Int = 10) -> [(phrase: String, count: Int)] {
        let phrases = history.map { $0.sourceText.lowercased() }
        let frequency = Dictionary(phrases.map { ($0, 1) }, uniquingKeysWith: +)
        return frequency.sorted { $0.value > $1.value }.prefix(limit).map { ($0.key, $0.value) }
    }
    
    func getLearningSuggestions() -> [LearningSuggestion] {
        var suggestions: [LearningSuggestion] = []
        
        // Analyze recent translations for patterns
        let recentTranslations = Array(history.prefix(50))
        
        for item in recentTranslations {
            // Grammar corrections
            if !item.corrections.isEmpty {
                for correction in item.corrections {
                    suggestions.append(LearningSuggestion(
                        originalText: item.sourceText,
                        improvedText: correction,
                        explanation: "Grammar improvement suggestion",
                        category: .grammar
                    ))
                }
            }
            
            // Style suggestions based on alternatives
            if !item.alternatives.isEmpty && item.alternatives.first != item.translatedText {
                suggestions.append(LearningSuggestion(
                    originalText: item.translatedText,
                    improvedText: item.alternatives.first!,
                    explanation: "Alternative translation with different style",
                    category: .style
                ))
            }
        }
        
        return Array(suggestions.prefix(5))
    }
    
    // MARK: - Statistics
    
    private func updateStatistics(for item: TranslationHistoryItem) {
        statistics.totalTranslations += 1
        
        let languagePair = "\(item.sourceLanguage)-\(item.targetLanguage)"
        statistics.languagePairs[languagePair, default: 0] += 1
        
        let phrase = item.sourceText.lowercased()
        statistics.mostUsedPhrases[phrase, default: 0] += 1
        
        // Update average text length
        let currentTotal = statistics.averageTextLength * Double(statistics.totalTranslations - 1)
        statistics.averageTextLength = (currentTotal + Double(item.sourceText.count)) / Double(statistics.totalTranslations)
        
        saveStatistics()
    }
    
    // MARK: - Persistence
    
    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let decoded = try? JSONDecoder().decode([TranslationHistoryItem].self, from: data) else {
            return
        }
        history = decoded
    }
    
    private func saveHistory() {
        guard let encoded = try? JSONEncoder().encode(history) else { return }
        UserDefaults.standard.set(encoded, forKey: historyKey)
    }
    
    private func loadStatistics() {
        guard let data = UserDefaults.standard.data(forKey: statisticsKey),
              let decoded = try? JSONDecoder().decode(TranslationStatistics.self, from: data) else {
            return
        }
        statistics = decoded
    }
    
    private func saveStatistics() {
        guard let encoded = try? JSONEncoder().encode(statistics) else { return }
        UserDefaults.standard.set(encoded, forKey: statisticsKey)
    }
}
