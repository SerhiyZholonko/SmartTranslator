import SwiftUI
import Combine

@MainActor
final class FlashcardsViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var decks: [FlashcardDeck] = []
    @Published var selectedDeck: FlashcardDeck?
    @Published var showCreateDeck = false
    @Published var showAddCard = false
    @Published var showStudyView = false
    @Published var searchText = ""
    @Published var sortOption: SortOption = .dateCreated
    
    // MARK: - Services
    private let flashcardManager = FlashcardManager.shared
    
    // MARK: - Computed Properties
    var filteredDecks: [FlashcardDeck] {
        let filtered = searchText.isEmpty ? decks : decks.filter { deck in
            deck.name.localizedCaseInsensitiveContains(searchText) ||
            deck.description?.localizedCaseInsensitiveContains(searchText) == true
        }
        
        return sorted(decks: filtered)
    }
    
    var totalCards: Int {
        decks.reduce(0) { $0 + $1.cards.count }
    }
    
    var cardsToReview: Int {
        decks.reduce(0) { total, deck in
            total + deck.cards.filter { $0.isDueForReview }.count
        }
    }
    
    override init() {
        super.init()
        loadDecks()
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Listen for deck updates
        NotificationCenter.default.publisher(for: .flashcardsUpdated)
            .sink { [weak self] _ in
                self?.loadDecks()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func loadDecks() {
        decks = flashcardManager.getAllDecks()
    }
    
    func createDeck(name: String, description: String?, sourceLanguage: String, targetLanguage: String) {
        let deck = flashcardManager.createDeck(
            name: name,
            description: description,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage
        )
        
        selectedDeck = deck
        loadDecks()
        showCreateDeck = false
    }
    
    func deleteDeck(_ deck: FlashcardDeck) {
        flashcardManager.deleteDeck(deck.id)
        if selectedDeck?.id == deck.id {
            selectedDeck = nil
        }
        loadDecks()
    }
    
    func selectDeck(_ deck: FlashcardDeck) {
        selectedDeck = deck
    }
    
    func startStudying(_ deck: FlashcardDeck) {
        guard !deck.cards.isEmpty else {
            showError("no_cards_in_deck".localized)
            return
        }
        
        selectedDeck = deck
        showStudyView = true
    }
    
    func changeSortOption(_ option: SortOption) {
        sortOption = option
    }
    
    // MARK: - Private Methods
    private func sorted(decks: [FlashcardDeck]) -> [FlashcardDeck] {
        switch sortOption {
        case .dateCreated:
            return decks.sorted { $0.createdAt > $1.createdAt }
        case .name:
            return decks.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .cardCount:
            return decks.sorted { $0.cards.count > $1.cards.count }
        case .dueCards:
            return decks.sorted { deck1, deck2 in
                let due1 = deck1.cards.filter { $0.isDueForReview }.count
                let due2 = deck2.cards.filter { $0.isDueForReview }.count
                return due1 > due2
            }
        }
    }
}

// MARK: - Sort Options
enum SortOption: String, CaseIterable {
    case dateCreated = "date_created"
    case name = "name"
    case cardCount = "card_count"
    case dueCards = "due_cards"
    
    var localizedTitle: String {
        rawValue.localized
    }
}

// MARK: - Deck Card ViewModel
@MainActor
final class DeckCardViewModel: ObservableObject {
    @Published var deck: FlashcardDeck
    
    var cardsDue: Int {
        deck.cards.filter { $0.isDueForReview }.count
    }
    
    var progress: Double {
        guard !deck.cards.isEmpty else { return 0 }
        let learned = deck.cards.filter { $0.difficulty == .easy }.count
        return Double(learned) / Double(deck.cards.count)
    }
    
    init(deck: FlashcardDeck) {
        self.deck = deck
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let flashcardsUpdated = Notification.Name("flashcardsUpdated")
}