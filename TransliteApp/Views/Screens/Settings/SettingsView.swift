import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var defaultSourceLanguage = "auto"
    @State private var defaultTargetLanguage = "uk"
    @State private var enableSmartCache = true
    @State private var maxCacheSize = 50
    @State private var enableHistory = true
    @State private var selectedTranslationService: TranslationService = UserDefaults.standard.selectedTranslationService
    @State private var showingServiceAlert = false
    // Combined version and build
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    var body: some View {
        LocalizedView {
        NavigationView {
            ZStack {
                // Theme-aware background matching main screen
                AppColors.appBackground
                    .ignoresSafeArea()
                
            Form {
                Section(header: Text("translation_service".localized)) {
                    Picker("Service", selection: $selectedTranslationService) {
                        ForEach(TranslationService.allCases, id: \.self) { service in
                            HStack {
                                Image(systemName: service.systemImageName)
                                Text(service.displayName)
                            }
                            .tag(service)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedTranslationService) { oldValue, newValue in
                        if !newValue.isAvailable {
                            selectedTranslationService = oldValue
                            showingServiceAlert = true
                        } else {
                            UserDefaults.standard.selectedTranslationService = newValue
                        }
                    }
                    
                    if selectedTranslationService == .apple {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(AppColors.appAccent)
                            Text("apple_translation_ios_requirement".localized)
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                }
                
                Section(header: Text("general".localized)) {
                    Picker("app_language".localized, selection: $localizationManager.currentLanguage) {
                        ForEach(SupportedLanguage.supportedLanguages, id: \.id) { language in
                            Text(language.name)
                                .tag(language.code)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("default_source_language".localized)) {
                    Picker("source_language".localized, selection: $defaultSourceLanguage) {
                        Text("auto_detect".localized).tag("auto")
                        Text("language_english".localized).tag("en")
                        Text("language_ukrainian".localized).tag("uk")
                        Text("language_russian".localized).tag("ru")
                        Text("language_spanish".localized).tag("es")
                        Text("language_french".localized).tag("fr")
                        Text("language_german".localized).tag("de")
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Picker("target_language".localized, selection: $defaultTargetLanguage) {
                        Text("language_ukrainian".localized).tag("uk")
                        Text("language_english".localized).tag("en")
                        Text("language_russian".localized).tag("ru")
                        Text("language_spanish".localized).tag("es")
                        Text("language_french".localized).tag("fr")
                        Text("language_german".localized).tag("de")
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("cache_settings".localized)) {
                    Toggle("enable_smart_cache".localized, isOn: $enableSmartCache)
                    
                    if enableSmartCache {
                        let cacheStats = SmartCacheManager.shared.getCacheStatistics()
                        
                        HStack {
                            Text("cache_usage".localized)
                            Spacer()
                            Text(String(format: "%.1f MB of %d MB", cacheStats.sizeInMB, maxCacheSize))
                                .foregroundColor(AppColors.secondaryText)
                        }
                        
                        HStack {
                            Text("cached_items".localized)
                            Spacer()
                            Text("\(cacheStats.itemCount)")
                                .foregroundColor(AppColors.secondaryText)
                        }
                        
                        HStack {
                            Text("cache_size_limit".localized)
                            Spacer()
                            Text("\(maxCacheSize) MB")
                                .foregroundColor(AppColors.secondaryText)
                        }
                        
                        Slider(value: Binding(
                            get: { Double(maxCacheSize) },
                            set: { maxCacheSize = Int($0) }
                        ), in: 10...100, step: 10)
                        
                        Button("clear_cache".localized) {
                            SmartCacheManager.shared.clearCache()
                        }
                        .foregroundColor(AppColors.warningColor)
                    }
                }
                
                Section(header: Text("history_title".localized)) {
                    Toggle("save_translation_history".localized, isOn: $enableHistory)
                    
                    if enableHistory {
                        Button("clear_history".localized) {
                            clearHistory()
                        }
                        .foregroundColor(AppColors.errorColor)
                    }
                }
                
                Section(header: Text("about".localized)) {
                    HStack {
                        Text("version".localized)
                        Spacer()
                        let fullVersion = "\(version).\(build)"

                        Text(fullVersion)
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    // Menu items from side menu
                    Button(action: requestReview) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(AppColors.warningColor)
                            Text("menu_rate_us".localized)
                                .foregroundColor(AppColors.primaryText)
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: shareApp) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(AppColors.appAccent)
                            Text("menu_share_app".localized)
                                .foregroundColor(AppColors.primaryText)
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    
                    Button(action: openPrivacyPolicy) {
                        HStack {
                            Image(systemName: "shield.fill")
                                .foregroundColor(AppColors.successColor)
                            Text("menu_privacy_policy".localized)
                                .foregroundColor(AppColors.primaryText)
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button("reset_to_defaults".localized) {
                        resetToDefaults()
                    }
                    .foregroundColor(AppColors.appAccent)
                }
                
                // Padding for TabBar
                Section {
                    Color.clear
                        .frame(height: 60)
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.appBackground)
            .navigationTitle("settings_title".localized)
            .navigationBarTitleDisplayMode(.inline)

            }
        }
        }
        .alert("service_not_available".localized, isPresented: $showingServiceAlert) {
            Button("OK") { }
        } message: {
            Text("apple_translation_update_message".localized)
        }
        .onAppear {
            loadSettings()
        }
    }
    
    private func loadSettings() {
        let preferences = UserDefaults.standard
        defaultSourceLanguage = preferences.string(forKey: "defaultSourceLanguage") ?? "auto"
        defaultTargetLanguage = preferences.string(forKey: "defaultTargetLanguage") ?? "uk"
        enableSmartCache = preferences.bool(forKey: "enableSmartCache")
        maxCacheSize = preferences.integer(forKey: "maxCacheSize") == 0 ? 50 : preferences.integer(forKey: "maxCacheSize")
        enableHistory = preferences.bool(forKey: "enableHistory")
        selectedTranslationService = preferences.selectedTranslationService
    }
    
    private func saveSettings() {
        let preferences = UserDefaults.standard
        preferences.set(defaultSourceLanguage, forKey: "defaultSourceLanguage")
        preferences.set(defaultTargetLanguage, forKey: "defaultTargetLanguage")
        preferences.set(enableSmartCache, forKey: "enableSmartCache")
        preferences.set(maxCacheSize, forKey: "maxCacheSize")
        preferences.set(enableHistory, forKey: "enableHistory")
    }
    
    private func clearHistory() {
        TranslationHistoryManager.shared.clearHistory()
    }
    
    private func resetToDefaults() {
        defaultSourceLanguage = "auto"
        defaultTargetLanguage = "uk"
        enableSmartCache = true
        maxCacheSize = 50
        enableHistory = true
        selectedTranslationService = .google
        UserDefaults.standard.selectedTranslationService = .google
    }
    
    // MARK: - Menu Actions
    
    private func requestReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    private func shareApp() {
        let appName = "app_name".localized
        let shareText = "Check out \(appName) - the smart translation app!"
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first {
            keyWindow.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://smarttranslator.com/privacy") {
            UIApplication.shared.open(url)
        }
    }
    
}

#Preview {
    SettingsView()
}
