import SwiftUI

struct HistoryView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) var dismiss
    @StateObject private var historyManager = TranslationHistoryManager.shared
    
    @State private var searchText = ""
    @State private var showFavoritesOnly = false
    @State private var selectedItem: TranslationHistoryItem?
    @State private var showStatistics = false
    
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
                    
                    Button(action: { showFavoritesOnly.toggle() }) {
                        Image(systemName: showFavoritesOnly ? "star.fill" : "star")
                            .foregroundColor(showFavoritesOnly ? AppColors.warningColor : AppColors.secondaryText)
                    }
                }
                .padding(.horizontal)
                
                if filteredHistory.isEmpty {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.secondaryText)
                        
                        Text(searchText.isEmpty ? "no_history".localized : "no_results_found".localized)
                            .font(.headline)
                            .foregroundColor(AppColors.secondaryText)
                        
                        Text("history_description".localized)
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    Spacer()
                } else {
                    List {
                        ForEach(filteredHistory) { item in
                            HistoryItemRow(item: item)
                                .onTapGesture {
                                    selectedItem = item
                                }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("history_title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("done".localized) {
                        dismiss()
                    }
                }
                
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
    
    func deleteItems(at offsets: IndexSet) {
        historyManager.deleteItem(at: offsets)
    }
}

struct HistoryItemRow: View {
    let item: TranslationHistoryItem
    
    var body: some View {
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
                
                if item.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(AppColors.warningColor)
                }
                
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
        .padding(.vertical, 4)
    }
    
    func languageName(_ code: String) -> String {
        switch code {
        case "auto": return "language_auto".localized
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
    @StateObject private var historyManager = TranslationHistoryManager.shared
    @StateObject private var flashcardManager = FlashcardManager.shared
    @State private var showingDeckSelector = false
    @State private var flashcardCreated = false
    
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
                                Image(systemName: item.isFavorite ? "star.fill" : "star")
                                    .foregroundColor(item.isFavorite ? AppColors.warningColor : AppColors.secondaryText)
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
        }
    }
    
    func toggleFavorite() {
        historyManager.toggleFavorite(for: item.id)
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
        case "auto": return "auto_detect".localized
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
        case "auto": return "auto_detect".localized
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
