import SwiftUI
import Speech
import AVFoundation

struct TextTranslatorView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var historyManager = TranslationHistoryManager.shared
    @StateObject private var translationService = GoogleTranslateParser()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @StateObject private var permissionsManager = PermissionsManager.shared
    @StateObject private var flashcardManager = FlashcardManager.shared
    
    @State private var sourceLanguage = "auto"
    @State private var targetLanguage = "en"
    @State private var inputText = ""
    @State private var translatedText = ""
    @State private var isTranslating = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var alternatives: [String] = []
    @State private var isRecording = false
    @State private var showPermissionAlert = false
    @State private var showFlashcardOptions = false
    @State private var selectedDeck: FlashcardDeck?
    @State private var showDeckSelection = false
    @State private var flashcardSaved = false
    
    let languages = [
        ("auto", "Auto-detect"),
        ("en", "English"),
        ("uk", "Ukrainian"),
        ("ru", "Russian"),
        ("es", "Spanish"),
        ("fr", "French"),
        ("de", "German")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("Text Translator")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Spacer()
                    
                    Button(action: { swapLanguages() }) {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                    .disabled(sourceLanguage == "auto")
                }
                .padding()
                .background(Color.white)
                
                // Language selectors
                HStack(spacing: 16) {
                    LanguageSelector(
                        selectedLanguage: $sourceLanguage,
                        languages: languages,
                        title: "From"
                    )
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.gray)
                    
                    LanguageSelector(
                        selectedLanguage: $targetLanguage,
                        languages: languages.filter { $0.0 != "auto" },
                        title: "To"
                    )
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Input area
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Enter text")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Text("\(inputText.count) / 5000")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            
                            TextEditor(text: $inputText)
                                .frame(minHeight: 120)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                                .onChange(of: inputText) { _ in
                                    if inputText.count > 5000 {
                                        inputText = String(inputText.prefix(5000))
                                    }
                                }
                            
                            HStack {
                                Button(action: { inputText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                                .opacity(inputText.isEmpty ? 0 : 1)
                                
                                Spacer()
                                
                                // Voice input button
                                Button(action: toggleVoiceInput) {
                                    Image(systemName: isRecording ? "mic.fill" : "mic")
                                        .foregroundColor(isRecording ? .red : .blue)
                                        .font(.system(size: 20))
                                }
                                
                                Button(action: pasteFromClipboard) {
                                    Image(systemName: "doc.on.clipboard")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Translate button
                        Button(action: translate) {
                            HStack {
                                if isTranslating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "globe")
                                    Text("Translate")
                                }
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .cornerRadius(25)
                        }
                        .padding(.horizontal)
                        .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTranslating)
                        
                        // Translation result
                        if !translatedText.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Translation")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    // Add to Flashcards button
                                    Button(action: { showDeckSelection = true }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: flashcardSaved ? "checkmark.circle.fill" : "plus.circle")
                                                .foregroundColor(flashcardSaved ? .green : .orange)
                                            if !flashcardSaved {
                                                Text("Add to Flashcards")
                                                    .font(.caption)
                                                    .foregroundColor(.orange)
                                            }
                                        }
                                    }
                                    .disabled(flashcardSaved)
                                    
                                    Button(action: copyTranslation) {
                                        Image(systemName: "doc.on.doc")
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                Text(translatedText)
                                    .font(.system(size: 16))
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(12)
                                
                                // Alternatives
                                if !alternatives.isEmpty {
                                    Text("Alternatives")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    
                                    ForEach(alternatives, id: \.self) { alternative in
                                        Text(alternative)
                                            .font(.system(size: 14))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.gray.opacity(0.1))
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
            .background(Color(UIColor.systemBackground))
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Потрібен доступ до мікрофона", isPresented: $showPermissionAlert) {
            Button("Відкрити Налаштування", action: openSettings)
            Button("Скасувати", role: .cancel) { }
        } message: {
            Text("Будь ласка, увімкніть доступ до мікрофона в Налаштуваннях для використання голосового вводу.")
        }
        .sheet(isPresented: $showDeckSelection) {
            DeckSelectionView(
                decks: flashcardManager.decks,
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
    }
    
    private func translate() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isTranslating = true
        translatedText = ""
        alternatives = []
        flashcardSaved = false // Reset flashcard saved status
        
        Task {
            do {
                let result = try await translationService.translate(
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
                    
                    isTranslating = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isTranslating = false
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
        
        flashcardManager.addFlashcardToDeck(flashcard, deck: deck)
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
}

// MARK: - Deck Selection View

struct DeckSelectionView: View {
    let decks: [FlashcardDeck]
    let onDeckSelected: (FlashcardDeck) -> Void
    let onCreateNew: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Choose a deck to add this flashcard")
                    .font(.headline)
                    .padding(.top)
                
                if decks.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "rectangle.stack.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No decks available")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Create your first deck to start collecting flashcards")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(decks) { deck in
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
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create New Deck")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
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
                
                if !deck.description.isEmpty {
                    Text(deck.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text("\(deck.flashcardIds.count) cards")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func languageName(_ code: String) -> String {
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

struct LanguageSelector: View {
    @Binding var selectedLanguage: String
    let languages: [(String, String)]
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
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
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
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
