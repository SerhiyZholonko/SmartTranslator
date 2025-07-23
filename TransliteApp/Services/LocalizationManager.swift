import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "AppLanguage")
            // Trigger UI updates by posting notification
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }
    
    private init() {
        // Get saved language or use system default
        if let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage") {
            self.currentLanguage = savedLanguage
        } else {
            // Use system language if available, otherwise default to English
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            let supportedLanguages = ["en", "uk", "ru", "es", "fr", "de"]
            self.currentLanguage = supportedLanguages.contains(systemLanguage) ? systemLanguage : "en"
        }
    }
    
    func setLanguage(_ language: String) {
        currentLanguage = language
    }
    
    func localizedString(for key: String) -> String {
        guard let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            // Fallback to main bundle (English)
            return NSLocalizedString(key, comment: "")
        }
        
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}

// Notification for language changes
extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

// SwiftUI extension for easy localization
extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
    
    func localized(with arguments: CVarArg...) -> String {
        let localizedString = LocalizationManager.shared.localizedString(for: self)
        return String(format: localizedString, arguments: arguments)
    }
}

// View modifier for automatic localization updates
struct LocalizedView<Content: View>: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    private let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
                // Force view refresh when language changes
            }
    }
}

// Language data for picker
struct SupportedLanguage: Identifiable, Hashable {
    let id: String
    let code: String
    let name: String
    let englishName: String
    
    static let supportedLanguages: [SupportedLanguage] = [
        SupportedLanguage(id: "en", code: "en", name: "English", englishName: "English"),
        SupportedLanguage(id: "uk", code: "uk", name: "Українська", englishName: "Ukrainian"),
        SupportedLanguage(id: "ru", code: "ru", name: "Русский", englishName: "Russian"),
        SupportedLanguage(id: "es", code: "es", name: "Español", englishName: "Spanish"),
        SupportedLanguage(id: "fr", code: "fr", name: "Français", englishName: "French"),
        SupportedLanguage(id: "de", code: "de", name: "Deutsch", englishName: "German")
    ]
    
    static func language(for code: String) -> SupportedLanguage {
        return supportedLanguages.first { $0.code == code } ?? supportedLanguages[0]
    }
}