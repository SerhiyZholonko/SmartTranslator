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
                    .onChange(of: localizationManager.currentLanguage) { _, _ in
                        saveSettings()
                    }
                    
                    NavigationLink(destination: ThemeSettingsView()) {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .foregroundColor(AppColors.appAccent)
                            Text("app_theme".localized)
                                .foregroundColor(AppColors.primaryText)
                        }
                    }
                }
                
                Section(header: Text("default_source_language".localized)) {
                    Picker("source_language".localized, selection: $defaultSourceLanguage) {
                        Text("auto_detect".localized).tag("auto")
                        Text("language_english".localized).tag("en")
                        Text("language_ukrainian".localized).tag("uk")
                        Text("language_chinese_simplified".localized).tag("zh")
                        Text("language_spanish".localized).tag("es")
                        Text("language_french".localized).tag("fr")
                        Text("language_german".localized).tag("de")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: defaultSourceLanguage) { _, _ in
                        saveSettings()
                    }
                    
                    Picker("target_language".localized, selection: $defaultTargetLanguage) {
                        Text("language_ukrainian".localized).tag("uk")
                        Text("language_english".localized).tag("en")
                        Text("language_chinese_simplified".localized).tag("zh")
                        Text("language_spanish".localized).tag("es")
                        Text("language_french".localized).tag("fr")
                        Text("language_german".localized).tag("de")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: defaultTargetLanguage) { _, _ in
                        saveSettings()
                    }
                }
                
                Section(header: Text("cache_settings".localized)) {
                    Toggle("enable_smart_cache".localized, isOn: $enableSmartCache)
                        .onChange(of: enableSmartCache) { _, _ in
                            saveSettings()
                        }
                    
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
                            set: { 
                                maxCacheSize = Int($0)
                                saveSettings()
                            }
                        ), in: 10...100, step: 10)
                        
                        Button("clear_cache".localized) {
                            SmartCacheManager.shared.clearCache()
                        }
                        .foregroundColor(AppColors.warningColor)
                    }
                }
                
                Section(header: Text("history_title".localized)) {
                    Toggle("save_translation_history".localized, isOn: $enableHistory)
                        .onChange(of: enableHistory) { _, _ in
                            saveSettings()
                        }
                    
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
        saveSettings() // Save the reset values
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
        
        var activityItems: [Any] = [shareText]
        
        // Check if app is published on App Store
        if let appStoreURL = getAppStoreURL() {
            activityItems.append(appStoreURL)
        } else {
            // For development - share GitHub repository or website
            if let websiteURL = URL(string: "https://github.com/SerhiyZholonko/SmartTranslator") {
                activityItems.append(websiteURL)
            }
        }
        
        let activityVC = UIActivityViewController(
            activityItems: activityItems, 
            applicationActivities: nil
        )
        
        // Exclude some activity types if needed
        activityVC.excludedActivityTypes = [
            .assignToContact,
            .saveToCameraRoll
        ]
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first {
            keyWindow.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func getAppStoreURL() -> URL? {
        // Check if running from TestFlight
        if isRunningFromTestFlight() {
            // TestFlight public link - replace with your actual TestFlight invite link
            return URL(string: "https://testflight.apple.com/join/YOUR_TESTFLIGHT_CODE")
        }
        
        // Check if it's a release build (App Store)
        #if DEBUG
        // For development/debug builds, return nil to use GitHub
        return nil
        #else
        // For App Store release builds
        return URL(string: "https://apps.apple.com/app/smart-translator/idYOUR_APP_ID")
        #endif
    }
    
    private func isRunningFromTestFlight() -> Bool {
        // Check if the app is running from TestFlight
        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            return false
        }
        
        return receiptURL.path.contains("sandboxReceipt")
    }
    
    
}

#Preview {
    SettingsView()
}
