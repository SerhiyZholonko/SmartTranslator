import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var defaultSourceLanguage = "auto"
    @State private var defaultTargetLanguage = "uk"
    @State private var enableSmartCache = true
    @State private var maxCacheSize = 50
    @State private var enableHistory = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Default Languages")) {
                    Picker("Source Language", selection: $defaultSourceLanguage) {
                        Text("Auto Detect").tag("auto")
                        Text("English").tag("en")
                        Text("Ukrainian").tag("uk")
                        Text("Russian").tag("ru")
                        Text("Spanish").tag("es")
                        Text("French").tag("fr")
                        Text("German").tag("de")
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Picker("Target Language", selection: $defaultTargetLanguage) {
                        Text("Ukrainian").tag("uk")
                        Text("English").tag("en")
                        Text("Russian").tag("ru")
                        Text("Spanish").tag("es")
                        Text("French").tag("fr")
                        Text("German").tag("de")
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Cache Settings")) {
                    Toggle("Enable Smart Cache", isOn: $enableSmartCache)
                    
                    if enableSmartCache {
                        let cacheStats = SmartCacheManager.shared.getCacheStatistics()
                        
                        HStack {
                            Text("Cache Usage")
                            Spacer()
                            Text(String(format: "%.1f MB of %d MB", cacheStats.sizeInMB, maxCacheSize))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Cached Items")
                            Spacer()
                            Text("\(cacheStats.itemCount)")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Cache Size Limit")
                            Spacer()
                            Text("\(maxCacheSize) MB")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: Binding(
                            get: { Double(maxCacheSize) },
                            set: { maxCacheSize = Int($0) }
                        ), in: 10...100, step: 10)
                        
                        Button("Clear Cache") {
                            SmartCacheManager.shared.clearCache()
                        }
                        .foregroundColor(.orange)
                    }
                }
                
                Section(header: Text("History")) {
                    Toggle("Save Translation History", isOn: $enableHistory)
                    
                    if enableHistory {
                        Button("Clear History") {
                            clearHistory()
                        }
                        .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Translation Services")
                        Spacer()
                        Text("Google Translate")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Reset to Defaults") {
                        resetToDefaults()
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveSettings()
                        dismiss()
                    }
                }
            }
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
    }
}

#Preview {
    SettingsView()
}