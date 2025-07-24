import SwiftUI
import AVFoundation

@MainActor
final class StudyViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var currentCard: Flashcard?
    @Published var currentIndex = 0
    @Published var showAnswer = false
    @Published var isComplete = false
    @Published var progress: Double = 0
    @Published var sessionStats = SessionStats()
    
    // MARK: - Properties
    let deck: FlashcardDeck
    private var studyCards: [Flashcard] = []
    private let flashcardManager = FlashcardManager.shared
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    // MARK: - Computed Properties
    var progressText: String {
        "\(currentIndex + 1) / \(studyCards.count)"
    }
    
    init(deck: FlashcardDeck) {
        self.deck = deck
        super.init()
        setupStudySession()
    }
    
    // MARK: - Setup
    private func setupStudySession() {
        // Get cards that are due for review
        studyCards = deck.cards.filter { $0.isDueForReview }
        
        // If no cards are due, study all cards
        if studyCards.isEmpty {
            studyCards = deck.cards
        }
        
        // Shuffle cards for better learning
        studyCards.shuffle()
        
        // Set first card
        if !studyCards.isEmpty {
            currentCard = studyCards[0]
            updateProgress()
        } else {
            isComplete = true
        }
    }
    
    // MARK: - Public Methods
    func flipCard() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showAnswer.toggle()
        }
        
        if showAnswer {
            sessionStats.cardsViewed += 1
        }
    }
    
    func rateCard(_ difficulty: FlashcardDifficulty) {
        guard let card = currentCard else { return }
        
        // Update card with spaced repetition
        flashcardManager.updateCardAfterReview(card, difficulty: difficulty)
        
        // Update stats
        updateSessionStats(for: difficulty)
        
        // Move to next card
        nextCard()
    }
    
    func nextCard() {
        guard currentIndex < studyCards.count - 1 else {
            completeSession()
            return
        }
        
        currentIndex += 1
        currentCard = studyCards[currentIndex]
        showAnswer = false
        updateProgress()
    }
    
    func previousCard() {
        guard currentIndex > 0 else { return }
        
        currentIndex -= 1
        currentCard = studyCards[currentIndex]
        showAnswer = false
        updateProgress()
    }
    
    func speakText(_ text: String, language: String) {
        speechSynthesizer.stopSpeaking(at: .immediate)
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.5
        
        speechSynthesizer.speak(utterance)
    }
    
    func skipCard() {
        nextCard()
    }
    
    // MARK: - Private Methods
    private func updateProgress() {
        guard !studyCards.isEmpty else { return }
        progress = Double(currentIndex + 1) / Double(studyCards.count)
    }
    
    private func updateSessionStats(for difficulty: FlashcardDifficulty) {
        switch difficulty {
        case .easy:
            sessionStats.cardsEasy += 1
        case .medium:
            sessionStats.cardsGood += 1
        case .hard:
            sessionStats.cardsHard += 1
        }
    }
    
    private func completeSession() {
        sessionStats.totalCards = studyCards.count
        sessionStats.completionTime = Date()
        isComplete = true
        
        // Post notification to update deck statistics
        NotificationCenter.default.post(name: .flashcardsUpdated, object: nil)
    }
    
    deinit {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
}

// MARK: - Session Statistics
struct SessionStats {
    var totalCards = 0
    var cardsViewed = 0
    var cardsHard = 0
    var cardsGood = 0
    var cardsEasy = 0
    var startTime = Date()
    var completionTime: Date?
    
    var accuracy: Double {
        guard cardsViewed > 0 else { return 0 }
        let correct = cardsGood + cardsEasy
        return Double(correct) / Double(cardsViewed)
    }
    
    var studyDuration: TimeInterval {
        guard let completion = completionTime else {
            return Date().timeIntervalSince(startTime)
        }
        return completion.timeIntervalSince(startTime)
    }
    
    var formattedDuration: String {
        let minutes = Int(studyDuration) / 60
        let seconds = Int(studyDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}