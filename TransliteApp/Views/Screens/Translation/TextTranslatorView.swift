import SwiftUI
import Speech
import AVFoundation

struct TextTranslatorView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var historyManager = TranslationHistoryManager.shared
    @StateObject private var translationManager = TranslationManager.shared
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @StateObject private var permissionsManager = PermissionsManager.shared
    @StateObject private var flashcardManager = FlashcardManager.shared
    
    @State private var sourceLanguage = "auto"
    @State private var targetLanguage = "en"
    @State private var inputText = ""
    @State private var translatedText = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var alternatives: [String] = []
    @State private var isRecording = false
    @State private var showPermissionAlert = false
    @State private var showFlashcardOptions = false
    @State private var selectedDeck: FlashcardDeck?
    @State private var showDeckSelection = false
    @State private var flashcardSaved = false
    
    var languages: [(String, String)] {
        [
            ("auto", "auto_detect".localized),
            ("en", "language_english".localized),
            ("uk", "language_ukrainian".localized),
            ("ru", "language_russian".localized),
            ("es", "language_spanish".localized),
            ("fr", "language_french".localized),
            ("de", "language_german".localized)
        ]
    }
    
    var body: some View {
        LocalizedView {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.appAccent)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("text_translator_title".localized)
                            .font(.system(size: 20, weight: .semibold))
                        
                        HStack(spacing: 4) {
                            Image(systemName: translationManager.currentService.systemImageName)
                                .font(.caption)
                            Text(translationManager.currentServiceName)
                                .font(.caption)
                        }
                        .foregroundColor(AppColors.secondaryText)
                    }
                    
                    Spacer()
                    
                    Button(action: { swapLanguages() }) {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.appAccent)
                    }
                    .disabled(sourceLanguage == "auto")
                }
                .padding()
                .background(AppColors.cardBackground)
                
                // Language selectors
                HStack(spacing: 16) {
                    LanguageSelector(
                        selectedLanguage: $sourceLanguage,
                        languages: languages,
                        title: "from".localized
                    )
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(AppColors.secondaryText)
                    
                    LanguageSelector(
                        selectedLanguage: $targetLanguage,
                        languages: languages.filter { $0.0 != "auto" },
                        title: "to".localized
                    )
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Input area
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("enter_text_label".localized)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.secondaryText)
                                
                                Spacer()
                                
                                Text("character_count".localized(with: inputText.count))
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.secondaryText)
                            }
                            
                            TextEditor(text: $inputText)
                                .frame(minHeight: 120)
                                .padding(8)
                                .background(AppColors.inputBackground)
                                .cornerRadius(12)
                                .onChange(of: inputText) { _ in
                                    if inputText.count > 5000 {
                                        inputText = String(inputText.prefix(5000))
                                    }
                                }
                            
                            HStack {
                                Button(action: { inputText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(AppColors.secondaryText)
                                }
                                .opacity(inputText.isEmpty ? 0 : 1)
                                
                                Spacer()
                                
                                // Voice input button
                                Button(action: toggleVoiceInput) {
                                    Image(systemName: isRecording ? "mic.fill" : "mic")
                                        .foregroundColor(isRecording ? AppColors.errorColor : AppColors.appAccent)
                                        .font(.system(size: 20))
                                }
                                
                                Button(action: pasteFromClipboard) {
                                    Image(systemName: "doc.on.clipboard")
                                        .foregroundColor(AppColors.appAccent)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Translate button
                        Button(action: translate) {
                            HStack {
                                if translationManager.isTranslating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.buttonText))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "globe")
                                    Text("translate".localized)
                                }
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.buttonText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.appAccent)
                            .cornerRadius(25)
                        }
                        .padding(.horizontal)
                        .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || translationManager.isTranslating)
                        
                        // Translation result
                        if !translatedText.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("translation_title".localized)
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.secondaryText)
                                    
                                    Spacer()
                                    
                                    // Add to Flashcards button
                                    Button(action: { showDeckSelection = true }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: flashcardSaved ? "checkmark.circle.fill" : "plus.circle")
                                                .foregroundColor(flashcardSaved ? AppColors.successColor : AppColors.warningColor)
                                            if !flashcardSaved {
                                                Text("add_to_flashcards".localized)
                                                    .font(.caption)
                                                    .foregroundColor(AppColors.warningColor)
                                            }
                                        }
                                    }
                                    .disabled(flashcardSaved)
                                    
                                    Button(action: copyTranslation) {
                                        Image(systemName: "doc.on.doc")
                                            .foregroundColor(AppColors.appAccent)
                                    }
                                }
                                
                                Text(translatedText)
                                    .font(.system(size: 16))
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(AppColors.translationBackground)
                                    .cornerRadius(12)
                                
                                // Alternatives
                                if !alternatives.isEmpty {
                                    Text("alternatives".localized)
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.secondaryText)
                                    
                                    ForEach(alternatives, id: \.self) { alternative in
                                        Text(alternative)
                                            .font(.system(size: 14))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(AppColors.inputBackground)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .background(AppColors.appBackground)
            .navigationBarHidden(true)
        }
        .alert("error".localized, isPresented: $showError) {
            Button("ok".localized, role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("microphone_access_needed".localized, isPresented: $showPermissionAlert) {
            Button("open_settings".localized, action: openSettings)
            Button("cancel".localized, role: .cancel) { }
        } message: {
            Text("please_enable_microphone".localized)
        }
        .sheet(isPresented: $showDeckSelection) {
            DeckSelectionView(
                decks: flashcardManager.decks,
                sourceLanguage: sourceLanguage == "auto" ? "en" : sourceLanguage,
                targetLanguage: targetLanguage,
                onDeckSelected: { deck in
                    selectedDeck = deck
                    addToFlashcards(deck: deck)
                    showDeckSelection = false
                },
                onCreateNew: {
                    createAndAddToNewDeck()
                    showDeckSelection = false
                }
            )
        }
        .onAppear {
            loadLanguageSettings()
        }
        }
    }
    
    private func translate() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        translatedText = ""
        alternatives = []
        flashcardSaved = false // Reset flashcard saved status
        
        Task {
            do {
                let result = try await translationManager.translate(
                    text: inputText,
                    from: sourceLanguage,
                    to: targetLanguage
                )
                
                await MainActor.run {
                    translatedText = result
                    
                    // Save to history
                    let historyItem = TranslationHistoryItem(
                        sourceText: inputText,
                        translatedText: result,
                        sourceLanguage: sourceLanguage,
                        targetLanguage: targetLanguage
                    )
                    historyManager.addTranslation(historyItem)
                    
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func swapLanguages() {
        guard sourceLanguage != "auto" else { return }
        let temp = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = temp
        
        if !translatedText.isEmpty {
            inputText = translatedText
            translatedText = ""
        }
    }
    
    private func copyTranslation() {
        UIPasteboard.general.string = translatedText
    }
    
    private func pasteFromClipboard() {
        if let text = UIPasteboard.general.string {
            inputText = text
        }
    }
    
    private func toggleVoiceInput() {
        print("🎤 Voice input toggled, isRecording: \(isRecording)")
        
        if isRecording {
            stopVoiceInput()
        } else {
            startVoiceInput()
        }
    }
    
    private func startVoiceInput() {
        Task {
            // Check permissions first
            let micGranted = await permissionsManager.requestMicrophonePermission()
            let speechGranted = await permissionsManager.requestSpeechRecognitionPermission()
            
            guard micGranted && speechGranted else {
                await MainActor.run {
                    showPermissionAlert = true
                }
                return
            }
            
            await MainActor.run {
                isRecording = true
                print("🎤 Starting voice recognition...")
                
                // Get source language for recognition
                let recognitionLanguage = sourceLanguage == "auto" ? "en-US" : getRecognitionLanguage(from: sourceLanguage)
                
                // Use simple speech recognition with timeout
                startSimpleSpeechRecognition(language: recognitionLanguage)
            }
        }
    }
    
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    @State private var speechRecognizerSimple: SFSpeechRecognizer?
    @State private var hasCompletedRecognition = false
    
    private func startSimpleSpeechRecognition(language: String) {
        print("🎤 Starting simple speech recognition for: \(language)")
        
        // Clean up any existing recognition
        stopSimpleSpeechRecognition()
        
        // Create speech recognizer
        speechRecognizerSimple = SFSpeechRecognizer(locale: Locale(identifier: language))
        
        guard let speechRecognizer = speechRecognizerSimple,
              speechRecognizer.isAvailable else {
            print("❌ Speech recognizer not available")
            isRecording = false
            return
        }
        
        // Configure audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .default, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("❌ Audio session error: \(error)")
            isRecording = false
            return
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("❌ Could not create recognition request")
            isRecording = false
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        var lastText = ""
        var silenceTimer: Timer?
        hasCompletedRecognition = false
        
        // Start recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            DispatchQueue.main.async {
                // Prevent multiple completions
                guard !hasCompletedRecognition else {
                    print("🚫 Recognition already completed, ignoring")
                    return
                }
                
                if let result = result {
                    let newText = result.bestTranscription.formattedString
                    print("📝 Partial result: '\(newText)', isFinal: \(result.isFinal)")
                    
                    if !newText.isEmpty {
                        lastText = newText
                        
                        // Only set silence timer if not final result
                        if !result.isFinal {
                            silenceTimer?.invalidate()
                            silenceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                                guard !hasCompletedRecognition else { return }
                                print("🔇 Silence detected, using: '\(lastText)'")
                                completeRecognition(with: lastText)
                            }
                        }
                    }
                    
                    if result.isFinal {
                        print("✅ Final result: '\(newText)'")
                        silenceTimer?.invalidate()
                        completeRecognition(with: newText)
                    }
                }
                
                if let error = error {
                    print("❌ Recognition error: \(error)")
                    silenceTimer?.invalidate()
                    completeRecognition(with: lastText)
                }
            }
        }
        
        // Configure audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
            print("✅ Audio engine started")
            
            // Timeout after 10 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                if isRecording && !hasCompletedRecognition {
                    print("⏰ Recognition timeout")
                    completeRecognition(with: lastText)
                }
            }
        } catch {
            print("❌ Audio engine error: \(error)")
            isRecording = false
        }
    }
    
    private func completeRecognition(with text: String) {
        // Prevent multiple calls
        guard !hasCompletedRecognition else {
            print("🚫 Recognition already completed, ignoring duplicate call")
            return
        }
        
        hasCompletedRecognition = true
        print("✅ Completing recognition with: '\(text)'")
        
        stopSimpleSpeechRecognition()
        
        if !text.isEmpty {
            // Append to existing text or replace if empty
            if inputText.isEmpty {
                inputText = text
            } else {
                inputText += " " + text
            }
        }
        
        isRecording = false
    }
    
    private func stopSimpleSpeechRecognition() {
        print("🛑 Stopping simple speech recognition")
        
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    private func stopVoiceInput() {
        print("🛑 Stopping voice input")
        stopSimpleSpeechRecognition()
        isRecording = false
    }
    
    private func getRecognitionLanguage(from languageCode: String) -> String {
        switch languageCode {
        case "en": return "en-US"
        case "uk": return "uk-UA"
        case "ru": return "ru-RU"
        case "es": return "es-ES"
        case "fr": return "fr-FR"
        case "de": return "de-DE"
        default: return "en-US"
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Flashcard Functions
    
    private func addToFlashcards(deck: FlashcardDeck) {
        guard !inputText.isEmpty && !translatedText.isEmpty else { return }
        
        // Determine actual source language if auto-detect was used
        let actualSourceLanguage = sourceLanguage == "auto" ? "en" : sourceLanguage // Default to English if auto
        
        let flashcard = flashcardManager.createFlashcard(
            frontText: inputText.trimmingCharacters(in: .whitespacesAndNewlines),
            backText: translatedText,
            sourceLanguage: actualSourceLanguage,
            targetLanguage: targetLanguage,
            category: "From Translation"
        )
        
        _ = flashcardManager.addFlashcardToDeck(flashcard, deck: deck)
        flashcardSaved = true
        
        // Show success feedback
        withAnimation(.easeInOut(duration: 0.3)) {
            // The UI will update automatically due to flashcardSaved state
        }
    }
    
    private func createAndAddToNewDeck() {
        guard !inputText.isEmpty && !translatedText.isEmpty else { return }
        
        // Determine actual source language if auto-detect was used
        let actualSourceLanguage = sourceLanguage == "auto" ? "en" : sourceLanguage
        
        // Create new deck with a descriptive name
        let deckName = "Translation Cards (\(languageCodeToName(actualSourceLanguage)) → \(languageCodeToName(targetLanguage)))"
        let newDeck = flashcardManager.createDeck(
            name: deckName,
            description: "Cards from text translations",
            sourceLanguage: actualSourceLanguage,
            targetLanguage: targetLanguage
        )
        
        // Add the flashcard to the new deck
        addToFlashcards(deck: newDeck)
    }
    
    private func languageCodeToName(_ code: String) -> String {
        return languages.first(where: { $0.0 == code })?.1 ?? code.uppercased()
    }
    
    private func loadLanguageSettings() {
        let preferences = UserDefaults.standard
        
        // Завантажуємо збережені налаштування мов з Settings
        if let savedSourceLanguage = preferences.string(forKey: "defaultSourceLanguage") {
            sourceLanguage = savedSourceLanguage
        }
        
        if let savedTargetLanguage = preferences.string(forKey: "defaultTargetLanguage") {
            targetLanguage = savedTargetLanguage
        }
    }
}

// MARK: - Deck Selection View

struct DeckSelectionView: View {
    let decks: [FlashcardDeck]
    let sourceLanguage: String
    let targetLanguage: String
    let onDeckSelected: (FlashcardDeck) -> Void
    let onCreateNew: () -> Void
    @Environment(\.dismiss) var dismiss
    
    private var matchingDecks: [FlashcardDeck] {
        decks.filter { $0.sourceLanguage == sourceLanguage && $0.targetLanguage == targetLanguage }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("choose_deck_to_add".localized)
                    .font(.headline)
                    .padding(.top)
                
                if matchingDecks.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "rectangle.stack.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(AppColors.secondaryText)
                        
                        Text("no_compatible_decks".localized)
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("create_deck_for_languages".localized(with: languageName(sourceLanguage), languageName(targetLanguage)))
                            .font(.body)
                            .foregroundColor(AppColors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(matchingDecks) { deck in
                                DeckSelectionCard(deck: deck) {
                                    onDeckSelected(deck)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Create New Deck Button
                Button(action: onCreateNew) {
                    VStack(spacing: 4) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("create_new_deck".localized)
                        }
                        .font(.system(size: 16, weight: .semibold))
                        
                        Text("\(languageName(sourceLanguage)) → \(languageName(targetLanguage))")
                            .font(.caption)
                            .opacity(0.9)
                    }
                    .foregroundColor(AppColors.buttonText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColors.appAccent)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
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
    
    private func languageName(_ code: String) -> String {
        switch code {
        case "auto": return "language_auto".localized
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

struct DeckSelectionCard: View {
    let deck: FlashcardDeck
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(deck.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(languageName(deck.sourceLanguage)) → \(languageName(deck.targetLanguage))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !(deck.description?.isEmpty ?? true) {
                    Text(deck.description ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text("cards_count_simple".localized(with: deck.flashcardIds.count))
                        .font(.caption)
                        .foregroundColor(AppColors.appAccent)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle")
                        .foregroundColor(AppColors.appAccent)
                }
            }
            .padding()
            .background(AppColors.tertiaryBackground)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func languageName(_ code: String) -> String {
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

struct LanguageSelector: View {
    @Binding var selectedLanguage: String
    let languages: [(String, String)]
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(AppColors.secondaryText)
            
            Menu {
                ForEach(languages, id: \.0) { language in
                    Button(action: {
                        selectedLanguage = language.0
                    }) {
                        HStack {
                            Text(getFlag(for: language.0))
                            Text(language.1)
                        }
                    }
                }
            } label: {
                HStack {
                    Text(getFlag(for: selectedLanguage))
                    Text(languages.first(where: { $0.0 == selectedLanguage })?.1 ?? "")
                        .font(.system(size: 14))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                }
                .foregroundColor(AppColors.primaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppColors.inputBackground)
                .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func getFlag(for languageCode: String) -> String {
        switch languageCode {
        case "en": return "🇬🇧"
        case "uk": return "🇺🇦"
        case "ru": return "🇷🇺"
        case "es": return "🇪🇸"
        case "fr": return "🇫🇷"
        case "de": return "🇩🇪"
        case "auto": return "🌐"
        default: return "🌐"
        }
    }
}

#Preview {
    TextTranslatorView()
}
