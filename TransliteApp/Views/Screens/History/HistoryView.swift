import SwiftUI

struct HistoryView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) var dismiss
    @StateObject private var historyManager = TranslationHistoryManager.shared
    
    @State private var searchText = ""
    @State private var showFavoritesOnly = false
    @State private var selectedItem: TranslationHistoryItem?
    @State private var showStatistics = false
    @State private var filterStarScale: CGFloat = 1.0
    
    var filteredHistory: [TranslationHistoryItem] {
        let items = showFavoritesOnly ? historyManager.getFavorites() : historyManager.history
        
        if searchText.isEmpty {
            return items
        } else {
            return historyManager.searchHistory(query: searchText)
        }
    }
    
    var body: some View {
        LocalizedView {
        NavigationView {
            ZStack {
                // Theme-aware background matching main screen
                AppColors.appBackground
                    .ignoresSafeArea()
                
            VStack {
                // Search and filter bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppColors.secondaryText)
                        
                        TextField("search_history".localized, text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(8)
                    .background(AppColors.tertiaryBackground)
                    .cornerRadius(8)
                    
                    Button(action: { 
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            filterStarScale = 1.3
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                filterStarScale = 1.0
                            }
                        }
                        
                        showFavoritesOnly.toggle() 
                    }) {
                        Image(systemName: showFavoritesOnly ? "star.fill" : "star")
                            .foregroundColor(showFavoritesOnly ? AppColors.warningColor : AppColors.secondaryText)
                            .scaleEffect(filterStarScale)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: filterStarScale)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showFavoritesOnly)
                    }
                }
                .padding(.horizontal)
                
                if filteredHistory.isEmpty {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.secondaryText)
                        
                        Text(getEmptyStateTitle())
                            .font(.headline)
                            .foregroundColor(AppColors.secondaryText)
                        
                        Text(getEmptyStateDescription())
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    Spacer()
                } else {
                    List {
                        ForEach(filteredHistory) { item in
                            HistoryItemRow(itemId: item.id)
                                .listRowBackground(AppColors.cardBackground)
                                .onTapGesture {
                                    selectedItem = item
                                }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .scrollContentBackground(.hidden)
                    .background(AppColors.appBackground)
                    .listStyle(PlainListStyle())
                    .id(historyManager.refreshTrigger) // Force refresh when favorites change
                }
            }
            .navigationTitle("history_title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("done".localized) {
//                        dismiss()
//                    }
//                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showStatistics = true }) {
                        Image(systemName: "chart.bar.fill")
                    }
                }
            }
            .sheet(item: $selectedItem) { item in
                HistoryDetailView(item: item)
            }
            .sheet(isPresented: $showStatistics) {
                StatisticsView()
            }
            }
        }
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        historyManager.deleteItem(at: offsets)
    }
    
    func getEmptyStateTitle() -> String {
        if !searchText.isEmpty {
            return "no_results_found".localized
        } else if showFavoritesOnly {
            return "no_favorites".localized
        } else {
            return "no_history".localized
        }
    }
    
    func getEmptyStateDescription() -> String {
        if !searchText.isEmpty {
            return "try_different_search".localized
        } else if showFavoritesOnly {
            return "add_favorites_description".localized
        } else {
            return "history_description".localized
        }
    }
}

struct HistoryItemRow: View {
    let itemId: UUID
    @State private var starScale: CGFloat = 1.0
    @ObservedObject private var historyManager = TranslationHistoryManager.shared
    
    var item: TranslationHistoryItem? {
        historyManager.history.first(where: { $0.id == itemId })
    }
    
    var body: some View {
        if let item = item {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(languageName(item.sourceLanguage))
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(AppColors.appAccent.opacity(0.2))
                        .cornerRadius(4)
                    
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text(languageName(item.targetLanguage))
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(AppColors.successColor.opacity(0.2))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            starScale = item.isFavorite ? 0.8 : 1.4
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                starScale = 1.0
                            }
                        }
                        
                        historyManager.toggleFavorite(for: itemId)
                    }) {
                        Image(systemName: item.isFavorite ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(item.isFavorite ? AppColors.warningColor : AppColors.secondaryText)
                            .scaleEffect(starScale)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: starScale)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: item.isFavorite)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text(item.timestamp.formatted(.relative(presentation: .numeric)))
                        .font(.caption2)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Text(item.sourceText)
                    .font(.system(size: 14))
                    .lineLimit(2)
                
                Text(item.translatedText)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.secondaryText)
                    .lineLimit(2)
                
                if !item.alternatives.isEmpty || !item.corrections.isEmpty {
                    HStack(spacing: 12) {
                        if !item.alternatives.isEmpty {
                            Label("\(item.alternatives.count)", systemImage: "text.badge.plus")
                                .font(.caption2)
                                .foregroundColor(AppColors.appAccent)
                        }
                        
                        if !item.corrections.isEmpty {
                            Label("\(item.corrections.count)", systemImage: "exclamationmark.triangle")
                                .font(.caption2)
                                .foregroundColor(AppColors.warningColor)
                        }
                    }
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(12)
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        } else {
            EmptyView()
        }
    }
    
    func languageName(_ code: String) -> String {
        switch code {
        case "en": return "language_en_short".localized
        case "uk": return "language_uk_short".localized
        case "ru": return "language_ru_short".localized
        case "es": return "language_es_short".localized
        case "fr": return "language_fr_short".localized
        case "de": return "language_de_short".localized
        default: return code.uppercased()
        }
    }
}

struct HistoryDetailView: View {
    let item: TranslationHistoryItem
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var historyManager = TranslationHistoryManager.shared
    @StateObject private var flashcardManager = FlashcardManager.shared
    @State private var showingDeckSelector = false
    @State private var flashcardCreated = false
    @State private var starScale: CGFloat = 1.0
    @State private var starRotation: Double = 0.0
    @State private var isFavorite: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Language pair and metadata
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(languageName(item.sourceLanguage))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(AppColors.appAccent.opacity(0.2))
                                .cornerRadius(8)
                            
                            Image(systemName: "arrow.right")
                                .foregroundColor(AppColors.secondaryText)
                            
                            Text(languageName(item.targetLanguage))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(AppColors.successColor.opacity(0.2))
                                .cornerRadius(8)
                            
                            Spacer()
                            
                            Button(action: toggleFavorite) {
                                Image(systemName: isFavorite ? "star.fill" : "star")
                                    .foregroundColor(isFavorite ? AppColors.warningColor : AppColors.secondaryText)
                                    .scaleEffect(starScale)
                                    .rotationEffect(.degrees(starRotation))
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFavorite)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: starScale)
                                    .animation(.easeInOut(duration: 0.2), value: starRotation)
                            }
                        }
                        
                        
                        Text(item.timestamp.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Source text
                    VStack(alignment: .leading, spacing: 8) {
                        Text("original_text".localized)
                            .font(.headline)
                        
                        Text(item.sourceText)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppColors.tertiaryBackground)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Translation
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("translation_title".localized)
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: createFlashcard) {
                                Image(systemName: "plus.square.fill")
                                    .foregroundColor(AppColors.successColor)
                            }
                            
                            Button(action: copyTranslation) {
                                Image(systemName: "doc.on.doc.fill")
                                    .foregroundColor(AppColors.appAccent)
                            }
                        }
                        
                        Text(item.translatedText)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppColors.tertiaryBackground)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Alternatives
                    if !item.alternatives.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("alternatives".localized)
                                .font(.headline)
                            
                            ForEach(item.alternatives, id: \.self) { alternative in
                                HStack {
                                    Text(alternative)
                                        .font(.system(size: 14))
                                    
                                    Spacer()
                                    
                                    Button(action: { copyText(alternative) }) {
                                        Image(systemName: "doc.on.doc")
                                            .font(.caption)
                                            .foregroundColor(AppColors.appAccent)
                                    }
                                }
                                .padding()
                                .background(AppColors.appAccent.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Corrections
                    if !item.corrections.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("corrections".localized)
                                .font(.headline)
                            
                            ForEach(item.corrections, id: \.self) { correction in
                                Text(correction)
                                    .font(.system(size: 14))
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(AppColors.warningColor.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("translation_details".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done".localized) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingDeckSelector) {
                DeckSelectorView(
                    decks: flashcardManager.decks,
                    sourceLanguage: item.sourceLanguage,
                    targetLanguage: item.targetLanguage,
                    onDeckSelected: { deck in
                        let flashcard = flashcardManager.createFlashcardFromTranslation(item)
                        if flashcardManager.addFlashcardToDeck(flashcard, deck: deck) {
                            flashcardCreated = true
                        }
                        showingDeckSelector = false
                    },
                    onCreateNewDeck: {
                        let newDeck = flashcardManager.createDeck(
                            name: "New Deck",
                            sourceLanguage: item.sourceLanguage,
                            targetLanguage: item.targetLanguage
                        )
                        let flashcard = flashcardManager.createFlashcardFromTranslation(item)
                        _ = flashcardManager.addFlashcardToDeck(flashcard, deck: newDeck)
                        flashcardCreated = true
                        showingDeckSelector = false
                    }
                )
            }
            .alert("flashcard_created".localized, isPresented: $flashcardCreated) {
                Button("ok".localized) { }
            } message: {
                Text("flashcard_added_description".localized)
            }
            .onAppear {
                // Ініціалізуємо стан обраного при відкритті
                isFavorite = historyManager.history.first(where: { $0.id == item.id })?.isFavorite ?? item.isFavorite
            }
        }
    }
    
    func toggleFavorite() {
        let wasAlreadyFavorite = isFavorite
        
        // Анімація при натисканні
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            starScale = wasAlreadyFavorite ? 0.8 : 1.3
        }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            starRotation = wasAlreadyFavorite ? 0 : 360
        }
        
        // Змінюємо локальний стан та стан в менеджері
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isFavorite.toggle()
        }
        historyManager.toggleFavorite(for: item.id)
        
        // Повертаємо масштаб назад через коротку затримку
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                starScale = 1.0
                starRotation = 0
            }
        }
        
        // Додатковий ефект для нових обраних
        if !wasAlreadyFavorite {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    starScale = 1.1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        starScale = 1.0
                    }
                }
            }
        }
    }
    
    func copyTranslation() {
        UIPasteboard.general.string = item.translatedText
    }
    
    func copyText(_ text: String) {
        UIPasteboard.general.string = text
    }
    
    func createFlashcard() {
        showingDeckSelector = true
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

struct StatisticsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var historyManager = TranslationHistoryManager.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("overview".localized)) {
                    HStack {
                        Text("total_translations".localized)
                        Spacer()
                        Text("\(historyManager.statistics.totalTranslations)")
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    HStack {
                        Text("favorite_count".localized)
                        Spacer()
                        Text("\(historyManager.statistics.favoriteCount)")
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    HStack {
                        Text("average_text_length".localized)
                        Spacer()
                        Text(String(format: "characters_count".localized, historyManager.statistics.averageTextLength))
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
                
                Section(header: Text("language_pairs".localized)) {
                    ForEach(Array(historyManager.statistics.languagePairs.sorted(by: { $0.value > $1.value })), id: \.key) { pair in
                        HStack {
                            Text(pair.key)
                            Spacer()
                            Text(String(format: "translations_count".localized, pair.value))
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                }
                
                Section(header: Text("most_frequent_phrases".localized)) {
                    let frequentPhrases = historyManager.getMostFrequentPhrases(limit: 5)
                    ForEach(frequentPhrases, id: \.phrase) { item in
                        HStack {
                            Text(item.phrase)
                                .lineLimit(1)
                            Spacer()
                            Text(String(format: "times_count".localized, item.count))
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                }
                
                Section(header: Text("learning_suggestions".localized)) {
                    let suggestions = historyManager.getLearningSuggestions()
                    if suggestions.isEmpty {
                        Text("no_suggestions_available".localized)
                            .foregroundColor(AppColors.secondaryText)
                    } else {
                        ForEach(suggestions) { suggestion in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(suggestion.category.rawValue)
                                    .font(.caption)
                                    .foregroundColor(AppColors.secondaryText)
                                
                                Text(suggestion.explanation)
                                    .font(.system(size: 14))
                            }
                        }
                    }
                }
            }
            .navigationTitle("statistics".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DeckSelectorView: View {
    @Environment(\.dismiss) var dismiss
    let decks: [FlashcardDeck]
    let sourceLanguage: String
    let targetLanguage: String
    let onDeckSelected: (FlashcardDeck) -> Void
    let onCreateNewDeck: () -> Void
    
    private var matchingDecks: [FlashcardDeck] {
        decks.filter { $0.sourceLanguage == sourceLanguage && $0.targetLanguage == targetLanguage }
    }
    
    var body: some View {
        NavigationView {
            List {
                if !matchingDecks.isEmpty {
                    Section(header: Text("compatible_decks_with_languages".localized(with: languageName(sourceLanguage), languageName(targetLanguage)))) {
                        ForEach(matchingDecks) { deck in
                            Button(action: { onDeckSelected(deck) }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(deck.name)
                                        .font(.headline)
                                        .foregroundColor(AppColors.primaryText)
                                    
                                    HStack {
                                        Text(String(format: "cards_count".localized, deck.flashcardIds.count))
                                            .font(.caption)
                                            .foregroundColor(AppColors.secondaryText)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Section {
                    Button(action: onCreateNewDeck) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(AppColors.successColor)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("create_new_deck".localized)
                                    .foregroundColor(AppColors.successColor)
                                Text("\(languageName(sourceLanguage)) → \(languageName(targetLanguage))")
                                    .font(.caption)
                                    .foregroundColor(AppColors.secondaryText)
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                if matchingDecks.isEmpty {
                    Section {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(AppColors.appAccent)
                            Text("no_decks_found_for_languages".localized(with: languageName(sourceLanguage), languageName(targetLanguage)))
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                }
            }
            .navigationTitle("add_to_flashcards_title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                }
            }
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

#Preview {
    HistoryView()
}
