import SwiftUI
import UniformTypeIdentifiers
import PDFKit
import Vision

@MainActor
final class FileTranslatorViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var selectedFileURL: URL?
    @Published var extractedText = ""
    @Published var translatedText = ""
    @Published var sourceLanguage = "auto"
    @Published var targetLanguage = "en"
    @Published var isProcessing = false
    @Published var showDocumentPicker = false
    @Published var showLanguagePicker = false
    @Published var isSelectingSourceLanguage = true
    @Published var processingProgress: Double = 0
    
    // MARK: - Services
    private let translationManager = TranslationManager.shared
    
    // MARK: - Properties
    let supportedTypes: [UTType] = [.pdf, .text, .plainText, .rtf, .html]
    
    // MARK: - Public Methods
    func selectFile() {
        showDocumentPicker = true
    }
    
    func processFile(at url: URL) {
        selectedFileURL = url
        clearError()
        
        Task {
            isProcessing = true
            processingProgress = 0.1
            
            do {
                // Start accessing security-scoped resource
                guard url.startAccessingSecurityScopedResource() else {
                    throw NSError(domain: "FileTranslator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot access file"])
                }
                
                defer {
                    url.stopAccessingSecurityScopedResource()
                }
                
                // Extract text based on file type
                let text = try await extractText(from: url)
                extractedText = text
                processingProgress = 0.5
                
                // Translate extracted text
                if !text.isEmpty {
                    await translateText()
                } else {
                    showError("no_text_extracted".localized)
                }
                
            } catch {
                handleError(error)
            }
            
            isProcessing = false
            processingProgress = 1.0
        }
    }
    
    func translate() {
        guard !extractedText.isEmpty else {
            showError("no_text_to_translate".localized)
            return
        }
        
        Task {
            await translateText()
        }
    }
    
    func selectLanguage(_ language: String, isSource: Bool) {
        if isSource {
            sourceLanguage = language
        } else {
            targetLanguage = language
        }
        
        // Re-translate if we have text
        if !extractedText.isEmpty && !translatedText.isEmpty {
            translate()
        }
    }
    
    func copyTranslation() {
        UIPasteboard.general.string = translatedText
        showError("copied_to_clipboard".localized)
    }
    
    func shareTranslation() {
        // This will be handled by the view
    }
    
    func exportTranslation() {
        // TODO: Implement export functionality
        showError("export_coming_soon".localized)
    }
    
    // MARK: - Private Methods
    private func extractText(from url: URL) async throws -> String {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            return try extractTextFromPDF(url)
        case "txt", "text":
            return try String(contentsOf: url, encoding: .utf8)
        case "rtf", "rtfd":
            return try extractTextFromRTF(url)
        case "html", "htm":
            return try extractTextFromHTML(url)
        default:
            // Try to read as plain text
            return try String(contentsOf: url, encoding: .utf8)
        }
    }
    
    private func extractTextFromPDF(_ url: URL) throws -> String {
        guard let pdfDocument = PDFDocument(url: url) else {
            throw NSError(domain: "FileTranslator", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot open PDF file"])
        }
        
        var extractedText = ""
        let pageCount = pdfDocument.pageCount
        
        for pageIndex in 0..<pageCount {
            autoreleasepool {
                if let page = pdfDocument.page(at: pageIndex),
                   let pageContent = page.string {
                    extractedText += pageContent + "\n\n"
                }
                
                // Update progress
                let progress = 0.1 + (0.4 * Double(pageIndex + 1) / Double(pageCount))
                Task { @MainActor in
                    self.processingProgress = progress
                }
            }
        }
        
        return extractedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func extractTextFromRTF(_ url: URL) throws -> String {
        let data = try Data(contentsOf: url)
        
        if let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.rtf],
            documentAttributes: nil
        ) {
            return attributedString.string
        }
        
        throw NSError(domain: "FileTranslator", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot parse RTF file"])
    }
    
    private func extractTextFromHTML(_ url: URL) throws -> String {
        let data = try Data(contentsOf: url)
        
        if let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        ) {
            return attributedString.string
        }
        
        // Fallback to raw HTML
        return try String(contentsOf: url, encoding: .utf8)
    }
    
    private func translateText() async {
        isProcessing = true
        clearError()
        processingProgress = 0.6
        
        do {
            // Split text into chunks if needed
            let chunks = splitTextIntoChunks(extractedText, maxLength: 4500)
            var translatedChunks: [String] = []
            
            for (index, chunk) in chunks.enumerated() {
                let result = try await translationManager.translate(
                    text: chunk,
                    from: sourceLanguage,
                    to: targetLanguage
                )
                translatedChunks.append(result)
                
                // Update progress
                let progress = 0.6 + (0.4 * Double(index + 1) / Double(chunks.count))
                processingProgress = progress
            }
            
            translatedText = translatedChunks.joined(separator: "\n\n")
            
        } catch {
            handleError(error)
        }
        
        isProcessing = false
        processingProgress = 1.0
    }
    
    private func splitTextIntoChunks(_ text: String, maxLength: Int) -> [String] {
        guard text.count > maxLength else { return [text] }
        
        var chunks: [String] = []
        var currentChunk = ""
        
        // Split by sentences
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        
        for sentence in sentences {
            let trimmedSentence = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedSentence.isEmpty else { continue }
            
            let fullSentence = trimmedSentence + "."
            
            if currentChunk.count + fullSentence.count > maxLength {
                if !currentChunk.isEmpty {
                    chunks.append(currentChunk)
                }
                currentChunk = fullSentence
            } else {
                currentChunk += " " + fullSentence
            }
        }
        
        if !currentChunk.isEmpty {
            chunks.append(currentChunk)
        }
        
        return chunks
    }
}