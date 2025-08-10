import Foundation

@MainActor
class TranslationManager: ObservableObject {
    static let shared = TranslationManager()
    
    @Published private var selectedService: TranslationService
    @Published var isTranslating = false
    
    private let googleTranslator = GoogleTranslateParser()
    private let appleTranslator = AppleTranslationServiceWrapper.shared
    private let groqTranslator: GroqTranslationService
    
    // Public access to Google parser for advanced features
    var googleParser: GoogleTranslateParser? {
        return googleTranslator
    }
    
    // Public access to Groq translator
    var groqService: GroqTranslationService {
        return groqTranslator
    }
    
    private init() {
        selectedService = UserDefaults.standard.selectedTranslationService
        groqTranslator = GroqTranslationService.shared
        
        // Auto-switch to AI if available and user hasn't manually selected a service
        Task {
            await checkAndSwitchToAIIfAvailable()
        }
        
        // Listen for service changes
        NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            let newService = UserDefaults.standard.selectedTranslationService
            if self?.selectedService != newService {
                self?.selectedService = newService
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Translation Methods
    
    func translate(
        text: String,
        from sourceLanguage: String = "en",
        to targetLanguage: String
    ) async throws -> String {
        await MainActor.run {
            isTranslating = true
        }
        
        defer {
            Task { @MainActor in
                isTranslating = false
            }
        }
        
        do {
            let result = try await performTranslation(
                text: text,
                from: sourceLanguage,
                to: targetLanguage
            )
            return result
        } catch {
            // Try fallback services based on current selection
            switch selectedService {
            case .apple:
                print("Apple Translation failed, falling back to Google: \(error)")
                return try await googleTranslator.translate(
                    text: text,
                    from: sourceLanguage,
                    to: targetLanguage
                )
            case .groqAI:
                print("Groq AI Translation failed, falling back to Google: \(error)")
                return try await googleTranslator.translate(
                    text: text,
                    from: sourceLanguage,
                    to: targetLanguage
                )
            case .google:
                // For Google failures, try offline translation if available
                print("Google Translation failed: \(error)")
                let offlineResult = BasicOfflineTranslation.shared.translate(
                    text: text,
                    from: sourceLanguage,
                    to: targetLanguage
                )
                
                if let result = offlineResult, !result.isEmpty {
                    return result
                } else {
                    throw error
                }
            }
        }
    }
    
    func translateWithOptions(
        text: String,
        from sourceLanguage: String = "en",
        to targetLanguage: String
    ) async throws -> [GoogleTranslateParser.TranslationOption] {
        // Enhanced translation with multiple options
        switch selectedService {
        case .groqAI:
            // Try Groq AI first for enhanced translations
            do {
                return try await groqTranslator.getEnhancedTranslations(
                    text: text,
                    from: sourceLanguage,
                    to: targetLanguage
                )
            } catch {
                print("Groq AI failed, falling back to Google: \(error)")
                return try await googleTranslator.translateWithOptions(
                    text: text,
                    from: sourceLanguage,
                    to: targetLanguage
                )
            }
        case .google:
            return try await googleTranslator.translateWithOptions(
                text: text,
                from: sourceLanguage,
                to: targetLanguage
            )
        case .apple:
            // For Apple Translation, return single option
            let translation = try await translate(
                text: text,
                from: sourceLanguage,
                to: targetLanguage
            )
            
            return [GoogleTranslateParser.TranslationOption(
                text: translation,
                confidence: 1.0,
                category: .primary,
                frequency: nil,
                partOfSpeech: nil
            )]
        }
    }
    
    // MARK: - Service Information
    
    var currentService: TranslationService {
        selectedService
    }
    
    var currentServiceName: String {
        selectedService.displayName
    }
    
    func canTranslate(from: String, to: String) -> Bool {
        switch selectedService {
        case .google:
            return true // Google supports most language pairs
        case .apple:
            return appleTranslator.canTranslate(from: from, to: to)
        case .groqAI:
            return groqTranslator.isAvailable // Groq supports most language pairs when available
        }
    }
    
    // MARK: - Service Management
    
    func setTranslationService(_ service: TranslationService) {
        selectedService = service
        UserDefaults.standard.selectedTranslationService = service
    }
    
    func getAvailableServices() -> [TranslationService] {
        return TranslationService.allCases.filter { service in
            switch service {
            case .google:
                return true
            case .apple:
                return service.isAvailable
            case .groqAI:
                return groqTranslator.hasApiKeys
            }
        }
    }
    
    private func checkAndSwitchToAIIfAvailable() async {
        // Wait a moment for Groq service to initialize
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        await MainActor.run {
            let hasManuallySelected = UserDefaults.standard.hasUserManuallySelectedService
            
            // If user hasn't manually selected a service and Groq AI is available
            if !hasManuallySelected && groqTranslator.hasApiKeys {
                print("🤖 Auto-switching to Groq AI service")
                selectedService = .groqAI
                UserDefaults.standard.selectedTranslationService = .groqAI
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func performTranslation(
        text: String,
        from sourceLanguage: String,
        to targetLanguage: String
    ) async throws -> String {
        switch selectedService {
        case .google:
            return try await googleTranslator.translate(
                text: text,
                from: sourceLanguage,
                to: targetLanguage
            )
        case .apple:
            return try await appleTranslator.translate(
                text: text,
                from: sourceLanguage,
                to: targetLanguage
            )
        case .groqAI:
            // For single translation, get the best variant from Groq AI
            let options = try await groqTranslator.getEnhancedTranslations(
                text: text,
                from: sourceLanguage,
                to: targetLanguage
            )
            return options.first?.text ?? ""
        }
    }
}