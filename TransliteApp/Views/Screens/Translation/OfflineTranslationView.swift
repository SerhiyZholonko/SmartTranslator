import SwiftUI
import Translation

@available(iOS 17.4, *)
struct OfflineTranslationView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var appleTranslationService = AppleTranslationService.shared
    @State private var selectedSourceLanguage = "en"
    @State private var selectedTargetLanguage = "uk"
    @State private var languageStatus: [String: String] = [:]
    @State private var isCheckingStatus = false
    
    let supportedLanguages = [
        ("en", "English"),
        ("uk", "Ukrainian"),
        ("ru", "Russian"),
        ("es", "Spanish"),
        ("fr", "French"),
        ("de", "German"),
        ("it", "Italian"),
        ("pt", "Portuguese"),
        ("zh", "Chinese"),
        ("ja", "Japanese"),
        ("ko", "Korean"),
        ("ar", "Arabic")
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Offline Translation Status")) {
                    HStack {
                        Image(systemName: appleTranslationService.isTranslationAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(appleTranslationService.isTranslationAvailable ? AppColors.successColor : AppColors.errorColor)
                        
                        VStack(alignment: .leading) {
                            Text("Apple Translation")
                                .font(.headline)
                            Text(appleTranslationService.isTranslationAvailable ? "Available" : "Not Available")
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                }
                
                Section(header: Text("Language Pair Status")) {
                    VStack(spacing: 12) {
                        HStack {
                            Text("From:")
                            Picker("Source Language", selection: $selectedSourceLanguage) {
                                ForEach(supportedLanguages, id: \.0) { code, name in
                                    Text(name).tag(code)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        HStack {
                            Text("To:")
                            Picker("Target Language", selection: $selectedTargetLanguage) {
                                ForEach(supportedLanguages, id: \.0) { code, name in
                                    Text(name).tag(code)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        Button(action: checkLanguagePairStatus) {
                            HStack {
                                if isCheckingStatus {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "magnifyingglass")
                                }
                                Text("Check Availability")
                            }
                        }
                        .disabled(isCheckingStatus)
                        
                        if let status = languageStatus[languagePairKey] {
                            LanguageStatusView(status: status)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Supported Languages")) {
                    ForEach(supportedLanguages, id: \.0) { code, name in
                        HStack {
                            Text(name)
                            Spacer()
                            Image(systemName: "globe")
                                .foregroundColor(AppColors.appAccent)
                        }
                    }
                }
                
                Section(header: Text("About Offline Translation")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Works without internet connection")
                        Text("• Faster translation for supported languages")
                        Text("• Privacy-focused - no data sent to servers")
                        Text("• Language packs download automatically when needed")
                        Text("• Available on iOS 17.4 and later")
                    }
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
                }
            }
            .navigationTitle("Offline Translation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                appleTranslationService.checkAvailability()
            }
        }
    }
    
    private var languagePairKey: String {
        "\(selectedSourceLanguage)-\(selectedTargetLanguage)"
    }
    
    private func checkLanguagePairStatus() {
        isCheckingStatus = true
        
        Task {
            let canTranslate = appleTranslationService.canTranslate(from: selectedSourceLanguage, to: selectedTargetLanguage)
            
            await MainActor.run {
                languageStatus[languagePairKey] = canTranslate ? "Available" : "Not Available"
                isCheckingStatus = false
            }
        }
    }
}

struct LanguageStatusView: View {
    let status: String
    
    var body: some View {
        HStack {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(statusTitle)
                    .font(.headline)
                
                Text(statusDescription)
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
        }
        .padding()
        .background(statusColor.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var statusIcon: String {
        switch status {
        case "Available":
            return "checkmark.circle.fill"
        case "Not Available":
            return "xmark.circle.fill"
        default:
            return "questionmark.circle"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case "Available":
            return AppColors.successColor
        case "Not Available":
            return AppColors.errorColor
        default:
            return AppColors.secondaryText
        }
    }
    
    private var statusTitle: String {
        return status
    }
    
    private var statusDescription: String {
        switch status {
        case "Available":
            return "Language pack is installed and ready to use offline"
        case "Not Available":
            return "This language pair is not supported for offline translation"
        default:
            return "Unable to determine language support status"
        }
    }
}

// Fallback view for older iOS versions
struct OfflineTranslationFallbackView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.secondaryText)
                
                Text("Offline Translation Not Available")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Offline translation requires iOS 17.4 or later. Your device is running an older version of iOS.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppColors.secondaryText)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Available options:")
                        .font(.headline)
                    
                    Text("• Google Translate (online)")
                    Text("• Groq AI translation (online)")
                    Text("• Smart caching for offline access to previous translations")
                }
                .foregroundColor(AppColors.secondaryText)
            }
            .padding()
            .navigationTitle("Offline Translation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Wrapper view that shows appropriate content based on iOS version
struct OfflineTranslationWrapper: View {
    var body: some View {
        if #available(iOS 17.4, *) {
            OfflineTranslationView()
        } else {
            OfflineTranslationFallbackView()
        }
    }
}

#Preview {
    OfflineTranslationWrapper()
}