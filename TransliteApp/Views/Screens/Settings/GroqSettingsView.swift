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
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: groqService.isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(groqService.isAvailable ? .green : .red)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                if groqService.hasApiKeys {
                                    Text(LocalizationManager.shared.localizedString(for: "ai_enhanced_active"))
                                        .font(.caption)
                                        .foregroundColor(.green)
                                        .fontWeight(.medium)
                                    Text(LocalizationManager.shared.localizedString(for: "api_keys_configured"))
                                        .font(.caption2)
                                        .foregroundColor(.green)
                                } else {
                                    Text(LocalizationManager.shared.localizedString(for: "ai_enhanced_not_configured"))
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .fontWeight(.medium)
                                    Text(LocalizationManager.shared.localizedString(for: "no_api_keys_configured"))
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
                        
                        // Gradient progress bar for token usage
                        if groqService.hasApiKeys {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(LocalizationManager.shared.localizedString(for: "token_usage"))
                                        .font(.caption2)
                                        .foregroundColor(AppColors.secondaryText)
                                    
                                    Spacer()
                                    
                                    Text("\(String(format: "%.1f", groqService.tokenUsagePercentage))%")
                                        .font(.caption2)
                                        .foregroundColor(groqService.tokenUsagePercentage > 80 ? .red : AppColors.primaryText)
                                        .fontWeight(.medium)
                                }
                                
                                // Custom gradient progress bar
                                ZStack(alignment: .leading) {
                                    // Background
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 6)
                                        .cornerRadius(3)
                                    
                                    // Gradient progress fill
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                colors: groqService.tokenUsagePercentage > 80 ? 
                                                    [.orange, .red] : 
                                                    groqService.tokenUsagePercentage > 50 ?
                                                    [.green, .yellow] :
                                                    [.blue, .green],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: max(0, CGFloat(groqService.tokenUsagePercentage / 100.0) * (UIScreen.main.bounds.width - 80)), height: 6)
                                        .cornerRadius(3)
                                        .animation(.easeInOut(duration: 0.3), value: groqService.tokenUsagePercentage)
                                }
                            }
                        }
                    }
                }
                
                if groqService.hasApiKeys {
                    Section("📊 " + "usage_statistics".localized) {
                        VStack(spacing: 12) {
                            // Requests usage
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("daily_requests_usage".localized)
                                        .font(.caption)
                                        .foregroundColor(AppColors.secondaryText)
                                    Text("\(groqService.dailyRequestsUsed) / 14,400")
                                        .font(.headline)
                                        .foregroundColor(AppColors.primaryText)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(String(format: "%.0f", groqService.requestUsagePercentage))%")
                                        .font(.headline)
                                        .foregroundColor(groqService.requestUsagePercentage > 80 ? .red : .green)
                                    
                                    ProgressView(value: groqService.requestUsagePercentage / 100.0)
                                        .frame(width: 60)
                                        .accentColor(groqService.requestUsagePercentage > 80 ? .red : .green)
                                }
                            }
                            
                            Divider()
                            
                            // Tokens usage
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("daily_tokens_usage".localized)
                                        .font(.caption)
                                        .foregroundColor(AppColors.secondaryText)
                                    Text("\(groqService.dailyTokensUsed) / 25,000")
                                        .font(.headline)
                                        .foregroundColor(AppColors.primaryText)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(String(format: "%.1f", groqService.tokenUsagePercentage))%")
                                        .font(.headline)
                                        .foregroundColor(groqService.tokenUsagePercentage > 80 ? .red : .green)
                                    
                                    ProgressView(value: groqService.tokenUsagePercentage / 100.0)
                                        .frame(width: 60)
                                        .accentColor(groqService.tokenUsagePercentage > 80 ? .red : .green)
                                }
                            }
                            
                            Divider()
                            
                            // Hourly rate
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("hourly_rate_usage".localized)
                                        .font(.caption)
                                        .foregroundColor(AppColors.secondaryText)
                                    Text("\(groqService.currentHourlyRate) / 600")
                                        .font(.headline)
                                        .foregroundColor(AppColors.primaryText)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    let hourlyPercent = Double(groqService.currentHourlyRate) / 600.0 * 100.0
                                    Text("\(String(format: "%.1f", hourlyPercent))%")
                                        .font(.headline)
                                        .foregroundColor(hourlyPercent > 80 ? .red : .green)
                                    
                                    ProgressView(value: hourlyPercent / 100.0)
                                        .frame(width: 60)
                                        .accentColor(hourlyPercent > 80 ? .red : .green)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("add_ai_api_key_description".localized)
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                        
                        TextField("paste_ai_api_key".localized, text: $apiKeyInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                        
                        HStack {
                            Button("how_to_get_ai_key".localized) {
                                showingInstructions = true
                            }
                            .font(.caption)
                            .foregroundColor(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme))
                            
                            Spacer()
                            
                            Button("open_ai_console".localized) {
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
                    Text("how_to_get_ai_key".localized)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("ai_key_instructions".localized)
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
                            Text("open_ai_console".localized)
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