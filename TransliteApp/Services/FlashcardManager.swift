import Foundation
import SwiftUI

class FlashcardManager: ObservableObject {
    static let shared = FlashcardManager()
    
    @Published var flashcards: [Flashcard] = []
    @Published var decks: [FlashcardDeck] = []
    @Published var studySessions: [StudySession] = []
    
    private let flashcardsKey = "flashcards"
    private let decksKey = "flashcardDecks"
    private let sessionsKey = "studySessions"
    
    private init() {
        loadData()
        createDefaultDeckIfNeeded()
    }
    
    // MARK: - Data Management
    
    private func loadData() {
        loadFlashcards()
        loadDecks()
        loadStudySessions()
    }
    
    private func loadFlashcards() {
        guard let data = UserDefaults.standard.data(forKey: flashcardsKey),
              let decoded = try? JSONDecoder().decode([Flashcard].self, from: data) else {
            return
        }
        flashcards = decoded
    }
    
    private func saveFlashcards() {
        guard let encoded = try? JSONEncoder().encode(flashcards) else { return }
        UserDefaults.standard.set(encoded, forKey: flashcardsKey)
    }
    
    private func loadDecks() {
        guard let data = UserDefaults.standard.data(forKey: decksKey),
              let decoded = try? JSONDecoder().decode([FlashcardDeck].self, from: data) else {
            return
        }
        decks = decoded
    }
    
    private func saveDecks() {
        guard let encoded = try? JSONEncoder().encode(decks) else { return }
        UserDefaults.standard.set(encoded, forKey: decksKey)
    }
    
    private func loadStudySessions() {
        guard let data = UserDefaults.standard.data(forKey: sessionsKey),
              let decoded = try? JSONDecoder().decode([StudySession].self, from: data) else {
            return
        }
        studySessions = decoded
    }
    
    private func saveStudySessions() {
        guard let encoded = try? JSONEncoder().encode(studySessions) else { return }
        UserDefaults.standard.set(encoded, forKey: sessionsKey)
    }
    
    // MARK: - Deck Management
    
    func createDeck(name: String, description: String = "", sourceLanguage: String, targetLanguage: String) -> FlashcardDeck {
        let deck = FlashcardDeck(name: name, description: description, sourceLanguage: sourceLanguage, targetLanguage: targetLanguage)
        decks.append(deck)
        saveDecks()
        return deck
    }
    
    func deleteDeck(_ deck: FlashcardDeck) {
        // Remove all flashcards in this deck
        let flashcardIdsToRemove = Set(deck.flashcardIds)
        flashcards.removeAll { flashcardIdsToRemove.contains($0.id) }
        
        // Remove the deck
        decks.removeAll { $0.id == deck.id }
        
        saveFlashcards()
        saveDecks()
    }
    
    func addFlashcardToDeck(_ flashcard: Flashcard, deck: FlashcardDeck) {
        guard let deckIndex = decks.firstIndex(where: { $0.id == deck.id }) else { return }
        
        if !flashcards.contains(where: { $0.id == flashcard.id }) {
            flashcards.append(flashcard)
        }
        
        if !decks[deckIndex].flashcardIds.contains(flashcard.id) {
            decks[deckIndex].flashcardIds.append(flashcard.id)
        }
        
        saveFlashcards()
        saveDecks()
    }
    
    private func createDefaultDeckIfNeeded() {
        if decks.isEmpty {
            let defaultDeck = createDeck(name: "My First Deck", description: "Start learning with your first flashcards", sourceLanguage: "en", targetLanguage: "uk")
            
            // Add some sample cards
            let sampleCards = [
                Flashcard(frontText: "Hello", backText: "Привіт", sourceLanguage: "en", targetLanguage: "uk", difficulty: .easy),
                Flashcard(frontText: "Thank you", backText: "Дякую", sourceLanguage: "en", targetLanguage: "uk", difficulty: .easy),
                Flashcard(frontText: "Good morning", backText: "Доброго ранку", sourceLanguage: "en", targetLanguage: "uk", difficulty: .medium)
            ]
            
            for card in sampleCards {
                addFlashcardToDeck(card, deck: defaultDeck)
            }
        }
    }
    
    // MARK: - Flashcard Management
    
    func createFlashcard(frontText: String, backText: String, sourceLanguage: String, targetLanguage: String, category: String? = nil, difficulty: FlashcardDifficulty = .medium) -> Flashcard {
        let flashcard = Flashcard(frontText: frontText, backText: backText, sourceLanguage: sourceLanguage, targetLanguage: targetLanguage, category: category, difficulty: difficulty)
        flashcards.append(flashcard)
        saveFlashcards()
        return flashcard
    }
    
    func createFlashcardFromTranslation(_ item: TranslationHistoryItem) -> Flashcard {
        let flashcard = Flashcard(
            frontText: item.sourceText,
            backText: item.translatedText,
            sourceLanguage: item.sourceLanguage,
            targetLanguage: item.targetLanguage,
            category: "From Translation"
        )
        flashcards.append(flashcard)
        saveFlashcards()
        return flashcard
    }
    
    func updateFlashcard(_ flashcard: Flashcard) {
        guard let index = flashcards.firstIndex(where: { $0.id == flashcard.id }) else { return }
        flashcards[index] = flashcard
        saveFlashcards()
    }
    
    func deleteFlashcard(_ flashcard: Flashcard) {
        flashcards.removeAll { $0.id == flashcard.id }
        
        // Remove from all decks
        for deckIndex in decks.indices {
            decks[deckIndex].flashcardIds.removeAll { $0 == flashcard.id }
        }
        
        saveFlashcards()
        saveDecks()
    }
    
    // MARK: - Study System with Spaced Repetition
    
    func getCardsForStudy(deckId: UUID) -> [Flashcard] {
        guard let deck = decks.first(where: { $0.id == deckId }) else { return [] }
        
        let deckFlashcards = flashcards.filter { deck.flashcardIds.contains($0.id) }
        let now = Date()
        
        // Get cards that are due for review
        let dueCards = deckFlashcards.filter { card in
            card.studyData.nextReviewDate <= now
        }
        
        // If no due cards, return new cards or least recently studied
        if dueCards.isEmpty {
            let newCards = deckFlashcards.filter { $0.studyData.timesStudied == 0 }
            if !newCards.isEmpty {
                return Array(newCards.prefix(10)) // Limit new cards
            }
            
            // Return least recently studied cards
            return Array(deckFlashcards.sorted { 
                ($0.studyData.lastStudied ?? Date.distantPast) < ($1.studyData.lastStudied ?? Date.distantPast)
            }.prefix(10))
        }
        
        return dueCards
    }
    
    func recordStudyResult(_ flashcard: Flashcard, result: StudyResult) {
        guard let index = flashcards.firstIndex(where: { $0.id == flashcard.id }) else { return }
        
        var updatedCard = flashcards[index]
        var studyData = updatedCard.studyData
        
        studyData.timesStudied += 1
        studyData.lastStudied = Date()
        
        switch result {
        case .again:
            studyData.incorrectAnswers += 1
            studyData.consecutiveCorrect = 0
            studyData.easeFactor = max(1.3, studyData.easeFactor - 0.2)
            studyData.interval = 600 // 10 minutes
            
        case .hard:
            studyData.correctAnswers += 1
            studyData.consecutiveCorrect += 1
            studyData.easeFactor = max(1.3, studyData.easeFactor - 0.15)
            studyData.interval = studyData.interval * 1.2
            
        case .good:
            studyData.correctAnswers += 1
            studyData.consecutiveCorrect += 1
            if studyData.timesStudied == 1 {
                studyData.interval = updatedCard.difficulty.initialInterval
            } else {
                studyData.interval = studyData.interval * studyData.easeFactor
            }
            
        case .easy:
            studyData.correctAnswers += 1
            studyData.consecutiveCorrect += 1
            studyData.easeFactor = min(2.5, studyData.easeFactor + 0.15)
            studyData.interval = studyData.interval * studyData.easeFactor * 1.3
        }
        
        studyData.nextReviewDate = Date().addingTimeInterval(studyData.interval)
        updatedCard.studyData = studyData
        flashcards[index] = updatedCard
        
        saveFlashcards()
    }
    
    // MARK: - Study Sessions
    
    func startStudySession(deckId: UUID) -> StudySession {
        let session = StudySession(deckId: deckId)
        studySessions.append(session)
        return session
    }
    
    func updateStudySession(_ session: StudySession) {
        guard let index = studySessions.firstIndex(where: { $0.id == session.id }) else { return }
        studySessions[index] = session
        saveStudySessions()
    }
    
    func endStudySession(_ session: StudySession) {
        guard let index = studySessions.firstIndex(where: { $0.id == session.id }) else { return }
        var updatedSession = session
        updatedSession.endTime = Date()
        updatedSession.totalTimeSpent = Date().timeIntervalSince(session.startTime)
        studySessions[index] = updatedSession
        
        // Update deck's last studied date
        if let deckIndex = decks.firstIndex(where: { $0.id == session.deckId }) {
            decks[deckIndex].lastStudied = Date()
            saveDecks()
        }
        
        saveStudySessions()
    }
    
    // MARK: - Statistics
    
    func getStudyStatistics(for deckId: UUID) -> (totalCards: Int, studiedCards: Int, averageSuccessRate: Double, totalStudyTime: TimeInterval) {
        guard let deck = decks.first(where: { $0.id == deckId }) else {
            return (0, 0, 0.0, 0)
        }
        
        let deckFlashcards = flashcards.filter { deck.flashcardIds.contains($0.id) }
        let studiedCards = deckFlashcards.filter { $0.studyData.timesStudied > 0 }
        
        let totalSuccessRate = studiedCards.reduce(0.0) { $0 + $1.studyData.successRate }
        let averageSuccessRate = studiedCards.isEmpty ? 0.0 : totalSuccessRate / Double(studiedCards.count)
        
        let deckSessions = studySessions.filter { $0.deckId == deckId && $0.endTime != nil }
        let totalStudyTime = deckSessions.reduce(0.0) { $0 + $1.totalTimeSpent }
        
        return (deckFlashcards.count, studiedCards.count, averageSuccessRate, totalStudyTime)
    }
    
    func getDueCardsCount(for deckId: UUID) -> Int {
        return getCardsForStudy(deckId: deckId).count
    }
    
    // MARK: - Helper Functions
    
    func getFlashcardsForDeck(_ deck: FlashcardDeck) -> [Flashcard] {
        return flashcards.filter { deck.flashcardIds.contains($0.id) }
    }
    
    func searchFlashcards(query: String) -> [Flashcard] {
        guard !query.isEmpty else { return flashcards }
        
        let lowercasedQuery = query.lowercased()
        return flashcards.filter { card in
            card.frontText.lowercased().contains(lowercasedQuery) ||
            card.backText.lowercased().contains(lowercasedQuery) ||
            card.category?.lowercased().contains(lowercasedQuery) == true
        }
    }
}