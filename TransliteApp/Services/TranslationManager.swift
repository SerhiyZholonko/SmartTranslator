import Foundation

class TranslationManager: ObservableObject {
    static let shared = TranslationManager()
    
    @Published private var selectedService: TranslationService
    @Published var isTranslating = false
    
    private let googleTranslator = GoogleTranslateParser()
    private let appleTranslator = AppleTranslationServiceWrapper.shared
    
    private init() {
        selectedService = UserDefaults.standard.selectedTranslationService
        
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
        from sourceLanguage: String = "auto",
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
            // If primary service fails, try fallback
            if selectedService == .apple {
                print("Apple Translation failed, falling back to Google: \(error)")
                return try await googleTranslator.translate(
                    text: text,
                    from: sourceLanguage,
                    to: targetLanguage
                )
            } else {
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
        from sourceLanguage: String = "auto",
        to targetLanguage: String
    ) async throws -> [GoogleTranslateParser.TranslationOption] {
        // Multiple options currently only supported by Google Translate
        if selectedService == .google {
            return try await googleTranslator.translateWithOptions(
                text: text,
                from: sourceLanguage,
                to: targetLanguage
            )
        } else {
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
        }
    }
}