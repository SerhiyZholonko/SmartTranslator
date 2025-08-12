import Foundation

@MainActor
class TranslationManager: ObservableObject {
    static let shared = TranslationManager()
    
    @Published private var selectedService: TranslationService
    @Published var selectedMode: TranslationMode
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
        selectedMode = UserDefaults.standard.selectedTranslationMode
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
        // Check user daily limit
        guard userUsageTracker.canTranslateToday else {
            throw TranslationError.dailyLimitExceeded
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
            
            // Record successful translation
            await MainActor.run {
                userUsageTracker.recordTranslation()
                saveUserUsageTracker()
            }
            
            return result
        } catch {
            // Try fallback services based on current mode and selection
            switch selectedMode {
            case .regular:
                // In regular mode, fallback based on selected service
                switch selectedService {
                case .apple:
                    print("Apple Translation failed, falling back to Google: \(error)")
                    return try await googleTranslator.translate(
                        text: text,
                        from: sourceLanguage,
                        to: targetLanguage
                    )
                case .google, .groqAI:
                    // For Google failures (or Groq in regular mode), try offline translation
                    print("Translation failed, trying offline: \(error)")
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
            case .ai:
                // In AI mode, fallback to selected regular service
                print("AI Translation failed, falling back to selected service: \(error)")
                switch selectedService {
                case .apple:
                    return try await appleTranslator.translate(
                        text: text,
                        from: sourceLanguage,
                        to: targetLanguage
                    )
                case .google, .groqAI:
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
        // Enhanced translation with multiple options - consider both mode and service
        switch selectedMode {
        case .regular:
            // In regular mode, use selected service
            return try await translateWithSelectedService(
                text: text,
                from: sourceLanguage,
                to: targetLanguage
            )
        case .ai:
            // In AI mode, prefer Groq AI regardless of selected service
            if groqTranslator.isAvailable {
                do {
                    return try await groqTranslator.getEnhancedTranslations(
                        text: text,
                        from: sourceLanguage,
                        to: targetLanguage
                    )
                } catch {
                    print("Groq AI failed, falling back to selected service: \(error)")
                    return try await translateWithSelectedService(
                        text: text,
                        from: sourceLanguage,
                        to: targetLanguage
                    )
                }
            } else {
                // AI not available, use selected service
                return try await translateWithSelectedService(
                    text: text,
                    from: sourceLanguage,
                    to: targetLanguage
                )
            }
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
        // Respect user's service selection, but consider translation mode
        switch selectedMode {
        case .regular:
            // In regular mode, use the selected service (Google/Apple) 
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
                // Even if Groq is selected as service, use Google in regular mode
                return try await googleTranslator.translate(
                    text: text,
                    from: sourceLanguage,
                    to: targetLanguage
                )
            }
        case .ai:
            // In AI mode, try to use AI regardless of selected service
            if groqTranslator.isAvailable {
                let options = try await groqTranslator.getEnhancedTranslations(
                    text: text,
                    from: sourceLanguage,
                    to: targetLanguage
                )
                return options.first?.text ?? ""
            } else {
                // Fallback to selected service if AI not available
                switch selectedService {
                case .google, .groqAI:
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
                }
            }
        }
    }
    
    // MARK: - Translation Mode Management
    
    func setTranslationMode(_ mode: TranslationMode) {
        selectedMode = mode
        UserDefaults.standard.selectedTranslationMode = mode
    }
    
    func translateWithMode(
        text: String,
        from sourceLanguage: String = "en",
        to targetLanguage: String
    ) async throws -> [GoogleTranslateParser.TranslationOption] {
        // Check user daily limit
        guard userUsageTracker.canTranslateToday else {
            throw TranslationError.dailyLimitExceeded
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
            let result: [GoogleTranslateParser.TranslationOption]
            
            switch selectedMode {
            case .regular:
                // Use user-selected translation service (from Settings)
                result = try await translateWithSelectedService(
                    text: text,
                    from: sourceLanguage,
                    to: targetLanguage
                )
            case .ai:
                // Use AI translation if available
                if groqTranslator.isAvailable {
                    result = try await groqTranslator.getEnhancedTranslations(
                        text: text,
                        from: sourceLanguage,
                        to: targetLanguage
                    )
                } else {
                    // Fallback to regular if AI not available
                    result = try await googleTranslator.translateWithOptions(
                        text: text,
                        from: sourceLanguage,
                        to: targetLanguage
                    )
                }
            }
            
            // Record successful translation
            await MainActor.run {
                userUsageTracker.recordTranslation()
                saveUserUsageTracker()
            }
            
            return result
        } catch {
            throw error
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
            // In regular mode, even if Groq is selected, use Google for consistency
            // Groq should only be used when AI mode is explicitly selected
            return try await googleTranslator.translateWithOptions(
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
}