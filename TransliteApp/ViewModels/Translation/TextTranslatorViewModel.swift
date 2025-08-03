import SwiftUI
import Combine
import AVFoundation

// Import GoogleTranslateParser to access TranslationOption
typealias TranslationOption = GoogleTranslateParser.TranslationOption

@MainActor
final class TextTranslatorViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var sourceText = ""
    @Published var translatedText = ""
    @Published var sourceLanguage = "en"
    @Published var targetLanguage = "en"
    @Published var isTranslating = false
    @Published var isSpeaking = false
    @Published var showLanguagePicker = false
    @Published var isSelectingSourceLanguage = true
    @Published var translationOptions: [TranslationOption] = []
    @Published var showTranslationOptions = false
    
    // MARK: - Services
    private let translationManager = TranslationManager.shared
    private let historyManager = TranslationHistoryManager.shared
    private let cacheManager = SmartCacheManager.shared
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    // MARK: - Properties
    private var translationTask: Task<Void, Never>?
    private let debounceDelay: TimeInterval = 0.5
    
    // Delayed history saving
    private var historyTimer: Timer?
    private var pendingHistoryItem: (sourceText: String, translatedText: String, sourceLanguage: String, targetLanguage: String)?
    
    // Typing activity tracking
    private var isUserTyping = false
    private var typingTimer: Timer?
    private var lastTextChangeTime = Date()
    
    override init() {
        super.init()
        setupBindings()
        loadLastUsedLanguages()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Track text changes to detect typing activity
        $sourceText
            .sink { [weak self] _ in
                self?.onTextChanged()
            }
            .store(in: &cancellables)
        
        // Auto-translate when source text changes (with longer debounce)
        $sourceText
            .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main) // Increased to 1 second
            .removeDuplicates()
            .sink { [weak self] text in
                guard !text.isEmpty else {
                    self?.clearTranslation()
                    return
                }
                self?.translate()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Typing Activity Tracking
    private func onTextChanged() {
        lastTextChangeTime = Date()
        
        // Mark as typing
        if !isUserTyping {
            isUserTyping = true
            cancelPendingHistorySave() // Cancel any pending saves while typing
        }
        
        // Reset typing timer - user is still typing
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.onTypingFinished()
        }
    }
    
    private func onTypingFinished() {
        isUserTyping = false
        typingTimer?.invalidate()
        typingTimer = nil
        
        // Now that typing is finished, try to schedule history save if there's a translation
        if !translatedText.isEmpty && !sourceText.isEmpty {
            scheduleHistorySave()
        }
    }
    
    // MARK: - Public Methods
    func translate() {
        guard !sourceText.isEmpty else { return }
        
        // Don't cancel history save if not typing (e.g., manual translate call)
        if isUserTyping {
            cancelPendingHistorySave()
        }
        
        translationTask?.cancel()
        translationTask = Task { [weak self] in
            guard let self = self else { return }
            
            self.isTranslating = true
            self.clearError()
            
            do {
                // Try to get translation with options
                if let parser = self.translationManager.googleParser {
                    let options = try await parser.translateWithOptions(
                        text: self.sourceText,
                        from: self.sourceLanguage,
                        to: self.targetLanguage
                    )
                    
                    self.translationOptions = options
                    self.translatedText = options.first?.text ?? ""
                    self.showTranslationOptions = options.count > 1
                } else {
                    // Fallback to simple translation
                    let result = try await self.translationManager.translate(
                        text: self.sourceText,
                        from: self.sourceLanguage,
                        to: self.targetLanguage
                    )
                    self.translatedText = result
                    self.translationOptions = []
                    self.showTranslationOptions = false
                }
                
                // Schedule delayed history save
                self.scheduleHistorySave()
                
            } catch {
                self.handleError(error)
                self.translatedText = ""
                self.translationOptions = []
            }
            
            self.isTranslating = false
        }
    }
    
    func swapLanguages() {
        // Allow swap for all languages
        
        let temp = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = temp
        
        if !translatedText.isEmpty {
            sourceText = translatedText
            translate()
        }
        
        saveLastUsedLanguages()
    }
    
    func clearAll() {
        cancelPendingHistorySave()
        sourceText = ""
        translatedText = ""
        translationOptions = []
        showTranslationOptions = false
        clearError()
    }
    
    func copyTranslation() {
        UIPasteboard.general.string = translatedText
    }
    
    func shareTranslation() {
        // This will be handled by the view
    }
    
    func speakTranslation() {
        guard !translatedText.isEmpty else { return }
        
        if isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
            isSpeaking = false
        } else {
            let utterance = AVSpeechUtterance(string: translatedText)
            utterance.voice = AVSpeechSynthesisVoice(language: targetLanguage)
            utterance.rate = 0.5
            
            speechSynthesizer.speak(utterance)
            isSpeaking = true
            
            // Monitor when speech finishes
            Task {
                while speechSynthesizer.isSpeaking {
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
                }
                isSpeaking = false
            }
        }
    }
    
    func selectLanguage(_ language: String, isSource: Bool) {
        if isSource {
            sourceLanguage = language
        } else {
            targetLanguage = language
        }
        
        saveLastUsedLanguages()
        
        if !sourceText.isEmpty {
            translate()
        }
    }
    
    func selectTranslationOption(_ option: TranslationOption) {
        translatedText = option.text
        showTranslationOptions = false
    }
    
    // Public method to save any pending history (call when view disappears)
    func saveAnyPendingHistoryPublic() {
        saveAnyPendingHistory()
    }
    
    // MARK: - Private Methods
    private func clearTranslation() {
        translatedText = ""
        translationOptions = []
        showTranslationOptions = false
    }
    
    // MARK: - Delayed History Saving
    
    private func scheduleHistorySave() {
        guard !sourceText.isEmpty && !translatedText.isEmpty else { return }
        
        // Don't schedule save if user is still typing
        if isUserTyping {
            return
        }
        
        // Cancel previous timer (prevents saving previous translation)
        historyTimer?.invalidate()
        
        // Store pending item
        pendingHistoryItem = (
            sourceText: sourceText,
            translatedText: translatedText,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage
        )
        
        // Schedule save after 5 seconds of inactivity (only if not typing)
        historyTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            // Double-check user is not typing when timer fires
            if self?.isUserTyping == false {
                self?.saveDelayedHistory()
            }
        }
    }
    
    private func cancelPendingHistorySave() {
        historyTimer?.invalidate()
        historyTimer = nil
        pendingHistoryItem = nil
    }
    
    private func saveAnyPendingHistory() {
        historyTimer?.invalidate()
        if let item = pendingHistoryItem {
            historyManager.addTranslation(
                sourceText: item.sourceText,
                translatedText: item.translatedText,
                sourceLanguage: item.sourceLanguage,
                targetLanguage: item.targetLanguage
            )
        }
        pendingHistoryItem = nil
    }
    
    private func saveDelayedHistory() {
        if let item = pendingHistoryItem {
            historyManager.addTranslation(
                sourceText: item.sourceText,
                translatedText: item.translatedText,
                sourceLanguage: item.sourceLanguage,
                targetLanguage: item.targetLanguage
            )
        }
        pendingHistoryItem = nil
    }
    
    private func saveToHistory() {
        guard !sourceText.isEmpty && !translatedText.isEmpty else { return }
        
        historyManager.addTranslation(
            sourceText: sourceText,
            translatedText: translatedText,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage
        )
    }
    
    private func loadLastUsedLanguages() {
        if let savedSource = UserDefaults.standard.string(forKey: "lastSourceLanguage") {
            sourceLanguage = savedSource
        }
        if let savedTarget = UserDefaults.standard.string(forKey: "lastTargetLanguage") {
            targetLanguage = savedTarget
        }
    }
    
    private func saveLastUsedLanguages() {
        UserDefaults.standard.set(sourceLanguage, forKey: "lastSourceLanguage")
        UserDefaults.standard.set(targetLanguage, forKey: "lastTargetLanguage")
    }
    
    func cleanup() {
        // Save any pending history before cleanup
        saveAnyPendingHistory()
        
        // Cancel typing and history timers
        typingTimer?.invalidate()
        typingTimer = nil
        
        // Cancel any ongoing translation
        translationTask?.cancel()
        translationTask = nil
        
        // Stop speech synthesis
        speechSynthesizer.stopSpeaking(at: .immediate)
        
        // Clear states
        isTranslating = false
        isSpeaking = false
        isUserTyping = false
    }
    
    deinit {
        print("🗑️ TextTranslatorViewModel deinit called")
        
        // Save any pending history before deinit
        if let item = pendingHistoryItem {
            // Call synchronously since we're in deinit
            Task { @MainActor in
                self.historyManager.addTranslation(
                    sourceText: item.sourceText,
                    translatedText: item.translatedText,
                    sourceLanguage: item.sourceLanguage,
                    targetLanguage: item.targetLanguage
                )
            }
        }
        
        // Cancel timers and translation task (safe to call from any thread)
        historyTimer?.invalidate()
        typingTimer?.invalidate()
        translationTask?.cancel()
        
        // Stop speech synthesis (safe to call from any thread)
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
}