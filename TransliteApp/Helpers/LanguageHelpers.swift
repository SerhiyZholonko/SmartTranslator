import Foundation

// MARK: - Language Helpers

/// Utility functions for language display and management
struct LanguageHelpers {
    
    /// Supported languages with their codes and localized names
    static let supportedLanguages: [(code: String, nameKey: String)] = [
        ("en", "language_english"),
        ("uk", "language_ukrainian"),
        ("zh", "language_chinese_simplified"),
        ("es", "language_spanish"),
        ("fr", "language_french"),
        ("de", "language_german")
    ]
    
    /// Supported voice languages with locale codes
    static let supportedVoiceLanguages: [(code: String, nameKey: String)] = [
        ("en-US", "language_english"),
        ("uk-UA", "language_ukrainian"),
        ("zh-CN", "language_chinese_simplified"),
        ("es-ES", "language_spanish"),
        ("fr-FR", "language_french"),
        ("de-DE", "language_german")
    ]
    
    /// Get flag emoji for language code (supports both simple and locale codes)
    static func getFlag(for languageCode: String) -> String {
        switch languageCode {
        case "en", "en-US": return "🇬🇧"
        case "uk", "uk-UA": return "🇺🇦"
        case "zh", "zh-CN": return "🇨🇳"
        case "es", "es-ES": return "🇪🇸"
        case "fr", "fr-FR": return "🇫🇷"
        case "de", "de-DE": return "🇩🇪"
        default: return "🌐"
        }
    }
    
    /// Get localized language name (supports both simple and locale codes)
    static func getLocalizedName(for languageCode: String) -> String {
        // Try voice languages first (for locale codes)
        if let language = supportedVoiceLanguages.first(where: { $0.code == languageCode }) {
            return language.nameKey.localized
        }
        
        // Try regular languages
        if let language = supportedLanguages.first(where: { $0.code == languageCode }) {
            return language.nameKey.localized
        }
        
        return languageCode.uppercased()
    }
    
    /// Get full display string with flag and name
    static func getDisplayString(for languageCode: String) -> String {
        return "\(getFlag(for: languageCode)) \(getLocalizedName(for: languageCode))"
    }
    
    /// Get list of languages as (code, displayString) tuples with flags
    static func getLanguagesForDisplay() -> [(String, String)] {
        return supportedLanguages.map { (code, nameKey) in
            (code, "\(getFlag(for: code)) \(nameKey.localized)")
        }
    }
    
    /// Get list of languages as (code, nameOnly) tuples without flags
    static func getLanguagesForDisplayWithoutFlags() -> [(String, String)] {
        return supportedLanguages.map { (code, nameKey) in
            (code, nameKey.localized)
        }
    }
    
    /// Get list of voice languages as (code, displayString) tuples with flags
    static func getVoiceLanguagesForDisplay() -> [(String, String)] {
        return supportedVoiceLanguages.map { (code, nameKey) in
            (code, "\(getFlag(for: code)) \(nameKey.localized)")
        }
    }
    
    /// Get list of voice languages as (code, nameOnly) tuples without flags
    static func getVoiceLanguagesForDisplayWithoutFlags() -> [(String, String)] {
        return supportedVoiceLanguages.map { (code, nameKey) in
            (code, nameKey.localized)
        }
    }
}