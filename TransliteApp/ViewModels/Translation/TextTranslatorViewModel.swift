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
    
    override init() {
        super.init()
        setupBindings()
        loadLastUsedLanguages()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Auto-translate when source text changes
        $sourceText
            .debounce(for: .seconds(debounceDelay), scheduler: DispatchQueue.main)
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
    
    // MARK: - Public Methods
    func translate() {
        guard !sourceText.isEmpty else { return }
        
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
                
                // Save to history
                self.saveToHistory()
                
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
    
    // MARK: - Private Methods
    private func clearTranslation() {
        translatedText = ""
        translationOptions = []
        showTranslationOptions = false
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
    
    deinit {
        translationTask?.cancel()
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
}