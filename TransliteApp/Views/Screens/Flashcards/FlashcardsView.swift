import SwiftUI
import Foundation
import AVFoundation

struct FlashcardsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var flashcardManager = FlashcardManager.shared
    @State private var showingCreateDeck = false
    @State private var newDeckName = ""
    @State private var newDeckDescription = ""
    @State private var newDeckSourceLang = "en"
    @State private var newDeckTargetLang = "uk"
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Header with Close Button
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Language Learning")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Study flashcards to improve your vocabulary")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                    }
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
                        DeckCardWrapper(
                            deck: deck,
                            flashcardManager: flashcardManager
                        )
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
        }
    }
}

struct DeckCardWrapper: View {
    let deck: FlashcardDeck
    let flashcardManager: FlashcardManager
    @State private var showingStudyView = false
    
    var body: some View {
        DeckCard(deck: deck) {
            print("Selected deck: \(deck.name), ID: \(deck.id)")
            showingStudyView = true
        }
        .sheet(isPresented: $showingStudyView) {
            NavigationView {
                StudyView(deck: deck)
            }
        }
    }
}

struct DeckCard: View {
    let deck: FlashcardDeck
    let onTap: () -> Void
    @StateObject private var flashcardManager = FlashcardManager.shared
    @State private var showingAddCard = false
    @State private var newCardFront = ""
    @State private var newCardBack = ""
    @State private var showingDeleteConfirmation = false
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var speechDelegate: SpeechDelegate?
    @State private var speechSequenceDelegate: SpeechSequenceDelegate?
    
    var deckStats: (totalCards: Int, studiedCards: Int, averageSuccessRate: Double, totalStudyTime: TimeInterval) {
        flashcardManager.getStudyStatistics(for: deck.id)
    }
    
    var dueCardsCount: Int {
        flashcardManager.getDueCardsCount(for: deck.id)
    }
    
    var body: some View {
        VStack(spacing: 0) {
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
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack(spacing: 4) {
                                Text("\(languageName(deck.sourceLanguage)) → \(languageName(deck.targetLanguage))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
  
                            }
                            
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
            
            // Action buttons
            HStack(spacing: 12) {
                // Add Card Button
                Button(action: { showingAddCard = true }) {
                    HStack {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 16))
                        Text("Add Card")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
                
                
                Spacer()
                
                // Delete Deck Button
                Button(action: { showingDeleteConfirmation = true }) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .sheet(isPresented: $showingAddCard) {
            AddCardView(
                deck: deck,
                frontText: $newCardFront,
                backText: $newCardBack
            ) {
                let newCard = flashcardManager.createFlashcard(
                    frontText: newCardFront,
                    backText: newCardBack,
                    sourceLanguage: deck.sourceLanguage,
                    targetLanguage: deck.targetLanguage
                )
                flashcardManager.addFlashcardToDeck(newCard, deck: deck)
                newCardFront = ""
                newCardBack = ""
                showingAddCard = false
            }
        }
        .alert("Delete Deck", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                flashcardManager.deleteDeck(deck)
            }
        } message: {
            Text("Are you sure you want to delete \"\(deck.name)\" and all its cards? This action cannot be undone.")
        }
    }
    
    // MARK: - Text-to-Speech Functions

 
    
    
    private func getLanguageCode(_ code: String) -> String {
        switch code {
        case "en": return "en-US"
        case "uk": return "uk-UA"
        case "ru": return "ru-RU"
        case "es": return "es-ES"
        case "fr": return "fr-FR"
        case "de": return "de-DE"
        case "it": return "it-IT"
        case "pl": return "pl-PL"
        case "cs": return "cs-CZ"
        default: return "en-US"
        }
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

struct AddCardView: View {
    let deck: FlashcardDeck
    @Binding var frontText: String
    @Binding var backText: String
    let onAdd: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var sourceLanguage: String
    @State private var targetLanguage: String
    @State private var isTranslating = false
    @State private var translationAlternatives: [String] = []
    @State private var showingAlternatives = false
    @StateObject private var translator = GoogleTranslateParser()
    
    let languages = [
        ("auto", "Auto-detect"),
        ("en", "English"),
        ("uk", "Ukrainian"), 
        ("ru", "Russian"),
        ("es", "Spanish"),
        ("fr", "French"),
        ("de", "German"),
        ("it", "Italian"),
        ("pl", "Polish"),
        ("cs", "Czech")
    ]
    
    init(deck: FlashcardDeck, frontText: Binding<String>, backText: Binding<String>, onAdd: @escaping () -> Void) {
        self.deck = deck
        self._frontText = frontText
        self._backText = backText
        self.onAdd = onAdd
        self._sourceLanguage = State(initialValue: deck.sourceLanguage)
        self._targetLanguage = State(initialValue: deck.targetLanguage)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Language Selection Section
                Section(header: Text("Languages")) {
                    Picker("From", selection: $sourceLanguage) {
                        ForEach(languages, id: \.0) { code, name in
                            Text(name).tag(code)
                        }
                    }
                    
                    HStack {
                        Button(action: swapLanguages) {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Picker("To", selection: $targetLanguage) {
                            ForEach(languages.filter { $0.0 != "auto" }, id: \.0) { code, name in
                                Text(name).tag(code)
                            }
                        }
                    }
                }
                
                // Front Text Section
                Section(header: HStack {
                    Text("Front (\(languageName(sourceLanguage)))")
                    Spacer()
                    if !frontText.isEmpty && sourceLanguage != targetLanguage {
                        Button(action: translateText) {
                            HStack {
                                if isTranslating {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.right.circle.fill")
                                }
                                Text("Translate")
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        .disabled(isTranslating)
                    }
                }) {
                    TextField("Enter text to translate", text: $frontText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Translation Results Section
                if !translationAlternatives.isEmpty {
                    Section(header: Text("Translation Options")) {
                        ForEach(Array(translationAlternatives.enumerated()), id: \.offset) { index, translation in
                            HStack {
                                Text(translation)
                                    .lineLimit(nil)
                                
                                Spacer()
                                
                                Button("Use") {
                                    backText = translation
                                    translationAlternatives.removeAll()
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                backText = translation
                                translationAlternatives.removeAll()
                            }
                        }
                    }
                }
                
                // Back Text Section
                Section(header: Text("Back (\(languageName(targetLanguage)))")) {
                    TextField("Enter translation or use auto-translate", text: $backText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Additional Options
                Section {
                    HStack {
                        Image(systemName: "lightbulb")
                            .foregroundColor(.orange)
                        Text("Tip: Use the translate button to get multiple translation options")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Add Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        onAdd()
                    }
                    .disabled(frontText.isEmpty || backText.isEmpty)
                }
            }
        }
    }
    
    private func swapLanguages() {
        guard sourceLanguage != "auto" else { return }
        let temp = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = temp
        
        let tempText = frontText
        frontText = backText
        backText = tempText
    }
    
    private func translateText() {
        guard !frontText.isEmpty, sourceLanguage != targetLanguage else { return }
        
        isTranslating = true
        translationAlternatives.removeAll()
        
        Task {
            do {
                // Get main translation
                let mainTranslation = try await translator.translate(
                    text: frontText,
                    from: sourceLanguage == "auto" ? "" : sourceLanguage,
                    to: targetLanguage
                )
                
                await MainActor.run {
                    var alternatives = [mainTranslation]
                    
                    // Add main translation as first option
                    if !mainTranslation.isEmpty {
                        backText = mainTranslation
                        
                        // Generate some alternative phrasings if possible
                        let variations = generateAlternatives(for: mainTranslation)
                        alternatives.append(contentsOf: variations)
                        
                        translationAlternatives = Array(Set(alternatives)).filter { !$0.isEmpty }
                    }
                    
                    isTranslating = false
                }
            } catch {
                await MainActor.run {
                    isTranslating = false
                    // Show error or use fallback
                    print("Translation error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func generateAlternatives(for translation: String) -> [String] {
        var alternatives: [String] = []
        
        // Simple alternatives based on common patterns
        let lowerTranslation = translation.lowercased()
        
        // Add capitalized version if not already capitalized
        if translation != translation.capitalized {
            alternatives.append(translation.capitalized)
        }
        
        // Add lowercase version if not already lowercase
        if translation != lowerTranslation {
            alternatives.append(lowerTranslation)
        }
        
        // Add version with article if it doesn't have one (for some languages)
        if targetLanguage == "en" && !lowerTranslation.hasPrefix("the ") && !lowerTranslation.hasPrefix("a ") && !lowerTranslation.hasPrefix("an ") {
            alternatives.append("the " + lowerTranslation)
        }
        
        return alternatives.filter { $0 != translation }
    }
    
    func languageName(_ code: String) -> String {
        switch code {
        case "auto": return "Auto"
        case "en": return "English"
        case "uk": return "Ukrainian"
        case "ru": return "Russian"
        case "es": return "Spanish"
        case "fr": return "French"
        case "de": return "German"
        case "it": return "Italian"
        case "pl": return "Polish"
        case "cs": return "Czech"
        default: return code.uppercased()
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
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var isPlayingAudio = false
    @State private var speechDelegate: SpeechDelegate?
    
    var currentCard: Flashcard? {
        guard currentCardIndex < cardsToStudy.count else { return nil }
        return cardsToStudy[currentCardIndex]
    }
    
    var body: some View {
        VStack(spacing: 20) {
                if sessionComplete, let session = studySession {
                    StudyCompleteView(session: session) {
                        dismiss()
                    }
                } else if cardsToStudy.isEmpty {
                    // No cards to study view
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "rectangle.stack.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Cards to Study")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Add some flashcards to this deck to start studying")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Close") {
                            dismiss()
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Spacer()
                    }
                } else if let card = currentCard {
                    // Progress indicator
                    HStack {
                        Text("\(currentCardIndex + 1) of \(cardsToStudy.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Audio button
                        Button(action: { playCurrentCard() }) {
                            Image(systemName: isPlayingAudio ? "speaker.wave.2.fill" : "speaker.wave.2")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                        }
                        .disabled(isPlayingAudio)
                        
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
                    
                    // Navigation buttons
                    HStack {
                        Button(action: navigateToPrevious) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(currentCardIndex > 0 ? .blue : .gray.opacity(0.3))
                        }
                        .disabled(currentCardIndex == 0)
                        
                        Spacer()
                        
                        Button(action: navigateToNext) {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(currentCardIndex < cardsToStudy.count - 1 ? .blue : .gray.opacity(0.3))
                        }
                        .disabled(currentCardIndex >= cardsToStudy.count - 1)
                    }
                    .padding(.horizontal, 30)
                    
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
                                    if showingBack {
                                        // When showing back, swipe to record result
                                        let result: StudyResult
                                        if value.translation.width > 0 {
                                            result = .good // Right swipe = good
                                        } else {
                                            result = .again // Left swipe = again
                                        }
                                        handleStudyResult(result)
                                    } else {
                                        // When showing front, swipe to navigate
                                        if value.translation.width > 0 {
                                            navigateToPrevious() // Right swipe = previous
                                        } else {
                                            navigateToNext() // Left swipe = next
                                        }
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
                print("StudyView appeared for deck: \(deck.name)")
                startStudySession()
            }
    }
    
    private func startStudySession() {
        print("Starting study session for deck: \(deck.id)")
        cardsToStudy = flashcardManager.getCardsForStudy(deckId: deck.id)
        print("Cards to study count: \(cardsToStudy.count)")
        
        if !cardsToStudy.isEmpty {
            studySession = flashcardManager.startStudySession(deckId: deck.id)
            print("Study session started")
        } else {
            print("No cards to study")
        }
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
    
    private func navigateToNext() {
        guard currentCardIndex < cardsToStudy.count - 1 else { return }
        withAnimation(.spring()) {
            currentCardIndex += 1
            showingBack = false
            dragOffset = .zero
        }
    }
    
    private func navigateToPrevious() {
        guard currentCardIndex > 0 else { return }
        withAnimation(.spring()) {
            currentCardIndex -= 1
            showingBack = false
            dragOffset = .zero
        }
    }
    
    // MARK: - Text-to-Speech Functions
    
    private func playCurrentCard() {
        guard let card = currentCard else { return }
        
        isPlayingAudio = true
        
        // Determine which text to play based on card state
        let textToSpeak = showingBack ? card.backText : card.frontText
        let languageCode = showingBack ? deck.targetLanguage : deck.sourceLanguage
        
        // Create speech utterance
        let utterance = AVSpeechUtterance(string: textToSpeak)
        utterance.voice = AVSpeechSynthesisVoice(language: getLanguageCode(languageCode))
        utterance.rate = 0.5
        utterance.volume = 1.0
        
        // Set up completion handler
        speechDelegate = SpeechDelegate { [self] in
            DispatchQueue.main.async {
                self.isPlayingAudio = false
            }
        }
        speechSynthesizer.delegate = speechDelegate
        
        // Stop any current speech and speak new utterance
        speechSynthesizer.stopSpeaking(at: .immediate)
        speechSynthesizer.speak(utterance)
    }
    
    private func getLanguageCode(_ code: String) -> String {
        switch code {
        case "en": return "en-US"
        case "uk": return "uk-UA"
        case "ru": return "ru-RU"
        case "es": return "es-ES"
        case "fr": return "fr-FR"
        case "de": return "de-DE"
        case "it": return "it-IT"
        case "pl": return "pl-PL"
        case "cs": return "cs-CZ"
        default: return "en-US"
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
        .overlay(
            // Swipe indicators
            HStack {
                if !showingBack && dragOffset.width > 50 {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue.opacity(0.8))
                        .padding(.leading, 20)
                }
                Spacer()
                if !showingBack && dragOffset.width < -50 {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue.opacity(0.8))
                        .padding(.trailing, 20)
                }
            }
            .opacity(showingBack ? 0 : 1)
        )
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

// MARK: - Speech Delegate

class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    private let onFinish: () -> Void
    
    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onFinish()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        onFinish()
    }
}

class SpeechSequenceDelegate: NSObject, AVSpeechSynthesizerDelegate {
    private let onFinish: () -> Void
    private var utteranceCount = 0
    private var completedUtterances = 0
    
    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }
    
    func setUtteranceCount(_ count: Int) {
        utteranceCount = count
        completedUtterances = 0
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        completedUtterances += 1
        if completedUtterances >= 2 { // Both front and back utterances completed
            onFinish()
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        onFinish()
    }
}

#Preview {
    FlashcardsView()
}
