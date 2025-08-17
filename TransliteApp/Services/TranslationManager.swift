import Foundation

@MainActor
class TranslationManager: ObservableObject {
    static let shared = TranslationManager()
    
    @Published private var selectedService: TranslationService
    // AI mode removed - AI only used for flashcards, not regular translation
    @Published var isTranslating = false
    @Published var userUsageTracker = UserUsageTracker()
    
    private let googleTranslator = GoogleTranslateParser()
    private let appleTranslator = AppleTranslationServiceWrapper.shared
    private let groqTranslator: GroqTranslationService
    
    private let userUsageTrackerKey = "user_usage_tracker"
    
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
        // selectedMode removed - AI only for flashcards
        groqTranslator = GroqTranslationService.shared
        
        // Load user usage tracker
        loadUserUsageTracker()
        
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
        // Check user daily limit only for Groq AI (premium feature with limits)
        // Google and Apple Translation should work freely
        if selectedService == .groqAI {
            guard userUsageTracker.canTranslateToday else {
                throw TranslationError.dailyLimitExceeded
            }
        }
        
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
            
            // Record successful translation only for Groq AI (limited service)
            if selectedService == .groqAI {
                await MainActor.run {
                    userUsageTracker.recordTranslation()
                    saveUserUsageTracker()
                }
            }
            
            return result
        } catch {
            // Try fallback services based on selected service (AI mode removed)
            switch selectedService {
                case .google:
                    print("Google Translation failed, falling back to Apple: \(error)")
                    do {
                        return try await appleTranslator.translate(
                            text: text,
                            from: sourceLanguage,
                            to: targetLanguage
                        )
                    } catch {
                        print("Apple Translation failed, trying offline: \(error)")
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
                case .apple:
                    print("Apple Translation failed, falling back to Google: \(error)")
                    return try await googleTranslator.translate(
                        text: text,
                        from: sourceLanguage,
                        to: targetLanguage
                    )
                case .groqAI:
                    // For Groq in regular mode, try Apple first, then Google
                    print("Groq Translation failed, falling back to Apple: \(error)")
                    do {
                        return try await appleTranslator.translate(
                            text: text,
                            from: sourceLanguage,
                            to: targetLanguage
                        )
                    } catch {
                        print("Apple Translation failed, falling back to Google: \(error)")
                        return try await googleTranslator.translate(
                            text: text,
                            from: sourceLanguage,
                            to: targetLanguage
                        )
                    }
                }
        }
    }
    
    func translateWithOptions(
        text: String,
        from sourceLanguage: String = "en",
        to targetLanguage: String
    ) async throws -> [GoogleTranslateParser.TranslationOption] {
        // Use selected service only (AI removed from regular translation)
        return try await translateWithSelectedService(
            text: text,
            from: sourceLanguage,
            to: targetLanguage
        )
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
        // Use selected service only (AI removed from regular translation)
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
            // Use Groq AI when selected
            let options = try await groqTranslator.getEnhancedTranslations(
                text: text,
                from: sourceLanguage,
                to: targetLanguage
            )
            // Return the first (best) translation option
            return options.first?.text ?? text
        }
    }
    
    // MARK: - Translation Methods (AI mode removed)
    
    // AI Translation for Flashcards only
    func translateForFlashcard(
        text: String,
        from sourceLanguage: String = "en",
        to targetLanguage: String
    ) async throws -> [GoogleTranslateParser.TranslationOption] {
        // Check if AI is available for flashcard generation
        if groqTranslator.isAvailable {
            do {
                return try await groqTranslator.getEnhancedTranslations(
                    text: text,
                    from: sourceLanguage,
                    to: targetLanguage
                )
            } catch {
                print("AI Translation failed for flashcard, falling back to Google: \(error)")
                // Fallback to Google for flashcard creation
                return try await googleTranslator.translateWithOptions(
                    text: text,
                    from: sourceLanguage,
                    to: targetLanguage
                )
            }
        } else {
            // AI not available, use Google for flashcard options
            return try await googleTranslator.translateWithOptions(
                text: text,
                from: sourceLanguage,
                to: targetLanguage
            )
        }
    }
    
    
    // MARK: - Service-Specific Translation
    
    private func translateWithSelectedService(
        text: String,
        from sourceLanguage: String,
        to targetLanguage: String
    ) async throws -> [GoogleTranslateParser.TranslationOption] {
        switch selectedService {
        case .google:
            return try await googleTranslator.translateWithOptions(
                text: text,
                from: sourceLanguage,
                to: targetLanguage
            )
        case .apple:
            // Apple Translation doesn't provide multiple options, so create a single option
            let translation = try await appleTranslator.translate(
                text: text,
                from: sourceLanguage,
                to: targetLanguage
            )
            return [GoogleTranslateParser.TranslationOption(
                text: translation,
                confidence: 0.95,
                category: .primary,
                frequency: "High",
                partOfSpeech: nil
            )]
        case .groqAI:
            // Use Groq AI to get enhanced translations with multiple options
            return try await groqTranslator.getEnhancedTranslations(
                text: text,
                from: sourceLanguage,
                to: targetLanguage
            )
        }
    }
    
    // MARK: - User Usage Tracking
    
    private func loadUserUsageTracker() {
        if let data = UserDefaults.standard.data(forKey: userUsageTrackerKey),
           let tracker = try? JSONDecoder().decode(UserUsageTracker.self, from: data) {
            userUsageTracker = tracker
        }
    }
    
    private func saveUserUsageTracker() {
        if let data = try? JSONEncoder().encode(userUsageTracker) {
            UserDefaults.standard.set(data, forKey: userUsageTrackerKey)
        }
    }
    
    func resetUserDailyUsage() {
        userUsageTracker.resetDaily()
        saveUserUsageTracker()
    }
    
    // MARK: - Public Access to Usage Stats
    
    var canTranslateToday: Bool {
        return userUsageTracker.canTranslateToday
    }
    
    var remainingTranslations: Int {
        return userUsageTracker.remainingDailyTranslations
    }
    
    var usageStatusMessage: String {
        return userUsageTracker.statusMessage
    }
    
    // Check if user is approaching daily limit
    var isApproachingLimit: Bool {
        return userUsageTracker.remainingDailyTranslations <= 2 && userUsageTracker.remainingDailyTranslations > 0
    }
    
    // Check if Groq AI is approaching limit
    var isGroqApproachingLimit: Bool {
        return groqTranslator.isApproachingLimit
    }
}