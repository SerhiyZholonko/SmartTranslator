import SwiftUI
import PhotosUI
import Vision
import PDFKit
import UniformTypeIdentifiers

struct FileTranslatorView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = FileTranslatorViewModel()
    @StateObject private var permissionsManager = PermissionsManager.shared
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        LocalizedView {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.appAccent)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("file_translator_title".localized)
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text(TranslationManager.shared.currentServiceName)
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    Spacer()
                    
                    Button(action: { 
                        viewModel.selectedFileURL = nil
                        viewModel.extractedText = ""
                        viewModel.translatedText = ""
                        viewModel.isPDFReady = false
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.appAccent)
                    }
                    .opacity(viewModel.selectedFileURL == nil ? 0 : 1)
                }
                .padding()
                .background(AppColors.cardBackground)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Language selectors
                        HStack(spacing: 12) {
                            FileLanguageSelector(
                                selectedLanguage: $viewModel.sourceLanguage,
                                languages: [
                                    ("auto", "auto_detect".localized),
                                    ("en", "language_english".localized),
                                    ("uk", "language_ukrainian".localized),
                                    ("zh", "language_chinese_simplified".localized),
                                    ("es", "language_spanish".localized),
                                    ("fr", "language_french".localized),
                                    ("de", "language_german".localized)
                                ],
                                title: "from".localized
                            )
                            
                            Button(action: {
                                guard viewModel.sourceLanguage != "auto" else { return }
                                let temp = viewModel.sourceLanguage
                                viewModel.sourceLanguage = viewModel.targetLanguage
                                viewModel.targetLanguage = temp
                            }) {
                                Image(systemName: "arrow.left.arrow.right")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppColors.appAccent)
                            }
                            .disabled(viewModel.sourceLanguage == "auto")
                            
                            FileLanguageSelector(
                                selectedLanguage: $viewModel.targetLanguage,
                                languages: [
                                    ("en", "language_english".localized),
                                    ("uk", "language_ukrainian".localized),
                                    ("zh", "language_chinese_simplified".localized),
                                    ("es", "language_spanish".localized),
                                    ("fr", "language_french".localized),
                                    ("de", "language_german".localized)
                                ],
                                title: "to".localized
                            )
                        }
                        .padding(.horizontal)
                        
                        // File display or picker
                        if let fileURL = viewModel.selectedFileURL {
                            // Show selected file
                            VStack(spacing: 16) {
                                VStack(spacing: 12) {
                                    Image(systemName: "doc.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(AppColors.appAccent)
                                    
                                    Text(viewModel.originalFileName.isEmpty ? fileURL.lastPathComponent : viewModel.originalFileName)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(AppColors.primaryText)
                                    
                                    Text("pdf_document".localized)
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.secondaryText)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .background(AppColors.translationBackground)
                                .cornerRadius(12)
                                
                                if viewModel.isProcessing {
                                    VStack(spacing: 12) {
                                        HStack {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                            Text(getProcessingStageText())
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(AppColors.primaryText)
                                        }
                                        
                                        if viewModel.processingProgress > 0 {
                                            VStack(spacing: 4) {
                                                ProgressView(value: viewModel.processingProgress)
                                                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.appAccent))
                                                    .frame(maxWidth: 250)
                                                
                                                Text("\(Int(viewModel.processingProgress * 100))%")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(AppColors.secondaryText)
                                            }
                                        }
                                        
                                        // Cancel button
                                        if viewModel.canCancel {
                                            Button(action: { viewModel.cancelTranslation() }) {
                                                HStack(spacing: 6) {
                                                    Image(systemName: "xmark.circle.fill")
                                                    Text("cancel".localized)
                                                }
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.red)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(Color.red.opacity(0.1))
                                                .cornerRadius(8)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(AppColors.inputBackground.opacity(0.5))
                                    .cornerRadius(12)
                                }
                                
                                // PDF Download and Load Another File buttons
                                if viewModel.isPDFReady {
                                    VStack(spacing: 12) {
                                        // Download PDF button
                                        Button(action: { viewModel.downloadPDF() }) {
                                            HStack {
                                                Image(systemName: "arrow.down.doc.fill")
                                                Text("download_translated_pdf".localized)
                                            }
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(AppColors.buttonText)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(AppColors.appAccent)
                                            .cornerRadius(12)
                                        }
                                        
                                        // Load Another File button
                                        Button(action: { 
                                            viewModel.resetForNewFile()
                                        }) {
                                            HStack {
                                                Image(systemName: "plus.circle.fill")
                                                Text("load_another_file".localized)
                                            }
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(AppColors.appAccent)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(AppColors.appAccent, lineWidth: 2)
                                            )
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            // File picker options
                            VStack(spacing: 16) {
                                // Upload area
                                VStack(spacing: 20) {
                                    Image(systemName: "doc.text.magnifyingglass")
                                        .font(.system(size: 60))
                                        .foregroundColor(AppColors.appAccent.opacity(0.6))
                                    
                                    Text("select_file_to_translate".localized)
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.secondaryText)
                                    
                                    Text("supported_files_note".localized)
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.tertiaryText)
                                    
                                    HStack(spacing: 20) {
                                        // Photo library button
                                        PhotosPicker(selection: $selectedItem, matching: .images) {
                                            VStack(spacing: 8) {
                                                Image(systemName: "photo.fill")
                                                    .font(.system(size: 30))
                                                    .foregroundColor(AppColors.buttonText)
                                                
                                                Text("gallery".localized)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(AppColors.buttonText)
                                            }
                                            .frame(width: 100, height: 80)
                                            .background(AppColors.appAccent)
                                            .cornerRadius(12)
                                        }
                                        .onChange(of: selectedItem) { newItem in
                                            Task {
                                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                                   let image = UIImage(data: data) {
                                                    // Create a temporary file for the image
                                                    let tempURL = FileManager.default.temporaryDirectory
                                                        .appendingPathComponent("selected_image_\(UUID().uuidString).png")
                                                    
                                                    if let pngData = image.pngData() {
                                                        try? pngData.write(to: tempURL)
                                                        await MainActor.run {
                                                            viewModel.processFile(at: tempURL)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                        // Document picker button
                                        Button(action: { 
                                            viewModel.selectFile()
                                        }) {
                                            VStack(spacing: 8) {
                                                Image(systemName: "doc.fill")
                                                    .font(.system(size: 30))
                                                    .foregroundColor(AppColors.buttonText)
                                                
                                                Text("PDF")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(AppColors.buttonText)
                                            }
                                            .frame(width: 100, height: 80)
                                            .background(AppColors.warningColor)
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                                .padding(40)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(AppColors.inputBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [10]))
                                                .foregroundColor(AppColors.inputBorder)
                                        )
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // Success message - translation completed
                        if !viewModel.translatedText.isEmpty && !viewModel.isProcessing {
                            VStack(spacing: 16) {
                                // Success indicator
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.green)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("translation_complete".localized)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(AppColors.primaryText)
                                        
                                        Text("pdf_ready_for_download".localized)
                                            .font(.system(size: 14))
                                            .foregroundColor(AppColors.secondaryText)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .background(AppColors.appBackground)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $viewModel.showDocumentPicker) {
            DocumentPicker(selectedFile: $viewModel.selectedFileURL) { url in
                viewModel.processFile(at: url)
            }
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            if let pdfURL = viewModel.exportedPDFURL {
                ShareSheet(activityItems: [pdfURL])
            }
        }
        .onAppear {
            viewModel.selectLanguage(UserDefaults.standard.string(forKey: "defaultSourceLanguage") ?? "auto", isSource: true)
            viewModel.selectLanguage(UserDefaults.standard.string(forKey: "defaultTargetLanguage") ?? "en", isSource: false)
        }
        }
    }
    
    // MARK: - Helper Methods
    private func getProcessingStageText() -> String {
        let progress = viewModel.processingProgress
        
        if progress < 0.2 {
            return "reading_file".localized
        } else if progress < 0.6 {
            if !viewModel.pdfPageProgress.isEmpty {
                return viewModel.pdfPageProgress
            }
            return "extracting_text".localized
        } else if progress < 0.9 {
            return "translating_content".localized
        } else {
            return "generating_document".localized
        }
    }
}


// ShareSheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Document Picker
struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedFile: URL?
    let onDocumentPicked: (URL) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf, UTType.image])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            // Start accessing the security-scoped resource
            if url.startAccessingSecurityScopedResource() {
                // Copy the file to a temporary location
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                
                do {
                    // Remove existing file if it exists
                    if FileManager.default.fileExists(atPath: tempURL.path) {
                        try FileManager.default.removeItem(at: tempURL)
                    }
                    
                    // Copy the file
                    try FileManager.default.copyItem(at: url, to: tempURL)
                    
                    parent.onDocumentPicked(tempURL)
                    
                    // Stop accessing the security-scoped resource
                    url.stopAccessingSecurityScopedResource()
                } catch {
                    print("Error copying file: \(error)")
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

private struct FileLanguageSelector: View {
    @Binding var selectedLanguage: String
    let languages: [(String, String)]
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(AppColors.secondaryText)
            
            Menu {
                ForEach(languages, id: \.0) { language in
                    Button("\(getFlag(for: language.0)) \(language.1)") {
                        selectedLanguage = language.0
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(getFlag(for: selectedLanguage))
                    Text(languages.first(where: { $0.0 == selectedLanguage })?.1 ?? "")
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                }
                .foregroundColor(AppColors.primaryText)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(AppColors.inputBackground)
                .cornerRadius(8)
            }
        }
    }
    
    private func getFlag(for languageCode: String) -> String {
        switch languageCode {
        case "en": return "🇬🇧"
        case "uk": return "🇺🇦"
        case "zh": return "🇨🇳"
        case "es": return "🇪🇸"
        case "fr": return "🇫🇷"
        case "de": return "🇩🇪"
        case "auto": return "🌐"
        default: return "🌐"
        }
    }
}

#Preview {
    FileTranslatorView()
}
