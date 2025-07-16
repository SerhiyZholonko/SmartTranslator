import SwiftUI
import Foundation

struct FlashcardsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var flashcardManager = FlashcardManager.shared
    @State private var selectedDeck: FlashcardDeck?
    @State private var showingCreateDeck = false
    @State private var showingStudyView = false
    @State private var newDeckName = ""
    @State private var newDeckDescription = ""
    @State private var newDeckSourceLang = "en"
    @State private var newDeckTargetLang = "uk"
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Language Learning")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Study flashcards to improve your vocabulary")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Create New Deck Button
                    Button(action: { showingCreateDeck = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            
                            Text("Create New Deck")
                                .font(.headline)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Decks List
                    ForEach(flashcardManager.decks) { deck in
                        DeckCard(deck: deck) {
                            selectedDeck = deck
                            showingStudyView = true
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCreateDeck) {
                CreateDeckView(
                    deckName: $newDeckName,
                    deckDescription: $newDeckDescription,
                    sourceLang: $newDeckSourceLang,
                    targetLang: $newDeckTargetLang
                ) {
                    let _ = flashcardManager.createDeck(
                        name: newDeckName,
                        description: newDeckDescription,
                        sourceLanguage: newDeckSourceLang,
                        targetLanguage: newDeckTargetLang
                    )
                    newDeckName = ""
                    newDeckDescription = ""
                    showingCreateDeck = false
                }
            }
            .sheet(isPresented: $showingStudyView) {
                if let deck = selectedDeck {
                    StudyView(deck: deck)
                }
            }
        }
    }
}

struct DeckCard: View {
    let deck: FlashcardDeck
    let onTap: () -> Void
    @StateObject private var flashcardManager = FlashcardManager.shared
    
    var deckStats: (totalCards: Int, studiedCards: Int, averageSuccessRate: Double, totalStudyTime: TimeInterval) {
        flashcardManager.getStudyStatistics(for: deck.id)
    }
    
    var dueCardsCount: Int {
        flashcardManager.getDueCardsCount(for: deck.id)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(deck.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if !deck.description.isEmpty {
                            Text(deck.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(languageName(deck.sourceLanguage)) → \(languageName(deck.targetLanguage))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if dueCardsCount > 0 {
                            Text("\(dueCardsCount) due")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
                
                // Statistics
                HStack(spacing: 20) {
                    StatItem(
                        icon: "square.stack.3d.up",
                        title: "Cards",
                        value: "\(deckStats.totalCards)"
                    )
                    
                    StatItem(
                        icon: "checkmark.circle",
                        title: "Studied",
                        value: "\(deckStats.studiedCards)"
                    )
                    
                    if deckStats.studiedCards > 0 {
                        StatItem(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Success",
                            value: "\(Int(deckStats.averageSuccessRate * 100))%"
                        )
                    }
                }
                
                // Last studied
                if let lastStudied = deck.lastStudied {
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Last studied \(lastStudied.formatted(.relative(presentation: .numeric)))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func languageName(_ code: String) -> String {
        switch code {
        case "en": return "EN"
        case "uk": return "UK"
        case "ru": return "RU"
        case "es": return "ES"
        case "fr": return "FR"
        case "de": return "DE"
        default: return code.uppercased()
        }
    }
}

struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct CreateDeckView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var deckName: String
    @Binding var deckDescription: String
    @Binding var sourceLang: String
    @Binding var targetLang: String
    let onCreate: () -> Void
    
    let languages = [
        ("en", "English"),
        ("uk", "Ukrainian"),
        ("ru", "Russian"),
        ("es", "Spanish"),
        ("fr", "French"),
        ("de", "German")
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Deck Information")) {
                    TextField("Deck Name", text: $deckName)
                    TextField("Description (optional)", text: $deckDescription)
                }
                
                Section(header: Text("Languages")) {
                    Picker("From", selection: $sourceLang) {
                        ForEach(languages, id: \.0) { code, name in
                            Text(name).tag(code)
                        }
                    }
                    
                    Picker("To", selection: $targetLang) {
                        ForEach(languages, id: \.0) { code, name in
                            Text(name).tag(code)
                        }
                    }
                }
            }
            .navigationTitle("New Deck")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        onCreate()
                    }
                    .disabled(deckName.isEmpty)
                }
            }
        }
    }
}

struct StudyView: View {
    let deck: FlashcardDeck
    @Environment(\.dismiss) var dismiss
    @StateObject private var flashcardManager = FlashcardManager.shared
    @State private var currentCardIndex = 0
    @State private var showingBack = false
    @State private var dragOffset = CGSize.zero
    @State private var studySession: StudySession?
    @State private var cardsToStudy: [Flashcard] = []
    @State private var sessionComplete = false
    
    var currentCard: Flashcard? {
        guard currentCardIndex < cardsToStudy.count else { return nil }
        return cardsToStudy[currentCardIndex]
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if sessionComplete {
                    StudyCompleteView(session: studySession!) {
                        dismiss()
                    }
                } else if let card = currentCard {
                    // Progress indicator
                    HStack {
                        Text("\(currentCardIndex + 1) of \(cardsToStudy.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("End Session") {
                            endSession()
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                    
                    ProgressView(value: Double(currentCardIndex), total: Double(cardsToStudy.count))
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    // Flashcard
                    FlashcardView(
                        card: card,
                        showingBack: $showingBack,
                        dragOffset: $dragOffset
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showingBack.toggle()
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                let swipeThreshold: CGFloat = 100
                                
                                if abs(value.translation.width) > swipeThreshold {
                                    // Determine result based on swipe direction and showing back
                                    let result: StudyResult
                                    if showingBack {
                                        if value.translation.width > 0 {
                                            result = .good // Right swipe when showing back = good
                                        } else {
                                            result = .again // Left swipe when showing back = again
                                        }
                                        handleStudyResult(result)
                                    }
                                }
                                
                                withAnimation(.spring()) {
                                    dragOffset = .zero
                                }
                            }
                    )
                    
                    // Answer buttons (only show when back is visible)
                    if showingBack {
                        VStack(spacing: 12) {
                            Text("How well did you know this?")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(StudyResult.allCases, id: \.self) { result in
                                    Button(action: { handleStudyResult(result) }) {
                                        Text(result.displayName)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(colorForResult(result))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        VStack {
                            Text("Tap to reveal answer")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer().frame(height: 100)
                        }
                    }
                    
                    Spacer()
                } else {
                    // No cards to study
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("All caught up!")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("No cards are due for review right now.")
                            .foregroundColor(.secondary)
                        
                        Button("Close") {
                            dismiss()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
            .navigationTitle(deck.name)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                startStudySession()
            }
        }
    }
    
    private func startStudySession() {
        cardsToStudy = flashcardManager.getCardsForStudy(deckId: deck.id)
        studySession = flashcardManager.startStudySession(deckId: deck.id)
    }
    
    private func handleStudyResult(_ result: StudyResult) {
        guard let card = currentCard, let session = studySession else { return }
        
        // Record the result
        flashcardManager.recordStudyResult(card, result: result)
        
        // Update session stats
        var updatedSession = session
        updatedSession.cardsStudied += 1
        if result == .good || result == .easy {
            updatedSession.correctAnswers += 1
        }
        
        flashcardManager.updateStudySession(updatedSession)
        studySession = updatedSession
        
        // Move to next card
        withAnimation(.spring()) {
            currentCardIndex += 1
            showingBack = false
            
            if currentCardIndex >= cardsToStudy.count {
                sessionComplete = true
                endSession()
            }
        }
    }
    
    private func endSession() {
        guard let session = studySession else { return }
        flashcardManager.endStudySession(session)
        
        if !sessionComplete {
            sessionComplete = true
        }
    }
    
    private func colorForResult(_ result: StudyResult) -> Color {
        switch result {
        case .again: return .red
        case .hard: return .orange
        case .good: return .green
        case .easy: return .blue
        }
    }
}

struct FlashcardView: View {
    let card: Flashcard
    @Binding var showingBack: Bool
    @Binding var dragOffset: CGSize
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            
            // Card content
            VStack(spacing: 20) {
                // Language indicator
                HStack {
                    Text(showingBack ? languageName(card.targetLanguage) : languageName(card.sourceLanguage))
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    // Difficulty indicator
                    Text(card.difficulty.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(difficultyColor(card.difficulty).opacity(0.2))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                // Main text
                Text(showingBack ? card.backText : card.frontText)
                    .font(.title2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                // Study data (only show on back)
                if showingBack && card.studyData.timesStudied > 0 {
                    VStack(spacing: 4) {
                        Text("Success Rate: \(Int(card.studyData.successRate * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Studied \(card.studyData.timesStudied) times")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(20)
        }
        .frame(height: 300)
        .padding(.horizontal, 20)
        .scaleEffect(1 - abs(dragOffset.width) / 1000)
        .rotationEffect(.degrees(Double(dragOffset.width / 20)))
        .offset(dragOffset)
    }
    
    func languageName(_ code: String) -> String {
        switch code {
        case "en": return "English"
        case "uk": return "Ukrainian"
        case "ru": return "Russian"
        case "es": return "Spanish"
        case "fr": return "French"
        case "de": return "German"
        default: return code.uppercased()
        }
    }
    
    func difficultyColor(_ difficulty: FlashcardDifficulty) -> Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}

struct StudyCompleteView: View {
    let session: StudySession
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Session Complete!")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                Text("Cards studied: \(session.cardsStudied)")
                Text("Accuracy: \(Int(session.accuracy * 100))%")
                if let endTime = session.endTime {
                    let duration = endTime.timeIntervalSince(session.startTime)
                    Text("Time: \(Int(duration / 60))m \(Int(duration.truncatingRemainder(dividingBy: 60)))s")
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            Button("Close") {
                onClose()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
        .padding()
    }
}

#Preview {
    FlashcardsView()
}