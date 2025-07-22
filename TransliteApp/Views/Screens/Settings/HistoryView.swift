import SwiftUI

struct HistoryView: View {
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
        NavigationView {
            VStack {
                // Search and filter bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search translations", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    Button(action: { showFavoritesOnly.toggle() }) {
                        Image(systemName: showFavoritesOnly ? "star.fill" : "star")
                            .foregroundColor(showFavoritesOnly ? .yellow : .gray)
                    }
                }
                .padding(.horizontal)
                
                if filteredHistory.isEmpty {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text(searchText.isEmpty ? "No translations yet" : "No results found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Your translation history will appear here")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
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
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
                
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(languageName(item.targetLanguage))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
                
                if item.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
                
                Text(item.timestamp.formatted(.relative(presentation: .numeric)))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(item.sourceText)
                .font(.system(size: 14))
                .lineLimit(2)
            
            Text(item.translatedText)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            if !item.alternatives.isEmpty || !item.corrections.isEmpty {
                HStack(spacing: 12) {
                    if !item.alternatives.isEmpty {
                        Label("\(item.alternatives.count)", systemImage: "text.badge.plus")
                            .font(.caption2)
                            .foregroundColor(.purple)
                    }
                    
                    if !item.corrections.isEmpty {
                        Label("\(item.corrections.count)", systemImage: "exclamationmark.triangle")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    func languageName(_ code: String) -> String {
        switch code {
        case "auto": return "Auto"
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
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                            
                            Image(systemName: "arrow.right")
                                .foregroundColor(.secondary)
                            
                            Text(languageName(item.targetLanguage))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(8)
                            
                            Spacer()
                            
                            Button(action: toggleFavorite) {
                                Image(systemName: item.isFavorite ? "star.fill" : "star")
                                    .foregroundColor(item.isFavorite ? .yellow : .gray)
                            }
                        }
                        
                        
                        Text(item.timestamp.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Source text
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Original Text")
                            .font(.headline)
                        
                        Text(item.sourceText)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Translation
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Translation")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: createFlashcard) {
                                Image(systemName: "plus.square.fill")
                                    .foregroundColor(.green)
                            }
                            
                            Button(action: copyTranslation) {
                                Image(systemName: "doc.on.doc.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Text(item.translatedText)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Alternatives
                    if !item.alternatives.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Alternative Translations")
                                .font(.headline)
                            
                            ForEach(item.alternatives, id: \.self) { alternative in
                                HStack {
                                    Text(alternative)
                                        .font(.system(size: 14))
                                    
                                    Spacer()
                                    
                                    Button(action: { copyText(alternative) }) {
                                        Image(systemName: "doc.on.doc")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Corrections
                    if !item.corrections.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Grammar Corrections")
                                .font(.headline)
                            
                            ForEach(item.corrections, id: \.self) { correction in
                                Text(correction)
                                    .font(.system(size: 14))
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Translation Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
            .alert("Flashcard Created", isPresented: $flashcardCreated) {
                Button("OK") { }
            } message: {
                Text("The translation has been added to your flashcards for studying.")
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
        case "auto": return "Auto Detect"
        case "en": return "English"
        case "uk": return "Ukrainian"
        case "ru": return "Russian"
        case "es": return "Spanish"
        case "fr": return "French"
        case "de": return "German"
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
                Section(header: Text("Overview")) {
                    HStack {
                        Text("Total Translations")
                        Spacer()
                        Text("\(historyManager.statistics.totalTranslations)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Favorite Count")
                        Spacer()
                        Text("\(historyManager.statistics.favoriteCount)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Average Text Length")
                        Spacer()
                        Text(String(format: "%.0f characters", historyManager.statistics.averageTextLength))
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Language Pairs")) {
                    ForEach(Array(historyManager.statistics.languagePairs.sorted(by: { $0.value > $1.value })), id: \.key) { pair in
                        HStack {
                            Text(pair.key)
                            Spacer()
                            Text("\(pair.value) translations")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Most Frequent Phrases")) {
                    let frequentPhrases = historyManager.getMostFrequentPhrases(limit: 5)
                    ForEach(frequentPhrases, id: \.phrase) { item in
                        HStack {
                            Text(item.phrase)
                                .lineLimit(1)
                            Spacer()
                            Text("\(item.count) times")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Learning Suggestions")) {
                    let suggestions = historyManager.getLearningSuggestions()
                    if suggestions.isEmpty {
                        Text("No suggestions available yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(suggestions) { suggestion in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(suggestion.category.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(suggestion.explanation)
                                    .font(.system(size: 14))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
                    Section(header: Text("Compatible Decks (\(languageName(sourceLanguage)) → \(languageName(targetLanguage)))")) {
                        ForEach(matchingDecks) { deck in
                            Button(action: { onDeckSelected(deck) }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(deck.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    HStack {
                                        Text("\(deck.flashcardIds.count) cards")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
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
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Create New Deck")
                                    .foregroundColor(.green)
                                Text("\(languageName(sourceLanguage)) → \(languageName(targetLanguage))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                if matchingDecks.isEmpty {
                    Section {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("No decks found for \(languageName(sourceLanguage)) → \(languageName(targetLanguage)). Create a new deck to start.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Add to Flashcards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func languageName(_ code: String) -> String {
        switch code {
        case "auto": return "Auto Detect"
        case "en": return "English"
        case "uk": return "Ukrainian"
        case "ru": return "Russian"
        case "es": return "Spanish"
        case "fr": return "French"
        case "de": return "German"
        default: return code.uppercased()
        }
    }
}

#Preview {
    HistoryView()
}
