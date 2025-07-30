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
        LocalizedView {
        NavigationView {
            ZStack {
                // Theme-aware background matching main screen
                AppColors.appBackground
                    .ignoresSafeArea()
                
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Header with Close Button
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("language_learning".localized)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("study_flashcards_description".localized)
                                .font(.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                        }
                        
                        Spacer()
                        

                    }
                    .padding(.horizontal)
                    
                    // Debug: Reset button if problematic numbers detected
                    if flashcardManager.decks.contains(where: { 
                        let count = flashcardManager.getDueCardsCount(for: $0.id)
                        return count > 50 || count < 0 
                    }) {
                        Button(action: {
                            flashcardManager.resetAllStudyData()
                        }) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Виправити помилку з числами")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Spacer()
                                Text("Натисніть для скидання")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Create New Deck Button
                    Button(action: { showingCreateDeck = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            
                            Text("create_new_deck".localized)
                                .font(.headline)
                            
                            Spacer()
                        }
                        .padding()
                        .background(AppColors.appAccent.opacity(0.1))
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
            }
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
        .fullScreenCover(isPresented: $showingStudyView) {
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
                                .foregroundColor(AppColors.primaryText)
                            
                            if !(deck.description?.isEmpty ?? true) {
                                Text(deck.description ?? "")
                                    .font(.caption)
                                    .foregroundColor(AppColors.secondaryText)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack(spacing: 4) {
                                Text("\(languageName(deck.sourceLanguage)) → \(languageName(deck.targetLanguage))")
                                    .font(.caption)
                                    .foregroundColor(AppColors.secondaryText)
  
                            }
                            
                            // Temporarily hidden due to calculation issues
                            /*
                            if dueCardsCount > 0 {
                                Text("cards_due".localized(with: String(dueCardsCount)))
                                    .font(.caption)
                                    .foregroundColor(AppColors.warningColor)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(AppColors.warningColor.opacity(0.2))
                                    .cornerRadius(4)
                            }
                            */
                        }
                    }
                    
                    // Statistics
                    HStack(spacing: 20) {
                        StatItem(
                            icon: "square.stack.3d.up",
                            title: "cards".localized,
                            value: "\(deckStats.totalCards)"
                        )
                        
                        StatItem(
                            icon: "checkmark.circle",
                            title: "studied".localized,
                            value: "\(deckStats.studiedCards)"
                        )
                        
                        if deckStats.studiedCards > 0 {
                            StatItem(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "success".localized,
                                value: "\(Int(deckStats.averageSuccessRate * 100))%"
                            )
                        }
                    }
                    
                    // Last studied
                    if let lastStudied = deck.lastStudied {
                        HStack {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryText)
                            
                            Text("last_studied".localized(with: lastStudied.formatted(.relative(presentation: .numeric))))
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                }
                .padding()
                .background(AppColors.tertiaryBackground)
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
                        Text("add_card".localized)
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppColors.appAccent.opacity(0.1))
                    .foregroundColor(AppColors.appAccent)
                    .cornerRadius(8)
                }
                
                
                Spacer()
                
                // Delete Deck Button
                Button(action: { showingDeleteConfirmation = true }) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .padding(8)
                        .background(AppColors.errorColor.opacity(0.1))
                        .foregroundColor(AppColors.errorColor)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(AppColors.tertiaryBackground)
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
        .alert("delete_deck".localized, isPresented: $showingDeleteConfirmation) {
            Button("cancel".localized, role: .cancel) { }
            Button("delete".localized, role: .destructive) {
                flashcardManager.deleteDeck(deck.id)
            }
        } message: {
            Text("delete_deck_confirm".localized(with: deck.name))
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
        case "en": return "language_english".localized
        case "uk": return "language_ukrainian".localized
        case "ru": return "language_russian".localized
        case "es": return "language_spanish".localized
        case "fr": return "language_french".localized
        case "de": return "language_german".localized
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
                .foregroundColor(AppColors.appAccent)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(AppColors.secondaryText)
        }
    }
}

struct AddCardView: View {
    let deck: FlashcardDeck
    @Binding var frontText: String
    @Binding var backText: String
    let onAdd: () -> Void
    @Environment(\.dismiss) var dismiss
    
    let sourceLanguage: String
    let targetLanguage: String
    @State private var isTranslating = false
    @State private var translationAlternatives: [String] = []
    @State private var showingAlternatives = false
    @StateObject private var translator = GoogleTranslateParser()
    
    var languages: [(String, String)] {
        [
            ("auto", "auto_detect".localized),
            ("en", "language_english".localized),
            ("uk", "language_ukrainian".localized), 
            ("ru", "language_russian".localized),
            ("es", "language_spanish".localized),
            ("fr", "language_french".localized),
            ("de", "language_german".localized),
            ("it", "language_italian".localized),
            ("pl", "language_polish".localized),
            ("cs", "language_czech".localized)
        ]
    }
    
    init(deck: FlashcardDeck, frontText: Binding<String>, backText: Binding<String>, onAdd: @escaping () -> Void) {
        self.deck = deck
        self._frontText = frontText
        self._backText = backText
        self.onAdd = onAdd
        self.sourceLanguage = deck.sourceLanguage
        self.targetLanguage = deck.targetLanguage
    }
    
    var body: some View {
        LocalizedView {
        NavigationView {
            Form {
                // Language Selection Section (Fixed for this deck)
                Section(header: Text("languages".localized)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("from".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(languageName(sourceLanguage))
                                .font(.body)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("to".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(languageName(targetLanguage))
                                .font(.body)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(AppColors.appAccent)
                        Text("cards_must_use_languages".localized(with: languageName(sourceLanguage), languageName(targetLanguage)))
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
                
                // Front Text Section
                Section(header: HStack {
                    Text("front_side_with_language".localized(with: languageName(sourceLanguage)))
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
                                Text("translate_button".localized)
                            }
                            .font(.caption)
                            .foregroundColor(AppColors.appAccent)
                        }
                        .disabled(isTranslating)
                    }
                }) {
                    TextField("enter_text_to_translate".localized, text: $frontText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Translation Results Section
                if !translationAlternatives.isEmpty {
                    Section(header: Text("translation_options".localized)) {
                        ForEach(Array(translationAlternatives.enumerated()), id: \.offset) { index, translation in
                            HStack {
                                Text(translation)
                                    .lineLimit(nil)
                                
                                Spacer()
                                
                                Button("use".localized) {
                                    backText = translation
                                    translationAlternatives.removeAll()
                                }
                                .font(.caption)
                                .foregroundColor(AppColors.appAccent)
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
                Section(header: Text("back_side_with_language".localized(with: languageName(targetLanguage)))) {
                    TextField("enter_translation_or_use_auto".localized, text: $backText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Additional Options
                Section {
                    HStack {
                        Image(systemName: "lightbulb")
                            .foregroundColor(AppColors.warningColor)
                        Text("tip_translate_button".localized)
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
            }
            .navigationTitle("add_card_title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("add".localized) {
                        onAdd()
                    }
                    .disabled(frontText.isEmpty || backText.isEmpty)
                }
            }
        }
        }
    }
    
    private func swapLanguages() {
        // Language swap disabled when languages are fixed to deck
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
        case "auto": return "auto_detect".localized
        case "en": return "language_english".localized
        case "uk": return "language_ukrainian".localized
        case "ru": return "language_russian".localized
        case "es": return "language_spanish".localized
        case "fr": return "language_french".localized
        case "de": return "language_german".localized
        case "it": return "language_italian".localized
        case "pl": return "language_polish".localized
        case "cs": return "language_czech".localized
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
        LocalizedView {
        ZStack {
            // Background
            AppColors.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
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
                            .foregroundColor(AppColors.secondaryText)
                        
                        Text("no_cards_to_study".localized)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("add_flashcards_to_study".localized)
                            .font(.body)
                            .foregroundColor(AppColors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            // Check if deck has any cards at all
                            if !flashcardManager.getAllCards(for: deck.id).isEmpty {
                                Button(action: {
                                    // Reset study session to review all cards again
                                    cardsToStudy = flashcardManager.getAllCards(for: deck.id)
                                    currentCardIndex = 0
                                    showingBack = false
                                    studySession = flashcardManager.startStudySession(deckId: deck.id)
                                }) {
                                    HStack {
                                        Spacer()
                                        Text("review_again".localized)
                                            .font(.body)
                                            .fontWeight(.medium)
                                        Spacer()
                                    }
                                    .padding()
                                    .contentShape(Rectangle())
                                    .background(AppColors.successColor)
                                    .foregroundColor(AppColors.cardBackground)
                                    .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            Button(action: {
                                dismiss()
                            }) {
                                HStack {
                                    Spacer()
                                    Text("close".localized)
                                        .font(.body)
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                                .padding()
                                .contentShape(Rectangle())
                                .background(AppColors.appAccent.opacity(0.2))
                                .foregroundColor(AppColors.appAccent)
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                } else if let card = currentCard {
                    // Compact header with progress
                    HStack {
                        Text("card_of_total".localized(with: currentCardIndex + 1, cardsToStudy.count))
                            .font(.caption2)
                            .foregroundColor(AppColors.secondaryText)
                        
                        ProgressView(value: Double(currentCardIndex), total: Double(cardsToStudy.count))
                            .frame(maxWidth: 100)
                        
                        Spacer()
                        
                        // Audio button
                        Button(action: { playCurrentCard() }) {
                            Image(systemName: isPlayingAudio ? "speaker.wave.2.fill" : "speaker.wave.2")
                                .font(.system(size: 16))
                                .foregroundColor(AppColors.appAccent)
                        }
                        .disabled(isPlayingAudio)
                        
                        Button("end_session".localized) {
                            endSession()
                        }
                        .font(.caption2)
                        .foregroundColor(AppColors.errorColor)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(AppColors.cardBackground)
                    
                    // Main content area
                    VStack(spacing: 16) {
                        // Navigation buttons
                        HStack {
                            Button(action: navigateToPrevious) {
                                Image(systemName: "chevron.left.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(currentCardIndex > 0 ? AppColors.appAccent : AppColors.secondaryText.opacity(0.3))
                            }
                            .disabled(currentCardIndex == 0)
                            
                            Spacer()
                            
                            Button(action: navigateToNext) {
                                Image(systemName: "chevron.right.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(currentCardIndex < cardsToStudy.count - 1 ? AppColors.appAccent : AppColors.secondaryText.opacity(0.3))
                            }
                            .disabled(currentCardIndex >= cardsToStudy.count - 1)
                        }
                        .padding(.horizontal, 30)
                    
                    // Carousel of flashcards
                    TabView(selection: $currentCardIndex) {
                        ForEach(Array(cardsToStudy.enumerated()), id: \.offset) { index, card in
                            FlashcardView(
                                card: card,
                                showingBack: .constant(index == currentCardIndex ? showingBack : false),
                                dragOffset: .constant(.zero)
                            )
                            .tag(index)
                            .onTapGesture {
                                if index == currentCardIndex {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        showingBack.toggle()
                                    }
                                }
                            }
                        }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(maxHeight: UIScreen.main.bounds.height * 0.4)
                        .onChange(of: currentCardIndex) { newValue in
                            showingBack = false
                        }
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    let swipeThreshold: CGFloat = 50
                                    
                                    if value.translation.width > swipeThreshold {
                                        // Swipe right - go to previous card
                                        navigateToPrevious()
                                    } else if value.translation.width < -swipeThreshold {
                                        // Swipe left - go to next card
                                        if showingBack {
                                            // If showing back, swipe left means "again"
                                            handleStudyResult(.again)
                                        } else {
                                            navigateToNext()
                                        }
                                    }
                                }
                        )
                        
                        // Answer buttons (only show when back is visible)
                        if showingBack {
                            VStack(spacing: 12) {
                                Text("how_well_did_you_know".localized)
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
                                Text("tap_to_reveal_answer".localized)
                                    .font(.caption)
                                    .foregroundColor(AppColors.secondaryText)
                                
                                Spacer().frame(height: 80)
                            }
                        }
                    }
                    .padding(.top, 16)
                } else {
                    // No cards to study
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.successColor)
                        
                        Text("all_caught_up".localized)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("no_cards_due_for_review".localized)
                            .foregroundColor(AppColors.secondaryText)
                        
                        VStack(spacing: 12) {
                            Button(action: {
                                // Reset study session to review all cards again
                                cardsToStudy = flashcardManager.getAllCards(for: deck.id)
                                currentCardIndex = 0
                                showingBack = false
                                studySession = flashcardManager.startStudySession(deckId: deck.id)
                            }) {
                                HStack {
                                    Spacer()
                                    Text("review_again".localized)
                                        .font(.body)
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                                .padding()
                                .contentShape(Rectangle())
                                .background(AppColors.successColor)
                                .foregroundColor(AppColors.cardBackground)
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                dismiss()
                            }) {
                                HStack {
                                    Spacer()
                                    Text("close".localized)
                                        .font(.body)
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                                .padding()
                                .contentShape(Rectangle())
                                .background(AppColors.appAccent.opacity(0.2))
                                .foregroundColor(AppColors.appAccent)
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle(deck.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("close".localized) {
                    dismiss()
                }
            }
        }
        .onAppear {
                print("StudyView appeared for deck: \(deck.name)")
                startStudySession()
            }
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
        case .again: return AppColors.errorColor
        case .hard: return AppColors.warningColor
        case .good: return AppColors.successColor
        case .easy: return AppColors.appAccent
        }
    }
    
    private func navigateToNext() {
        guard currentCardIndex < cardsToStudy.count - 1 else { return }
        withAnimation(.spring()) {
            currentCardIndex += 1
            showingBack = false
        }
    }
    
    private func navigateToPrevious() {
        guard currentCardIndex > 0 else { return }
        withAnimation(.spring()) {
            currentCardIndex -= 1
            showingBack = false
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
                        .background(AppColors.appAccent.opacity(0.2))
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
                        Text("success_rate_percent".localized(with: Int(card.studyData.successRate * 100)))
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                        
                        Text("studied_times".localized(with: card.studyData.timesStudied))
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
            }
            .padding(20)
        }
        .frame(maxHeight: 350)
        .frame(width: min(UIScreen.main.bounds.width - 40, 320))
        .scaleEffect(1 - abs(dragOffset.width) / 1000)
        .offset(dragOffset)
        .overlay(
            // Swipe indicators
            HStack {
                if !showingBack && dragOffset.width > 50 {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.appAccent.opacity(0.8))
                        .padding(.leading, 20)
                }
                Spacer()
                if !showingBack && dragOffset.width < -50 {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.appAccent.opacity(0.8))
                        .padding(.trailing, 20)
                }
            }
            .opacity(showingBack ? 0 : 1)
        )
    }
    
    func languageName(_ code: String) -> String {
        switch code {
        case "en": return "language_english".localized
        case "uk": return "language_ukrainian".localized
        case "ru": return "language_russian".localized
        case "es": return "language_spanish".localized
        case "fr": return "language_french".localized
        case "de": return "language_german".localized
        default: return code.uppercased()
        }
    }
    
    func difficultyColor(_ difficulty: FlashcardDifficulty) -> Color {
        switch difficulty {
        case .easy: return AppColors.successColor
        case .medium: return AppColors.warningColor
        case .hard: return AppColors.errorColor
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
            
            Text("session_complete".localized)
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                Text("cards_studied".localized(with: session.cardsStudied))
                Text("accuracy".localized(with: Int(session.accuracy * 100)))
                if let endTime = session.endTime {
                    let duration = endTime.timeIntervalSince(session.startTime)
                    let minutes = Int(duration / 60)
                    let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
                    Text("time_spent".localized(with: minutes, seconds))
                }
            }
            .font(.subheadline)
            .foregroundColor(AppColors.secondaryText)
            
            Button("close".localized) {
                onClose()
            }
            .font(.headline)
            .foregroundColor(AppColors.cardBackground)
            .padding()
            .background(AppColors.appAccent)
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
