import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var selectedLanguage: String
    @Published var autoDetectLanguage = true
    @Published var saveHistory = true
    @Published var enableCache = true
    @Published var showClearDataAlert = false
    @Published var cacheSize: String = "0 MB"
    @Published var historyCount: Int = 0
    
    // MARK: - Services
    private let localizationManager = LocalizationManager.shared
    private let cacheManager = SmartCacheManager.shared
    private let historyManager = TranslationHistoryManager.shared
    
    // MARK: - Properties
    let availableLanguages = [
        ("en", "English"),
        ("uk", "Українська"),
        ("ru", "Русский"),
        ("es", "Español"),
        ("fr", "Français"),
        ("de", "Deutsch")
    ]
    
    override init() {
        self.selectedLanguage = localizationManager.currentLanguage
        super.init()
        loadSettings()
        calculateCacheSize()
        updateHistoryCount()
    }
    
    // MARK: - Public Methods
    func changeLanguage(_ language: String) {
        selectedLanguage = language
        localizationManager.setLanguage(language)
        saveSettings()
    }
    
    func toggleAutoDetect() {
        autoDetectLanguage.toggle()
        saveSettings()
    }
    
    func toggleSaveHistory() {
        saveHistory.toggle()
        saveSettings()
        
        if !saveHistory {
            // Optionally clear history when disabled
            showClearDataAlert = true
        }
    }
    
    func toggleCache() {
        enableCache.toggle()
        saveSettings()
        
        if !enableCache {
            clearCache()
        }
    }
    
    func clearCache() {
        cacheManager.clearCache()
        calculateCacheSize()
        showError("cache_cleared".localized)
    }
    
    func clearHistory() {
        historyManager.clearHistory()
        updateHistoryCount()
        showError("history_cleared".localized)
    }
    
    func clearAllData() {
        clearCache()
        clearHistory()
        showError("all_data_cleared".localized)
    }
    
    func exportData() {
        // TODO: Implement data export functionality
        showError("export_coming_soon".localized)
    }
    
    // MARK: - Private Methods
    private func loadSettings() {
        autoDetectLanguage = UserDefaults.standard.bool(forKey: "autoDetectLanguage")
        saveHistory = UserDefaults.standard.bool(forKey: "saveHistory")
        enableCache = UserDefaults.standard.bool(forKey: "enableCache")
        
        // Set defaults if first launch
        if !UserDefaults.standard.bool(forKey: "settingsInitialized") {
            autoDetectLanguage = true
            saveHistory = true
            enableCache = true
            UserDefaults.standard.set(true, forKey: "settingsInitialized")
            saveSettings()
        }
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(autoDetectLanguage, forKey: "autoDetectLanguage")
        UserDefaults.standard.set(saveHistory, forKey: "saveHistory")
        UserDefaults.standard.set(enableCache, forKey: "enableCache")
    }
    
    private func calculateCacheSize() {
        let sizeInMB = cacheManager.getCurrentCacheSizeInMB()
        cacheSize = String(format: "%.1f MB", sizeInMB)
    }
    
    private func updateHistoryCount() {
        historyCount = historyManager.getHistory().count
    }
}

// MARK: - Settings Section
enum SettingsSection: String, CaseIterable {
    case general = "general_settings"
    case data = "data_privacy"
    case about = "about"
    
    var localizedTitle: String {
        rawValue.localized
    }
}