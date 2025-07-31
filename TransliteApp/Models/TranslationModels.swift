import Foundation

// MARK: - Translation History

struct TranslationHistoryItem: Codable, Identifiable {
    let id: UUID
    let sourceText: String
    let translatedText: String
    let sourceLanguage: String
    let targetLanguage: String
    let timestamp: Date
    let isFavorite: Bool
    let alternatives: [String]
    let corrections: [String]
    
    var idString: String {
        return id.uuidString
    }
    
    init(sourceText: String,
         translatedText: String,
         sourceLanguage: String,
         targetLanguage: String,
         alternatives: [String] = [],
         corrections: [String] = [],
         isFavorite: Bool = false) {
        self.id = UUID()
        self.sourceText = sourceText
        self.translatedText = translatedText
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.timestamp = Date()
        self.alternatives = alternatives
        self.corrections = corrections
        self.isFavorite = isFavorite
    }
    
    // Initializer to preserve existing id and timestamp when modifying properties
    init(id: UUID,
         sourceText: String,
         translatedText: String,
         sourceLanguage: String,
         targetLanguage: String,
         timestamp: Date,
         alternatives: [String] = [],
         corrections: [String] = [],
         isFavorite: Bool = false) {
        self.id = id
        self.sourceText = sourceText
        self.translatedText = translatedText
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.timestamp = timestamp
        self.alternatives = alternatives
        self.corrections = corrections
        self.isFavorite = isFavorite
    }
}

// MARK: - Smart Cache

struct CachedTranslation: Codable {
    let key: String // Combined key: "sourceLanguage-targetLanguage-tone-style-text"
    let translation: String
    let alternatives: [String]
    let corrections: [String]
    let frequency: Int
    let lastAccessed: Date
    let compressed: Bool
    
    static func generateKey(text: String, sourceLanguage: String, targetLanguage: String) -> String {
        let normalizedText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(sourceLanguage)-\(targetLanguage)-\(normalizedText)"
    }
}

// MARK: - User Preferences

struct UserPreferences: Codable {
    var defaultSourceLanguage: String
    var defaultTargetLanguage: String
    var autoDetectLanguage: Bool
    var saveHistory: Bool
    var enableSmartCache: Bool
    var cacheSize: Int // in MB
    var favoritePhases: [FavoritePhrase]
    
    static let `default` = UserPreferences(
        defaultSourceLanguage: "auto",
        defaultTargetLanguage: "en",
        autoDetectLanguage: true,
        saveHistory: true,
        enableSmartCache: true,
        cacheSize: 50,
        favoritePhases: []
    )
}

struct FavoritePhrase: Codable, Identifiable {
    let id: UUID
    let phrase: String
    let translation: String
    let sourceLanguage: String
    let targetLanguage: String
    let category: String?
    
    init(phrase: String, translation: String, sourceLanguage: String, targetLanguage: String, category: String? = nil) {
        self.id = UUID()
        self.phrase = phrase
        self.translation = translation
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.category = category
    }
}

// MARK: - Learning Suggestions

struct LearningSuggestion: Identifiable {
    let id: UUID
    let originalText: String
    let improvedText: String
    let explanation: String
    let category: SuggestionCategory
    let confidence: Double
    
    init(originalText: String, improvedText: String, explanation: String, category: SuggestionCategory, confidence: Double = 0.8) {
        self.id = UUID()
        self.originalText = originalText
        self.improvedText = improvedText
        self.explanation = explanation
        self.category = category
        self.confidence = confidence
    }
}

enum SuggestionCategory: String, CaseIterable {
    case grammar = "Grammar"
    case vocabulary = "Vocabulary"
    case idiom = "Idiom"
    case style = "Style"
    case tone = "Tone"
}

// MARK: - Translation Statistics

struct TranslationStatistics: Codable {
    var totalTranslations: Int
    var languagePairs: [String: Int] // "en-uk": 42
    var mostUsedPhrases: [String: Int]
    var averageTextLength: Double
    var favoriteCount: Int
    var lastResetDate: Date
    
    static let empty = TranslationStatistics(
        totalTranslations: 0,
        languagePairs: [:],
        mostUsedPhrases: [:],
        averageTextLength: 0,
        favoriteCount: 0,
        lastResetDate: Date()
    )
}

// MARK: - Flashcards for Language Learning

struct Flashcard: Codable, Identifiable {
    let id: UUID
    let frontText: String
    let backText: String
    let sourceLanguage: String
    let targetLanguage: String
    let category: String?
    let difficulty: FlashcardDifficulty
    let createdDate: Date
    var studyData: StudyData
    
    var isDueForReview: Bool {
        return studyData.nextReviewDate <= Date()
    }
    
    var idString: String {
        return id.uuidString
    }
    
    init(frontText: String,
         backText: String,
         sourceLanguage: String,
         targetLanguage: String,
         category: String? = nil,
         difficulty: FlashcardDifficulty = .medium) {
        self.id = UUID()
        self.frontText = frontText
        self.backText = backText
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.category = category
        self.difficulty = difficulty
        self.createdDate = Date()
        self.studyData = StudyData()
    }
}

enum FlashcardDifficulty: String, CaseIterable, Codable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    
    var displayName: String {
        switch self {
        case .easy: return "difficulty_easy".localized
        case .medium: return "difficulty_medium".localized
        case .hard: return "difficulty_hard".localized
        }
    }
    
    var initialInterval: TimeInterval {
        switch self {
        case .easy: return 86400 * 4 // 4 days
        case .medium: return 86400 * 1 // 1 day
        case .hard: return 3600 * 10 // 10 hours
        }
    }
}

struct StudyData: Codable {
    var timesStudied: Int
    var correctAnswers: Int
    var incorrectAnswers: Int
    var lastStudied: Date?
    var nextReviewDate: Date
    var interval: TimeInterval
    var easeFactor: Double
    var consecutiveCorrect: Int
    
    init() {
        self.timesStudied = 0
        self.correctAnswers = 0
        self.incorrectAnswers = 0
        self.lastStudied = nil
        self.nextReviewDate = Date.distantFuture // Don't mark new cards as due
        self.interval = 86400 // 1 day
        self.easeFactor = 2.5
        self.consecutiveCorrect = 0
    }
    
    var successRate: Double {
        let total = correctAnswers + incorrectAnswers
        return total > 0 ? Double(correctAnswers) / Double(total) : 0.0
    }
}

enum StudyResult: String, CaseIterable {
    case again = "again"
    case hard = "hard"
    case good = "good"
    case easy = "easy"
    
    var displayName: String {
        switch self {
        case .again: return "study_again".localized
        case .hard: return "study_hard".localized
        case .good: return "study_good".localized
        case .easy: return "study_easy".localized
        }
    }
    
    var color: String {
        switch self {
        case .again: return "red"
        case .hard: return "orange"
        case .good: return "green"
        case .easy: return "blue"
        }
    }
}

struct FlashcardDeck: Codable, Identifiable {
    let id: UUID
    var name: String
    var description: String?
    let sourceLanguage: String
    let targetLanguage: String
    var flashcardIds: [UUID]
    var cards: [Flashcard]
    let createdAt: Date
    var lastStudied: Date?
    
    init(name: String,
         description: String? = nil,
         sourceLanguage: String,
         targetLanguage: String) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.flashcardIds = []
        self.cards = []
        self.createdAt = Date()
        self.lastStudied = nil
    }
}

struct StudySession: Codable, Identifiable {
    let id: UUID
    let deckId: UUID
    let startTime: Date
    var endTime: Date?
    var cardsStudied: Int
    var correctAnswers: Int
    var totalTimeSpent: TimeInterval
    
    init(deckId: UUID) {
        self.id = UUID()
        self.deckId = deckId
        self.startTime = Date()
        self.endTime = nil
        self.cardsStudied = 0
        self.correctAnswers = 0
        self.totalTimeSpent = 0
    }
    
    var accuracy: Double {
        return cardsStudied > 0 ? Double(correctAnswers) / Double(cardsStudied) : 0.0
    }
}