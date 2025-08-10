import SwiftUI

struct GroqSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var groqService = GroqTranslationService.shared
    @State private var apiKeyInput = ""
    @State private var showingInstructions = false
    
    var body: some View {
        LocalizedView {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.purple)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text("ai_enhanced_translations".localized)
                                .font(.headline)
                                .foregroundColor(AppColors.primaryText)
                            
                            Text("configure_ai_service".localized)
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("ai_service_status".localized) {
                    HStack {
                        Image(systemName: groqService.isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(groqService.isAvailable ? .green : .red)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(groqService.statusMessage)
                                .font(.caption)
                                .foregroundColor(AppColors.primaryText)
                            
                            if groqService.hasApiKeys {
                                Text("API keys configured")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            } else {
                                Text("No API keys configured")
                                    .font(.caption2)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        Spacer()
                        
                        if groqService.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("add_groq_api_key_description".localized)
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                        
                        TextField("paste_groq_api_key".localized, text: $apiKeyInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                        
                        HStack {
                            Button("how_to_get_groq_key".localized) {
                                showingInstructions = true
                            }
                            .font(.caption)
                            .foregroundColor(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme))
                            
                            Spacer()
                            
                            Button("open_groq_console".localized) {
                                if let url = URL(string: "https://console.groq.com/keys") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .font(.caption)
                            .foregroundColor(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme))
                        }
                        
                        Button(action: saveApiKey) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("add_api_key".localized)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(apiKeyInput.isEmpty)
                    }
                }
                
                if groqService.hasApiKeys {
                    Section("manage_ai_settings".localized) {
                        Button("reset_daily_usage".localized) {
                            groqService.resetDailyUsage()
                        }
                        .foregroundColor(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme))
                        
                        Button("remove_all_keys".localized) {
                            UserDefaults.standard.removeObject(forKey: "groq_api_keys")
                            UserDefaults.standard.removeObject(forKey: "groq_api_key")
                            groqService.checkAvailability()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("ai_translation_settings".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                    .foregroundColor(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done".localized) {
                        dismiss()
                    }
                    .foregroundColor(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme))
                }
            }
            .sheet(isPresented: $showingInstructions) {
                InstructionsView()
            }
        }
        }
    }
    
    private func saveApiKey() {
        let trimmedKey = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else { return }
        
        // Get existing keys
        var existingKeys: [String] = []
        if let keysString = UserDefaults.standard.string(forKey: "groq_api_keys") {
            existingKeys = keysString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        } else if let singleKey = UserDefaults.standard.string(forKey: "groq_api_key") {
            existingKeys = [singleKey]
        }
        
        // Add new key if not already present
        if !existingKeys.contains(trimmedKey) {
            existingKeys.append(trimmedKey)
            let keysString = existingKeys.joined(separator: ",")
            UserDefaults.standard.set(keysString, forKey: "groq_api_keys")
        }
        
        // Clear input and update service
        apiKeyInput = ""
        groqService.checkAvailability()
    }
}

struct InstructionsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("how_to_get_groq_key".localized)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("groq_key_instructions".localized)
                        .font(.body)
                        .foregroundColor(AppColors.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Button(action: {
                        if let url = URL(string: "https://console.groq.com") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "safari")
                            Text("open_groq_console".localized)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("instructions".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done".localized) {
                        dismiss()
                    }
                    .foregroundColor(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme))
                }
            }
        }
    }
}