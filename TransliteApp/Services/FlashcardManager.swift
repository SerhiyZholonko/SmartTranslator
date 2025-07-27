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
//        createDefaultDeckIfNeeded()
        fixNewCardsReviewDates() // Fix existing cards with incorrect due dates
        performDataSanityCheck() // Additional safety check
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
    
    // MARK: - Public Access Methods
    
    func getAllDecks() -> [FlashcardDeck] {
        return decks
    }
    
    func deleteDeck(_ deckId: UUID) {
        guard let deckIndex = decks.firstIndex(where: { $0.id == deckId }) else { return }
        let deck = decks[deckIndex]
        
        // Remove all flashcards in this deck
        let flashcardIdsToRemove = Set(deck.flashcardIds)
        flashcards.removeAll { flashcardIdsToRemove.contains($0.id) }
        
        // Remove the deck
        decks.remove(at: deckIndex)
        
        saveFlashcards()
        saveDecks()
    }
    
    func updateCardAfterReview(_ card: Flashcard, difficulty: FlashcardDifficulty) {
        guard let cardIndex = flashcards.firstIndex(where: { $0.id == card.id }) else { return }
        
        var updatedCard = card
        var studyData = updatedCard.studyData
        
        // Update study data based on spaced repetition algorithm
        studyData.timesStudied += 1
        studyData.lastStudied = Date()
        
        switch difficulty {
        case .easy:
            studyData.correctAnswers += 1
            studyData.consecutiveCorrect += 1
            studyData.interval *= 2.5
            studyData.easeFactor = min(studyData.easeFactor + 0.15, 3.0)
        case .medium:
            studyData.correctAnswers += 1
            studyData.consecutiveCorrect += 1
            studyData.interval *= 2.0
        case .hard:
            studyData.incorrectAnswers += 1
            studyData.consecutiveCorrect = 0
            studyData.interval = max(studyData.interval * 0.8, 86400) // minimum 1 day
            studyData.easeFactor = max(studyData.easeFactor - 0.2, 1.3)
        }
        
        // Calculate next review date
        studyData.nextReviewDate = Date().addingTimeInterval(studyData.interval)
        
        updatedCard.studyData = studyData
        flashcards[cardIndex] = updatedCard
        
        saveFlashcards()
    }
    
    // MARK: - Deck Management
    
    func createDeck(name: String, description: String? = nil, sourceLanguage: String, targetLanguage: String) -> FlashcardDeck {
        let deck = FlashcardDeck(name: name, description: description, sourceLanguage: sourceLanguage, targetLanguage: targetLanguage)
        decks.append(deck)
        saveDecks()
        return deck
    }
    
    
    func addFlashcardToDeck(_ flashcard: Flashcard, deck: FlashcardDeck) -> Bool {
        guard let deckIndex = decks.firstIndex(where: { $0.id == deck.id }) else { return false }
        
        // Validate language pair matches deck's language pair
        if flashcard.sourceLanguage != deck.sourceLanguage || flashcard.targetLanguage != deck.targetLanguage {
            return false
        }
        
        if !flashcards.contains(where: { $0.id == flashcard.id }) {
            flashcards.append(flashcard)
        }
        
        if !decks[deckIndex].flashcardIds.contains(flashcard.id) {
            decks[deckIndex].flashcardIds.append(flashcard.id)
        }
        
        saveFlashcards()
        saveDecks()
        return true
    }
    
    private func createDefaultDeckIfNeeded() {
        if decks.isEmpty {
            let defaultDeck = createDeck(name: "my_first_deck".localized, description: "start_learning_description".localized, sourceLanguage: "en", targetLanguage: "uk")
            
            // Add some sample cards
            let sampleCards = [
                Flashcard(frontText: "Hello", backText: "Привіт", sourceLanguage: "en", targetLanguage: "uk", difficulty: .easy),
                Flashcard(frontText: "Thank you", backText: "Дякую", sourceLanguage: "en", targetLanguage: "uk", difficulty: .easy),
                Flashcard(frontText: "Good morning", backText: "Доброго ранку", sourceLanguage: "en", targetLanguage: "uk", difficulty: .medium)
            ]
            
            for card in sampleCards {
                _ = addFlashcardToDeck(card, deck: defaultDeck)
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
        
        // Get cards that are actually due for review (not new cards)
        let dueCards = deckFlashcards.filter { card in
            card.studyData.timesStudied > 0 && card.studyData.nextReviewDate <= now
        }
        
        // Add some new cards if we have fewer than 5 due cards
        let newCards = deckFlashcards.filter { $0.studyData.timesStudied == 0 }
        let newCardsToAdd = min(max(0, 5 - dueCards.count), newCards.count)
        let selectedNewCards = Array(newCards.prefix(newCardsToAdd))
        
        return dueCards + selectedNewCards
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
            if studyData.timesStudied == 1 {
                studyData.interval = 600 // 10 minutes for first study
            } else {
                studyData.interval = studyData.interval * 1.2
            }
            
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
            if studyData.timesStudied == 1 {
                studyData.interval = updatedCard.difficulty.initialInterval * 2
            } else {
                studyData.interval = studyData.interval * studyData.easeFactor * 1.3
            }
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
        // Safe calculation with bounds checking
        guard let deck = decks.first(where: { $0.id == deckId }) else { 
            print("⚠️ Deck not found: \(deckId)")
            return 0 
        }
        
        let deckFlashcards = flashcards.filter { deck.flashcardIds.contains($0.id) }
        
        // If no cards, return 0
        guard !deckFlashcards.isEmpty else {
            return 0
        }
        
        let now = Date()
        
        // Count only actually due cards (studied before and due now)
        let dueCards = deckFlashcards.filter { card in
            card.studyData.timesStudied > 0 && 
            card.studyData.nextReviewDate <= now &&
            card.studyData.nextReviewDate > Date.distantPast // Sanity check
        }
        
        // Add a few new cards if available and due cards are low
        let newCards = deckFlashcards.filter { $0.studyData.timesStudied == 0 }
        let newCardsToAdd = min(max(0, 3 - dueCards.count), newCards.count)
        
        let totalCount = dueCards.count + newCardsToAdd
        
        // Bounds checking - never return unreasonable numbers
        let safeCount = max(0, min(totalCount, deckFlashcards.count))
        
        // Additional safety check
        if safeCount > 100 {
            print("🚨 Suspicious count \(safeCount) for deck \(deck.name), capping at 10")
            return min(10, deckFlashcards.count)
        }
        
        if safeCount < 0 {
            print("🚨 Negative count detected, returning 0")
            return 0
        }
        
        return safeCount
    }
    
    // MARK: - Helper Functions
    
    func getFlashcardsForDeck(_ deck: FlashcardDeck) -> [Flashcard] {
        return flashcards.filter { deck.flashcardIds.contains($0.id) }
    }
    
    // Fix cards that were marked as due incorrectly
    func fixNewCardsReviewDates() {
        var updated = false
        var fixedCount = 0
        
        print("🔧 Running fixNewCardsReviewDates...")
        print("  - Total flashcards: \(flashcards.count)")
        
        for i in 0..<flashcards.count {
            if flashcards[i].studyData.timesStudied == 0 && 
               flashcards[i].studyData.nextReviewDate != Date.distantFuture {
                print("  - Fixing card: \(flashcards[i].frontText) (nextReviewDate was \(flashcards[i].studyData.nextReviewDate))")
                flashcards[i].studyData.nextReviewDate = Date.distantFuture
                updated = true
                fixedCount += 1
            }
        }
        
        print("  - Fixed \(fixedCount) cards")
        
        if updated {
            saveFlashcards()
            print("  - Saved changes")
        } else {
            print("  - No changes needed")
        }
        
        // Emergency fix: if we still have a huge number of due cards, reset all data
        for deck in decks {
            let count = getDueCardsCountDirect(for: deck.id)
            if count > 10000 { // Unreasonably high number
                print("🚨 Emergency fix: Resetting deck \(deck.name) due to corrupted data (count: \(count))")
                resetDeckStudyData(deckId: deck.id)
            }
        }
    }
    
    private func getDueCardsCountDirect(for deckId: UUID) -> Int {
        guard let deck = decks.first(where: { $0.id == deckId }) else { return 0 }
        let deckFlashcards = flashcards.filter { deck.flashcardIds.contains($0.id) }
        let now = Date()
        return deckFlashcards.filter { 
            $0.studyData.timesStudied > 0 && $0.studyData.nextReviewDate <= now 
        }.count
    }
    
    private func resetDeckStudyData(deckId: UUID) {
        guard let deck = decks.first(where: { $0.id == deckId }) else { return }
        
        for i in 0..<flashcards.count {
            if deck.flashcardIds.contains(flashcards[i].id) {
                flashcards[i].studyData = StudyData() // Reset to default
            }
        }
        saveFlashcards()
        print("  - Reset study data for deck")
    }
    
    // Sanity check for data corruption
    private func performDataSanityCheck() {
        print("🔍 Performing data sanity check...")
        
        var corruptedCards = 0
        var fixedCards = 0
        
        for i in 0..<flashcards.count {
            let card = flashcards[i]
            let studyData = card.studyData
            
            // Check for impossible values
            if studyData.timesStudied < 0 || 
               studyData.correctAnswers < 0 || 
               studyData.incorrectAnswers < 0 ||
               studyData.interval < 0 ||
               studyData.easeFactor < 1.0 || studyData.easeFactor > 4.0 ||
               studyData.consecutiveCorrect < 0 {
                
                print("  - Found corrupted card: \(card.frontText)")
                flashcards[i].studyData = StudyData()
                corruptedCards += 1
                fixedCards += 1
            }
            
            // Check for invalid dates
            if studyData.nextReviewDate < Date.distantPast ||
               studyData.nextReviewDate.timeIntervalSince1970 < 0 {
                print("  - Found invalid date in card: \(card.frontText)")
                flashcards[i].studyData.nextReviewDate = Date.distantFuture
                fixedCards += 1
            }
        }
        
        if corruptedCards > 0 {
            print("  - Found \(corruptedCards) corrupted cards, fixed \(fixedCards)")
            saveFlashcards()
        } else {
            print("  - All data looks good")
        }
    }
    
    // Public method to reset corrupted study data
    func resetAllStudyData() {
        print("🔄 Resetting all study data...")
        for i in 0..<flashcards.count {
            flashcards[i].studyData = StudyData()
        }
        saveFlashcards()
        print("  - All study data reset")
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
