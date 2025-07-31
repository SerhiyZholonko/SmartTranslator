import SwiftUI
import PhotosUI
import Vision
import PDFKit
import UniformTypeIdentifiers

enum FileType {
    case image
    case pdf
}

struct FileTranslatorView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var permissionsManager = PermissionsManager.shared
    @StateObject private var translationManager = TranslationManager.shared
    @State private var selectedImage: UIImage?
    @State private var selectedFile: URL?
    @State private var fileType: FileType = .image
    @State private var detectedText = ""
    @State private var translatedText = ""
    @State private var sourceLanguage = "auto"
    @State private var targetLanguage = "en"
    @State private var isProcessing = false
    @State private var showImagePicker = false
    @State private var showResults = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var showDocumentPicker = false
    
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
                        
                        Text(translationManager.currentServiceName)
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    Spacer()
                    
                    Button(action: resetTranslation) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.appAccent)
                    }
                    .opacity(selectedImage == nil ? 0 : 1)
                }
                .padding()
                .background(AppColors.cardBackground)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Language selectors
                        HStack(spacing: 12) {
                            FileLanguageSelector(
                                selectedLanguage: $sourceLanguage,
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
                            
                            Button(action: swapLanguages) {
                                Image(systemName: "arrow.left.arrow.right")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppColors.appAccent)
                            }
                            .disabled(sourceLanguage == "auto")
                            
                            FileLanguageSelector(
                                selectedLanguage: $targetLanguage,
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
                        if selectedImage != nil || selectedFile != nil {
                            // Show selected file
                            VStack(spacing: 16) {
                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 300)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(AppColors.inputBorder, lineWidth: 1)
                                        )
                                } else if let fileURL = selectedFile {
                                    VStack(spacing: 12) {
                                        Image(systemName: fileType == .pdf ? "doc.fill" : "photo.fill")
                                            .font(.system(size: 60))
                                            .foregroundColor(AppColors.appAccent)
                                        
                                        Text(fileURL.lastPathComponent)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(AppColors.primaryText)
                                        
                                        Text(fileType == .pdf ? "pdf_document".localized : "image_file".localized)
                                            .font(.system(size: 14))
                                            .foregroundColor(AppColors.secondaryText)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .background(AppColors.translationBackground)
                                    .cornerRadius(12)
                                }
                                
                                if isProcessing {
                                    HStack {
                                        ProgressView()
                                        Text("processing_file".localized)
                                            .font(.system(size: 14))
                                            .foregroundColor(AppColors.secondaryText)
                                    }
                                    .padding()
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
                                                    selectedImage = image
                                                    fileType = .image
                                                    processImage()
                                                }
                                            }
                                        }
                                        
                                        // Document picker button
                                        Button(action: { 
                                            showDocumentPicker = true
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
                        
                        // Results section
                        if showResults {
                            VStack(alignment: .leading, spacing: 16) {
                                // Detected text
                                if !detectedText.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("detected_text_title".localized)
                                            .font(.system(size: 14))
                                            .foregroundColor(AppColors.secondaryText)
                                        
                                        Text(detectedText)
                                            .font(.system(size: 16))
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(AppColors.translationBackground)
                                            .cornerRadius(12)
                                    }
                                }
                                
                                // Translated text
                                if !translatedText.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("translation_title".localized)
                                                .font(.system(size: 14))
                                                .foregroundColor(AppColors.secondaryText)
                                            
                                            Spacer()
                                            
                                            Button(action: copyTranslation) {
                                                Image(systemName: "doc.on.doc")
                                                    .foregroundColor(AppColors.appAccent)
                                            }
                                        }
                                        
                                        Text(translatedText)
                                            .font(.system(size: 16))
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(AppColors.translationBackground)
                                            .cornerRadius(12)
                                    }
                                }
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
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(selectedFile: $selectedFile) { url in
                selectedFile = url
                fileType = .pdf
                processPDF()
            }
        }
        .onAppear {
            loadLanguageSettings()
        }
        }
    }
    
    private func processImage() {
        guard let image = selectedImage else { return }
        
        isProcessing = true
        showResults = false
        detectedText = ""
        translatedText = ""
        
        // Perform text recognition
        recognizeText(in: image) { recognizedText in
            guard let text = recognizedText, !text.isEmpty else {
                isProcessing = false
                showResults = true
                detectedText = "no_text_detected_image".localized
                return
            }
            
            detectedText = text
            translateText(text)
        }
    }
    
    private func processPDF() {
        guard let fileURL = selectedFile else { return }
        
        isProcessing = true
        showResults = false
        detectedText = ""
        translatedText = ""
        
        // Extract text from PDF
        extractTextFromPDF(at: fileURL) { extractedText in
            guard let text = extractedText, !text.isEmpty else {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.showResults = true
                    self.detectedText = "no_text_found_pdf".localized
                }
                return
            }
            
            DispatchQueue.main.async {
                self.detectedText = text
                self.translateText(text)
            }
        }
    }
    
    private func translateText(_ text: String) {
        // Translate the text
        Task {
            do {
                let translated = try await translationManager.translate(
                    text: text,
                    from: sourceLanguage,
                    to: targetLanguage
                )
                
                await MainActor.run {
                    translatedText = translated
                    showResults = true
                    isProcessing = false
                    
                    // Save to history
                    let historyItem = TranslationHistoryItem(
                        sourceText: text,
                        translatedText: translated,
                        sourceLanguage: sourceLanguage,
                        targetLanguage: targetLanguage
                    )
                    TranslationHistoryManager.shared.addTranslation(historyItem)
                }
            } catch {
                await MainActor.run {
                    translatedText = "translation_error_prefix".localized(with: error.localizedDescription)
                    showResults = true
                    isProcessing = false
                }
            }
        }
    }
    
    private func recognizeText(in image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                completion(nil)
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            let fullText = recognizedStrings.joined(separator: "\n")
            completion(fullText)
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en", "uk", "zh", "es", "fr", "de"]
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Text recognition error: \(error)")
                completion(nil)
            }
        }
    }
    
    private func resetTranslation() {
        selectedImage = nil
        selectedFile = nil
        detectedText = ""
        translatedText = ""
        showResults = false
    }
    
    private func extractTextFromPDF(at url: URL, completion: @escaping (String?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let document = PDFDocument(url: url) else {
                completion(nil)
                return
            }
            
            var extractedText = ""
            
            for pageIndex in 0..<document.pageCount {
                if let page = document.page(at: pageIndex) {
                    if let pageText = page.string {
                        extractedText += pageText + "\n"
                    }
                }
            }
            
            completion(extractedText.isEmpty ? nil : extractedText.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
    
    private func copyTranslation() {
        UIPasteboard.general.string = translatedText
    }
    
    private func swapLanguages() {
        guard sourceLanguage != "auto" else { return }
        let temp = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = temp
        
        // Якщо є переведений текст, поміняти його місцями з оригінальним
        if !translatedText.isEmpty && !detectedText.isEmpty {
            let tempText = detectedText
            detectedText = translatedText
            translatedText = tempText
        }
    }
    
    private func loadLanguageSettings() {
        let preferences = UserDefaults.standard
        
        // Завантажуємо збережені налаштування мов з Settings
        if let savedSourceLanguage = preferences.string(forKey: "defaultSourceLanguage") {
            sourceLanguage = savedSourceLanguage
        }
        
        if let savedTargetLanguage = preferences.string(forKey: "defaultTargetLanguage") {
            targetLanguage = savedTargetLanguage
        }
    }
}

// Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
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
