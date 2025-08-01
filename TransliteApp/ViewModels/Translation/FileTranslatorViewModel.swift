import SwiftUI
import UniformTypeIdentifiers
import PDFKit
import Vision
import UIKit

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
    @Published var pdfPageProgress: String = ""
    @Published var isExporting = false
    @Published var showShareSheet = false
    @Published var exportedPDFURL: URL?
    @Published var isPDFReady = false
    @Published var originalFileName = ""
    @Published var canCancel = false
    
    // MARK: - Services
    private let translationManager = TranslationManager.shared
    
    // MARK: - Properties
    let supportedTypes: [UTType] = [.pdf, .text, .plainText, .rtf, .html, .image, .jpeg, .png]
    private let maxPDFSize: Int = 50 * 1024 * 1024 // 50MB limit
    private let chunkSize = 2000 // Smaller chunks for better translation and reduced memory usage
    private var cancellationToken: Task<Void, Never>?
    
    // MARK: - Public Methods
    func selectFile() {
        showDocumentPicker = true
    }
    
    func processFile(at url: URL) {
        selectedFileURL = url
        originalFileName = url.lastPathComponent
        clearError()
        isPDFReady = false
        
        // Cancel any existing task
        cancellationToken?.cancel()
        
        cancellationToken = Task {
            await MainActor.run {
                isProcessing = true
                canCancel = true
                processingProgress = 0.1
            }
            
            print("Starting file processing task")
            
            do {
                // Check for cancellation
                try Task.checkCancellation()
                
                // Check if this is a temporary file (already copied from DocumentPicker)
                let isTempFile = url.path.contains(NSTemporaryDirectory())
                
                // Only need security-scoped access for non-temporary files
                if !isTempFile {
                    guard url.startAccessingSecurityScopedResource() else {
                        throw NSError(domain: "FileTranslator", code: 1, userInfo: [NSLocalizedDescriptionKey: "error_invalid_file_format".localized])
                    }
                }
                
                defer {
                    if !isTempFile {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                
                // Extract text based on file type
                print("Starting text extraction from: \(url.lastPathComponent)")
                let text = try await extractText(from: url)
                print("Extracted \(text.count) characters from file")
                
                // Check for cancellation after extraction
                try Task.checkCancellation()
                
                await MainActor.run {
                    extractedText = text
                    processingProgress = 0.5
                }
                
                // Translate extracted text
                if !text.isEmpty {
                    try await translateText()
                } else {
                    await MainActor.run {
                        showError("no_text_extracted".localized)
                    }
                }
                
            } catch is CancellationError {
                // Handle cancellation gracefully
                print("Translation was cancelled by user")
                await MainActor.run {
                    isProcessing = false
                    canCancel = false
                    processingProgress = 0
                    showError("translation_cancelled".localized)
                }
                return // Early return for cancellation
            } catch {
                print("Translation error: \(error)")
                await MainActor.run {
                    isProcessing = false
                    canCancel = false
                    handleError(error)
                }
                return // Early return for errors
            }
            
            await MainActor.run {
                isProcessing = false
                canCancel = false
                processingProgress = 1.0
            }
        }
    }
    
    func translate() {
        guard !extractedText.isEmpty else {
            showError("no_text_to_translate".localized)
            return
        }
        
        Task {
            do {
                try await translateText()
            } catch {
                handleError(error)
            }
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
        guard !translatedText.isEmpty else {
            showError("no_translation_to_export".localized)
            return
        }
        
        Task {
            await exportToPDF()
        }
    }
    
    func downloadPDF() {
        guard let pdfURL = exportedPDFURL else { return }
        
        // Verify file exists before attempting to share
        guard FileManager.default.fileExists(atPath: pdfURL.path) else {
            showError("pdf_file_not_found".localized)
            return
        }
        
        // Re-generate PDF if needed
        if !FileManager.default.isReadableFile(atPath: pdfURL.path) {
            Task {
                do {
                    try await generateTranslatedPDF()
                    await MainActor.run {
                        if exportedPDFURL != nil {
                            showShareSheet = true
                        }
                    }
                } catch {
                    await MainActor.run {
                        showError("Error regenerating PDF: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            showShareSheet = true
        }
    }
    
    func cancelTranslation() {
        guard isProcessing else { return }
        
        print("User requested cancellation")
        cancellationToken?.cancel()
        cancellationToken = nil
        
        isProcessing = false
        canCancel = false
        processingProgress = 0
        pdfPageProgress = ""
        
        showError("translation_cancelled".localized)
    }
    
    // MARK: - Private Methods
    private func extractText(from url: URL) async throws -> String {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            return try await extractTextFromPDF(url)
        case "txt", "text":
            return try String(contentsOf: url, encoding: .utf8)
        case "rtf", "rtfd":
            return try extractTextFromRTF(url)
        case "html", "htm":
            return try extractTextFromHTML(url)
        case "png", "jpg", "jpeg", "gif", "bmp", "tiff", "heic":
            return try await extractTextFromImage(url)
        default:
            // Try to read as plain text
            return try String(contentsOf: url, encoding: .utf8)
        }
    }
    
    private func extractTextFromPDF(_ url: URL) async throws -> String {
        // Check if file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw NSError(domain: "FileTranslator", code: 11, userInfo: [NSLocalizedDescriptionKey: "File not found"])
        }
        
        // Check file size
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
        let fileSize = fileAttributes[.size] as? Int ?? 0
        
        if fileSize > maxPDFSize {
            throw NSError(domain: "FileTranslator", code: 10, userInfo: [NSLocalizedDescriptionKey: "pdf_too_large".localized])
        }
        
        guard let pdfDocument = PDFDocument(url: url) else {
            throw NSError(domain: "FileTranslator", code: 2, userInfo: [NSLocalizedDescriptionKey: "error_invalid_file_format".localized])
        }
        
        var extractedText = ""
        let pageCount = pdfDocument.pageCount
        
        // Handle large PDFs with smaller batches and yield control
        let batchSize = 5 // Process 5 pages at a time to reduce memory pressure
        
        for startIndex in stride(from: 0, to: pageCount, by: batchSize) {
            await Task.yield() // Allow UI updates and prevent blocking
            
            let endIndex = min(startIndex + batchSize, pageCount)
            
            for pageIndex in startIndex..<endIndex {
                autoreleasepool {
                    if let page = pdfDocument.page(at: pageIndex) {
                        extractedText += "\n<PAGE>\(pageIndex + 1)</PAGE>\n"
                        
                        // Extract structured content with formatting information
                        let pageContent = extractStructuredContentFromPage(page)
                        extractedText += pageContent + "\n"
                    }
                }
                
                // Yield control every page to prevent blocking
                await Task.yield()
            }
            
            // Update progress on main thread
            await MainActor.run {
                let progress = 0.1 + (0.4 * Double(endIndex) / Double(pageCount))
                self.processingProgress = progress
                self.pdfPageProgress = "processing_pages_format".localized(with: endIndex, pageCount)
            }
        }
        
        return extractedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func extractStructuredContentFromPage(_ page: PDFPage) -> String {
        guard let pageContent = page.string else { return "" }
        
        var structuredContent = ""
        let lines = pageContent.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            // Preserve exact line content including whitespace
            let originalLine = line
            
            // For empty lines, preserve as breaks
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                structuredContent += "<BREAK/>\n"
                continue
            }
            
            // Calculate exact indentation
            let leadingSpaces = originalLine.prefix(while: { $0 == " " }).count
            let leadingTabs = originalLine.prefix(while: { $0 == "\t" }).count
            let effectiveIndent = leadingSpaces + (leadingTabs * 4) // Convert tabs to spaces
            
            // Check context for better classification
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            let previousLineEmpty = index > 0 ? lines[index - 1].trimmingCharacters(in: .whitespaces).isEmpty : true
            let nextLineEmpty = index < lines.count - 1 ? lines[index + 1].trimmingCharacters(in: .whitespaces).isEmpty : true
            
            // Detect special formatting
            if isLikelyTitle(trimmedLine, previousEmpty: previousLineEmpty, nextEmpty: nextLineEmpty) {
                structuredContent += "<TITLE>" + trimmedLine + "</TITLE>\n"
            } else if isLikelyHeading(trimmedLine, previousEmpty: previousLineEmpty, effectiveIndent: effectiveIndent) {
                let level = detectHeadingLevel(trimmedLine)
                structuredContent += "<H\(level)>" + trimmedLine + "</H\(level)>\n"
            } else if effectiveIndent >= 4 {
                // Preserve indented content (lists, quotes, etc)
                structuredContent += "<INDENT:\(effectiveIndent)>" + trimmedLine + "</INDENT>\n"
            } else {
                // Regular line - preserve as-is
                structuredContent += "<LINE>" + trimmedLine + "</LINE>\n"
            }
        }
        
        return structuredContent
    }
    
    private func isLikelyTitle(_ text: String, previousEmpty: Bool, nextEmpty: Bool) -> Bool {
        // Title detection - usually centered, all caps, or very prominent
        if text.count > 100 { return false }
        
        // Check if all uppercase
        if text == text.uppercased() && text.count > 5 && previousEmpty && nextEmpty {
            return true
        }
        
        // Check for specific title patterns
        let titlePatterns = [
            "APPLE DEVELOPER PROGRAM LICENSE AGREEMENT",
            "LICENSE AGREEMENT",
            "TERMS AND CONDITIONS",
            "AGREEMENT"
        ]
        
        let upperText = text.uppercased()
        for pattern in titlePatterns {
            if upperText.contains(pattern) {
                return true
            }
        }
        
        return false
    }
    
    private func isLikelyHeading(_ text: String, previousEmpty: Bool, effectiveIndent: Int) -> Bool {
        // More conservative heading detection
        if text.count > 150 { return false }
        
        // Numbered sections are likely headings
        if text.range(of: "^\\d+\\.\\d*\\s+[A-Z]", options: .regularExpression) != nil {
            return true
        }
        
        // Article/Section patterns
        if text.range(of: "^(Article|Section|ARTICLE|SECTION)\\s+\\d+", options: .regularExpression) != nil {
            return true
        }
        
        // Short lines after empty lines with minimal indent
        if previousEmpty && text.count < 80 && effectiveIndent < 4 {
            // Check if it's not a regular sentence
            if !text.hasSuffix(".") || text.contains(":") {
                return true
            }
        }
        
        return false
    }
    
    private func detectPreciseHeading(_ text: String, previousEmpty: Bool, nextEmpty: Bool, indent: Int) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        
        // More conservative heading detection
        if trimmed.count > 150 { return false } // Too long
        if trimmed.hasSuffix(".") && !trimmed.contains(":") { return false } // Ends with period
        if trimmed.count < 3 { return false } // Too short
        
        // Strong indicators
        let strongKeywords = ["chapter", "section", "article", "part", "appendix", "introduction", "conclusion", "summary", "abstract", "overview", "background", "methodology", "results", "discussion", "references", "bibliography", "index", "glossary", "acknowledgments", "preface", "foreword", "contents", "table of contents", "list of figures", "list of tables"]
        
        let lowerText = trimmed.lowercased()
        for keyword in strongKeywords {
            if lowerText.contains(keyword) {
                return true
            }
        }
        
        // Check for numbered sections
        if trimmed.range(of: "^\\d+[\\.\\)]\\s*[A-Z]", options: .regularExpression) != nil {
            return true
        }
        
        // Check formatting indicators (but be more conservative)
        if previousEmpty && nextEmpty && trimmed.count < 80 {
            let uppercaseRatio = Double(trimmed.filter { $0.isUppercase }.count) / Double(trimmed.filter { $0.isLetter }.count)
            if uppercaseRatio > 0.4 { // Higher threshold
                return true
            }
        }
        
        // Special case: isolated short lines with specific indentation
        if previousEmpty && trimmed.count < 50 && indent < 10 {
            let hasCapitalStart = trimmed.first?.isUppercase == true
            let hasMinimalPunctuation = trimmed.filter { ".,;:!?".contains($0) }.count <= 1
            return hasCapitalStart && hasMinimalPunctuation
        }
        
        return false
    }
    
    
    private func detectHeadingLevel(_ text: String) -> Int {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        
        // Level 1: Very short, all caps, or contains "chapter"
        if trimmed.count < 30 && (trimmed.uppercased() == trimmed || trimmed.lowercased().contains("chapter") || trimmed.lowercased().contains("глава")) {
            return 1
        }
        
        // Level 2: Medium length with numbers or keywords
        if trimmed.count < 60 && (trimmed.range(of: "^\\d+", options: .regularExpression) != nil || trimmed.lowercased().contains("section")) {
            return 2
        }
        
        // Default to level 3
        return 3
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
    
    private func extractTextFromImage(_ url: URL) async throws -> String {
        guard let image = UIImage(contentsOfFile: url.path) else {
            throw NSError(domain: "FileTranslator", code: 4, userInfo: [NSLocalizedDescriptionKey: "Cannot load image"])
        }
        
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "FileTranslator", code: 5, userInfo: [NSLocalizedDescriptionKey: "Cannot process image"])
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }
                
                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                let fullText = recognizedStrings.joined(separator: "\n")
                continuation.resume(returning: fullText)
            }
            
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en", "uk", "zh", "es", "fr", "de"]
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    
    private func translateText() async throws {
        await MainActor.run {
            clearError()
            processingProgress = 0.6
        }
        
        // Check for cancellation
        try Task.checkCancellation()
        
        // Store original text with structure for PDF generation
        let originalStructuredText = extractedText
        
        // Split content into chunks if needed (this will clean the text)
        let chunks = splitTextIntoChunks(extractedText, maxLength: chunkSize)
        var translatedChunks: [String] = []
        
        print("Starting translation of \(chunks.count) chunks")
        
        for (index, chunk) in chunks.enumerated() {
            // Check for cancellation before each chunk
            try Task.checkCancellation()
            
            // Yield control between chunks to prevent UI blocking
            await Task.yield()
            
            print("Translating chunk \(index + 1)/\(chunks.count)")
            
            do {
                let result = try await translationManager.translate(
                    text: chunk,
                    from: sourceLanguage,
                    to: targetLanguage
                )
                
                translatedChunks.append(result)
                print("Successfully translated chunk \(index + 1)")
                
                // Update progress on main thread
                await MainActor.run {
                    let progress = 0.6 + (0.3 * Double(index + 1) / Double(chunks.count))
                    self.processingProgress = progress
                }
                
                // Add a small delay between translations to prevent overwhelming the API
                try await Task.sleep(for: .milliseconds(300)) // Increased delay
                
            } catch {
                print("Error translating chunk \(index + 1): \(error)")
                // Don't fail entire process for single chunk - add original text as fallback
                translatedChunks.append(chunk)
                
                // Update progress anyway
                await MainActor.run {
                    let progress = 0.6 + (0.3 * Double(index + 1) / Double(chunks.count))
                    self.processingProgress = progress
                }
            }
        }
        
        // Check for cancellation before final steps
        try Task.checkCancellation()
        
        // Join translated chunks as clean text for display
        let cleanTranslation = translatedChunks.joined(separator: "\n\n")
        
        // For PDF generation, we need to restore structure from original but with translated content
        let structuredTranslation = restoreStructureToTranslation(
            originalStructured: originalStructuredText,
            cleanTranslation: cleanTranslation
        )
        
        await MainActor.run {
            // Store clean translation for UI display
            translatedText = cleanTranslation
            processingProgress = 0.95
        }
        
        // Save to history with clean text
        let historyItem = TranslationHistoryItem(
            sourceText: cleanTextForTranslation(extractedText), // Clean version for history
            translatedText: cleanTranslation,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage
        )
        TranslationHistoryManager.shared.addTranslation(historyItem)
        
        // Auto-generate PDF if this is a PDF file
        if originalFileName.lowercased().hasSuffix(".pdf") {
            print("Starting PDF generation")
            do {
                // For PDF generation, use the clean translated text directly
                // The PDF will handle formatting based on content, not structural tags
                try await generateTranslatedPDF()
                
                print("PDF generation completed successfully")
            } catch {
                print("PDF generation failed: \(error)")
                await MainActor.run {
                    showError("Error generating PDF: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func restoreStructureToTranslation(originalStructured: String, cleanTranslation: String) -> String {
        // Extract all content from original structure to create mapping
        let originalContent = extractContentFromStructure(originalStructured)
        
        // Create a simple approach: replace original content chunks with translated chunks
        // by preserving the structure but substituting content
        var result = originalStructured
        
        // Split clean translation into paragraphs/sentences
        let translatedParagraphs = cleanTranslation.components(separatedBy: "\n\n")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        var translationIndex = 0
        
        // Replace content within each structured element
        let lines = originalStructured.components(separatedBy: .newlines)
        var rebuiltResult = ""
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Keep structural elements unchanged
            if trimmed.hasPrefix("<PAGE>") || trimmed.hasPrefix("<BREAK") || trimmed.isEmpty {
                rebuiltResult += line + "\n"
                continue
            }
            
            // For content elements, extract and replace the content
            if let contentMatch = extractContentFromLine(trimmed) {
                let (tagStart, originalContent, tagEnd) = contentMatch
                
                // Only replace if we have translation available and original content is substantial
                if translationIndex < translatedParagraphs.count && 
                   originalContent.count > 10 { // Only replace substantial content
                    
                    let translatedContent = translatedParagraphs[translationIndex]
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if !translatedContent.isEmpty {
                        rebuiltResult += tagStart + translatedContent + tagEnd + "\n"
                        translationIndex += 1
                    } else {
                        rebuiltResult += line + "\n"
                    }
                } else {
                    rebuiltResult += line + "\n"
                }
            } else {
                // Non-tagged content - replace directly if substantial
                if translationIndex < translatedParagraphs.count && 
                   trimmed.count > 10 {
                    
                    let translatedContent = translatedParagraphs[translationIndex]
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if !translatedContent.isEmpty {
                        rebuiltResult += translatedContent + "\n"
                        translationIndex += 1
                    } else {
                        rebuiltResult += line + "\n"
                    }
                } else {
                    rebuiltResult += line + "\n"
                }
            }
        }
        
        return rebuiltResult
    }
    
    private func extractContentFromStructure(_ structuredText: String) -> [String] {
        let cleanedText = cleanTextForTranslation(structuredText)
        return cleanedText.components(separatedBy: "\n\n")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
    
    private func extractContentFromLine(_ line: String) -> (String, String, String)? {
        // Match patterns like <TAG>content</TAG>
        let patterns = [
            "(<TITLE>)(.*?)(</TITLE>)",
            "(<H[1-6]>)(.*?)(</H[1-6]>)",
            "(<LINE>)(.*?)(</LINE>)",
            "(<INDENT:\\d+>)(.*?)(</INDENT>)",
            "(<P>)(.*?)(</P>)"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
                let range = NSRange(location: 0, length: line.count)
                if let match = regex.firstMatch(in: line, options: [], range: range) {
                    let tagStartRange = match.range(at: 1)
                    let contentRange = match.range(at: 2)
                    let tagEndRange = match.range(at: 3)
                    
                    if tagStartRange.location != NSNotFound && 
                       contentRange.location != NSNotFound && 
                       tagEndRange.location != NSNotFound {
                        
                        let tagStart = String(line[Range(tagStartRange, in: line)!])
                        let content = String(line[Range(contentRange, in: line)!])
                        let tagEnd = String(line[Range(tagEndRange, in: line)!])
                        
                        return (tagStart, content, tagEnd)
                    }
                }
            }
        }
        
        return nil
    }
    
    private func splitTextIntoChunks(_ text: String, maxLength: Int) -> [String] {
        guard text.count > maxLength else { 
            // Clean single chunk of structural tags before translation
            return [cleanTextForTranslation(text)]
        }
        
        var chunks: [String] = []
        var currentChunk = ""
        
        // Split by structured elements to preserve formatting
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            let isStructuralElement = line.hasPrefix("<") && line.hasSuffix(">")
            let fullLine = line + "\n"
            
            // If adding this line would exceed the limit
            if currentChunk.count + fullLine.count > maxLength {
                // Save current chunk if it's not empty
                if !currentChunk.isEmpty {
                    // Clean structural tags from chunk before translation
                    let cleanedChunk = cleanTextForTranslation(currentChunk.trimmingCharacters(in: .whitespacesAndNewlines))
                    if !cleanedChunk.isEmpty {
                        chunks.append(cleanedChunk)
                    }
                    currentChunk = ""
                }
                
                // If a single line is too long, we need to split it
                if fullLine.count > maxLength && !isStructuralElement {
                    let splitLine = splitLongLine(line, maxLength: maxLength)
                    let cleanedSplitLines = splitLine.map { cleanTextForTranslation($0) }.filter { !$0.isEmpty }
                    chunks.append(contentsOf: cleanedSplitLines)
                } else {
                    currentChunk = fullLine
                }
            } else {
                currentChunk += fullLine
            }
        }
        
        // Add the final chunk
        if !currentChunk.isEmpty {
            let cleanedChunk = cleanTextForTranslation(currentChunk.trimmingCharacters(in: .whitespacesAndNewlines))
            if !cleanedChunk.isEmpty {
                chunks.append(cleanedChunk)
            }
        }
        
        return chunks.filter { !$0.isEmpty }
    }
    
    private func cleanTextForTranslation(_ text: String) -> String {
        var cleanedText = text
        
        // Remove all structural tags but preserve content
        let tagPatterns = [
            "<PAGE>.*?</PAGE>",
            "<TITLE>(.*?)</TITLE>",
            "<H[1-6]>(.*?)</H[1-6]>",
            "<LINE>(.*?)</LINE>",
            "<INDENT:\\d+>(.*?)</INDENT>",
            "<BREAK/?>",
            "<P>(.*?)</P>"
        ]
        
        for pattern in tagPatterns {
            let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators])
            let range = NSRange(location: 0, length: cleanedText.count)
            
            // For patterns with capture groups, replace with captured content
            if pattern.contains("(.*?)") {
                cleanedText = regex?.stringByReplacingMatches(
                    in: cleanedText,
                    options: [],
                    range: range,
                    withTemplate: "$1"
                ) ?? cleanedText
            } else {
                // For patterns without capture groups, remove entirely
                cleanedText = regex?.stringByReplacingMatches(
                    in: cleanedText,
                    options: [],
                    range: range,
                    withTemplate: ""
                ) ?? cleanedText
            }
        }
        
        // Clean up multiple newlines and excessive whitespace
        cleanedText = cleanedText
            .replacingOccurrences(of: "\n\n\n+", with: "\n\n", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleanedText
    }
    
    private func splitLongLine(_ line: String, maxLength: Int) -> [String] {
        guard line.count > maxLength else { return [line] }
        
        var chunks: [String] = []
        var currentChunk = ""
        
        // Split by sentences first
        let sentences = line.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        
        for (index, sentence) in sentences.enumerated() {
            let isLast = index == sentences.count - 1
            let fullSentence = sentence + (isLast ? "" : ".")
            
            if currentChunk.count + fullSentence.count > maxLength {
                if !currentChunk.isEmpty {
                    chunks.append(currentChunk.trimmingCharacters(in: .whitespaces))
                    currentChunk = ""
                }
                
                // If sentence is still too long, split by words
                if fullSentence.count > maxLength {
                    let words = fullSentence.components(separatedBy: .whitespaces)
                    for word in words {
                        if currentChunk.count + word.count + 1 > maxLength {
                            if !currentChunk.isEmpty {
                                chunks.append(currentChunk.trimmingCharacters(in: .whitespaces))
                            }
                            currentChunk = word
                        } else {
                            currentChunk += currentChunk.isEmpty ? word : " " + word
                        }
                    }
                } else {
                    currentChunk = fullSentence
                }
            } else {
                currentChunk += currentChunk.isEmpty ? fullSentence : " " + fullSentence
            }
        }
        
        if !currentChunk.isEmpty {
            chunks.append(currentChunk.trimmingCharacters(in: .whitespaces))
        }
        
        return chunks.filter { !$0.isEmpty }
    }
    
    
    // MARK: - PDF Export
    @MainActor
    private func generateTranslatedPDF() async throws {
        guard !translatedText.isEmpty else { 
            throw NSError(domain: "FileTranslator", code: 100, userInfo: [NSLocalizedDescriptionKey: "No translated text available"])
        }
        
        print("Creating PDF with \(translatedText.count) characters")
        
        // Create PDF content
        let pdfData = createPDF()
        
        guard pdfData.count > 0 else {
            throw NSError(domain: "FileTranslator", code: 101, userInfo: [NSLocalizedDescriptionKey: "Failed to create PDF data"])
        }
        
        // Save to temporary directory for better sharing compatibility
        let tempPath = FileManager.default.temporaryDirectory
        let baseFileName = originalFileName.replacingOccurrences(of: ".pdf", with: "")
        let translatedFileName = "\(baseFileName)_translated_\(sourceLanguage)_to_\(targetLanguage).pdf"
        let finalURL = tempPath.appendingPathComponent(translatedFileName)
        
        print("Saving PDF to: \(finalURL.path)")
        
        // Remove existing file if it exists
        if FileManager.default.fileExists(atPath: finalURL.path) {
            try FileManager.default.removeItem(at: finalURL)
        }
        
        try pdfData.write(to: finalURL)
        
        // Verify file was written
        guard FileManager.default.fileExists(atPath: finalURL.path) else {
            throw NSError(domain: "FileTranslator", code: 102, userInfo: [NSLocalizedDescriptionKey: "Failed to write PDF file"])
        }
        
        // Set file attributes to ensure it's readable
        try FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: finalURL.path)
        
        exportedPDFURL = finalURL
        isPDFReady = true
        
        print("PDF successfully generated and saved")
    }
    
    @MainActor
    private func exportToPDF() async {
        isExporting = true
        clearError()
        
        do {
            // Create PDF content
            let pdfData = createPDF()
            
            // Save to temporary file
            let fileName = "translation_\(Date().timeIntervalSince1970).pdf"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            // Remove existing file if it exists
            if FileManager.default.fileExists(atPath: tempURL.path) {
                try FileManager.default.removeItem(at: tempURL)
            }
            
            try pdfData.write(to: tempURL)
            
            // Set file attributes to ensure it's readable
            try FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: tempURL.path)
            
            exportedPDFURL = tempURL
            showShareSheet = true
            
        } catch {
            showError(error.localizedDescription)
        }
        
        isExporting = false
    }
    
    private func createPDF() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Smart Translator",
            kCGPDFContextAuthor: "Smart Translator App",
            kCGPDFContextTitle: "Translation Export"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // A4 size
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            let margin: CGFloat = 40
            var yPosition: CGFloat = margin
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.label
            ]
            let title = "translated_document".localized
            let titleSize = title.size(withAttributes: titleAttributes)
            let titleRect = CGRect(x: margin, y: yPosition, width: pageWidth - 2 * margin, height: titleSize.height)
            title.draw(in: titleRect, withAttributes: titleAttributes)
            yPosition += titleSize.height + 20
            
            // Language info
            let languageInfo = "Translation: \(getLanguageName(sourceLanguage)) → \(getLanguageName(targetLanguage))"
            let langAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.label
            ]
            let langSize = languageInfo.size(withAttributes: langAttributes)
            let langRect = CGRect(x: margin, y: yPosition, width: pageWidth - 2 * margin, height: langSize.height)
            languageInfo.draw(in: langRect, withAttributes: langAttributes)
            yPosition += langSize.height + 20
            
            // Translation content will be formatted by drawFormattedText function
            
            // Draw clean translated text
            _ = drawSimpleText(translatedText, at: CGPoint(x: margin, y: yPosition), 
                             width: pageWidth - 2 * margin, 
                             context: context, 
                             pageHeight: pageHeight - margin)
        }
        
        return data
    }
    
    private func drawSimpleText(_ text: String, at point: CGPoint, width: CGFloat, 
                               context: UIGraphicsPDFRendererContext, 
                               pageHeight: CGFloat) -> CGFloat {
        var currentY = point.y
        let margin: CGFloat = 40
        
        // Simple paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .left
        paragraphStyle.paragraphSpacing = 8
        paragraphStyle.lineSpacing = 2
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.label,
            .paragraphStyle: paragraphStyle
        ]
        
        // Split text into paragraphs and draw each one
        let paragraphs = text.components(separatedBy: "\n\n")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        for paragraph in paragraphs {
            let cleanParagraph = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if cleanParagraph.isEmpty {
                continue
            }
            
            // Calculate height needed for this paragraph
            let paragraphHeight = cleanParagraph.boundingRect(
                with: CGSize(width: width, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: textAttributes,
                context: nil
            ).height
            
            // Check if we need a new page
            if currentY + paragraphHeight + paragraphStyle.paragraphSpacing > pageHeight {
                context.beginPage()
                currentY = margin
            }
            
            // Draw the paragraph
            let drawingRect = CGRect(x: point.x, y: currentY, width: width, height: paragraphHeight)
            cleanParagraph.draw(in: drawingRect, withAttributes: textAttributes)
            
            currentY += paragraphHeight + paragraphStyle.paragraphSpacing
        }
        
        return currentY
    }
    
    private func drawFormattedText(_ text: String, at point: CGPoint, width: CGFloat, 
                                 context: UIGraphicsPDFRendererContext, 
                                 pageHeight: CGFloat) -> CGFloat {
        var currentY = point.y
        let margin: CGFloat = 40
        
        // Parse text into structured sections
        let sections = parseTextSections(text)
        
        for section in sections {
            // Handle break elements
            if section.type == .lineBreak {
                currentY += 8 // Add spacing for breaks
                continue
            }
            
            if section.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                continue
            }
            
            var textAttributes: [NSAttributedString.Key: Any]
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping
            
            // Apply original indentation
            let baseIndent = CGFloat(section.indentLevel * 2) // 2 points per indent level
            
            // Configure style based on section type - preserving original formatting
            switch section.type {
            case .pageHeader:
                paragraphStyle.alignment = .center
                paragraphStyle.paragraphSpacing = 16
                paragraphStyle.paragraphSpacingBefore = 20
                textAttributes = [
                    .font: UIFont.boldSystemFont(ofSize: 12),
                    .foregroundColor: UIColor.systemGray,
                    .paragraphStyle: paragraphStyle
                ]
                
            case .heading1:
                paragraphStyle.alignment = .left
                paragraphStyle.paragraphSpacing = 12
                paragraphStyle.paragraphSpacingBefore = 24
                paragraphStyle.firstLineHeadIndent = baseIndent
                paragraphStyle.headIndent = baseIndent
                textAttributes = [
                    .font: UIFont.boldSystemFont(ofSize: 18),
                    .foregroundColor: UIColor.label,
                    .paragraphStyle: paragraphStyle
                ]
                
            case .heading2:
                paragraphStyle.alignment = .left
                paragraphStyle.paragraphSpacing = 10
                paragraphStyle.paragraphSpacingBefore = 18
                paragraphStyle.firstLineHeadIndent = baseIndent
                paragraphStyle.headIndent = baseIndent
                textAttributes = [
                    .font: UIFont.boldSystemFont(ofSize: 16),
                    .foregroundColor: UIColor.label,
                    .paragraphStyle: paragraphStyle
                ]
                
            case .heading3:
                paragraphStyle.alignment = .left
                paragraphStyle.paragraphSpacing = 8
                paragraphStyle.paragraphSpacingBefore = 14
                paragraphStyle.firstLineHeadIndent = baseIndent
                paragraphStyle.headIndent = baseIndent
                textAttributes = [
                    .font: UIFont.boldSystemFont(ofSize: 14),
                    .foregroundColor: UIColor.label,
                    .paragraphStyle: paragraphStyle
                ]
                
            case .paragraph:
                paragraphStyle.alignment = .left
                paragraphStyle.paragraphSpacing = 4 // Slightly more spacing between lines
                paragraphStyle.paragraphSpacingBefore = 0
                paragraphStyle.lineSpacing = 0 // No extra line spacing to preserve original layout
                paragraphStyle.firstLineHeadIndent = baseIndent
                paragraphStyle.headIndent = baseIndent
                textAttributes = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.label,
                    .paragraphStyle: paragraphStyle
                ]
                
            case .indentedText:
                paragraphStyle.alignment = .left
                paragraphStyle.paragraphSpacing = 4
                paragraphStyle.paragraphSpacingBefore = 0
                paragraphStyle.lineSpacing = 0
                // Apply proper indentation for nested content
                let effectiveIndent = baseIndent + 20 // Extra indent for nested content
                paragraphStyle.firstLineHeadIndent = effectiveIndent
                paragraphStyle.headIndent = effectiveIndent
                textAttributes = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.label,
                    .paragraphStyle: paragraphStyle
                ]
                
            case .singleLine:
                paragraphStyle.alignment = .left
                paragraphStyle.paragraphSpacing = 2 // Minimal spacing between individual lines
                paragraphStyle.paragraphSpacingBefore = 0
                paragraphStyle.lineSpacing = 0
                paragraphStyle.firstLineHeadIndent = baseIndent
                paragraphStyle.headIndent = baseIndent
                textAttributes = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.label,
                    .paragraphStyle: paragraphStyle
                ]
                
            case .lineBreak:
                continue // Skip - spacing handled by paragraph spacing
            }
            
            // Calculate the height needed for this section
            let adjustedWidth = width - (section.type == .indentedText ? 36 : 0)
            let sectionHeight = section.content.boundingRect(
                with: CGSize(width: adjustedWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: textAttributes,
                context: nil
            ).height
            
            // Check if we need a new page
            if currentY + sectionHeight + paragraphStyle.paragraphSpacingBefore > pageHeight {
                context.beginPage()
                currentY = margin
            }
            
            // Add spacing before section
            currentY += paragraphStyle.paragraphSpacingBefore
            
            // Draw the section
            let drawingRect = CGRect(x: point.x, y: currentY, width: width, height: sectionHeight)
            section.content.draw(in: drawingRect, withAttributes: textAttributes)
            
            currentY += sectionHeight + paragraphStyle.paragraphSpacing
        }
        
        return currentY
    }
    
    private func parseTextSections(_ text: String) -> [PDFTextSection] {
        var sections: [PDFTextSection] = []
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Skip empty lines
            if trimmedLine.isEmpty {
                continue
            }
            
            // Handle break elements by adding spacing
            if trimmedLine == "<BREAK/>" || trimmedLine == "<BREAK>" {
                if let lastSection = sections.last, lastSection.type != .lineBreak {
                    sections.append(PDFTextSection(content: "", type: .lineBreak))
                }
                continue
            }
            
            // Parse enhanced structured markup with new line-based tags
            if trimmedLine.hasPrefix("<PAGE>") && trimmedLine.hasSuffix("</PAGE>") {
                let pageNumber = String(trimmedLine.dropFirst(6).dropLast(7))
                sections.append(PDFTextSection(content: "Page \(pageNumber)", type: .pageHeader))
            } else if trimmedLine.hasPrefix("<TITLE>") && trimmedLine.hasSuffix("</TITLE>") {
                let content = String(trimmedLine.dropFirst(7).dropLast(8))
                sections.append(PDFTextSection(content: content, type: .heading1))
            } else if trimmedLine.hasPrefix("<H1>") && trimmedLine.hasSuffix("</H1>") {
                let content = String(trimmedLine.dropFirst(4).dropLast(5))
                sections.append(PDFTextSection(content: content, type: .heading1))
            } else if trimmedLine.hasPrefix("<H2>") && trimmedLine.hasSuffix("</H2>") {
                let content = String(trimmedLine.dropFirst(4).dropLast(5))
                sections.append(PDFTextSection(content: content, type: .heading2))
            } else if trimmedLine.hasPrefix("<H3>") && trimmedLine.hasSuffix("</H3>") {
                let content = String(trimmedLine.dropFirst(4).dropLast(5))
                sections.append(PDFTextSection(content: content, type: .heading3))
            } else if trimmedLine.hasPrefix("<INDENT:") && trimmedLine.hasSuffix("</INDENT>") {
                // Parse <INDENT:4>content</INDENT> format
                if let colonIndex = trimmedLine.firstIndex(of: ":"),
                   let closeIndex = trimmedLine.firstIndex(of: ">") {
                    let indentString = String(trimmedLine[trimmedLine.index(after: colonIndex)..<closeIndex])
                    let indentLevel = Int(indentString) ?? 0
                    let content = String(trimmedLine[trimmedLine.index(after: closeIndex)..<trimmedLine.index(trimmedLine.endIndex, offsetBy: -9)])
                    sections.append(PDFTextSection(content: content, type: .indentedText, indentLevel: indentLevel / 4)) // Convert spaces to indent levels
                }
            } else if trimmedLine.hasPrefix("<LINE>") && trimmedLine.hasSuffix("</LINE>") {
                let content = String(trimmedLine.dropFirst(6).dropLast(7))
                sections.append(PDFTextSection(content: content, type: .singleLine))
            } else if trimmedLine.hasPrefix("<P>") && trimmedLine.hasSuffix("</P>") {
                let content = String(trimmedLine.dropFirst(3).dropLast(4))
                sections.append(PDFTextSection(content: content, type: .paragraph))
            } else {
                // Fallback for unstructured text - treat as individual line
                sections.append(PDFTextSection(content: trimmedLine, type: .paragraph))
            }
        }
        
        return sections
    }
    
    private func parseTagWithAttributes(_ line: String, tagName: String) -> (content: String, indentLevel: Int) {
        // Extract content between tags
        let pattern = "<\(tagName)[^>]*>(.+?)</\(tagName)>"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: line.count)
        
        var content = ""
        var indentLevel = 0
        
        if let match = regex?.firstMatch(in: line, options: [], range: range) {
            let contentRange = match.range(at: 1)
            if contentRange.location != NSNotFound {
                content = String(line[Range(contentRange, in: line)!])
            }
        }
        
        // Extract indent level attribute
        if let indentMatch = line.range(of: "INDENT=\"(\\d+)\"", options: .regularExpression) {
            let indentString = String(line[indentMatch]).replacingOccurrences(of: "INDENT=\"", with: "").replacingOccurrences(of: "\"", with: "")
            indentLevel = Int(indentString) ?? 0
        } else if let levelMatch = line.range(of: "LEVEL=\"(\\d+)\"", options: .regularExpression) {
            let levelString = String(line[levelMatch]).replacingOccurrences(of: "LEVEL=\"", with: "").replacingOccurrences(of: "\"", with: "")
            indentLevel = Int(levelString) ?? 0
        }
        
        return (content, indentLevel)
    }
    
    private func isLikelyHeading(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        
        // Too long for heading
        if trimmed.count > 100 { return false }
        
        // Ends with period - probably not a heading
        if trimmed.hasSuffix(".") { return false }
        
        // Too short
        if trimmed.count < 3 { return false }
        
        // Check for heading keywords
        let headingKeywords = ["CHAPTER", "ГЛАВА", "РОЗДІЛ", "SECTION", "СЕКЦІЯ", "PART", "ЧАСТИНА", "INTRODUCTION", "ВСТУП", "CONCLUSION", "ВИСНОВОК"]
        let upperText = trimmed.uppercased()
        
        for keyword in headingKeywords {
            if upperText.contains(keyword) {
                return true
            }
        }
        
        // Check uppercase ratio
        let uppercaseCount = trimmed.filter { $0.isUppercase }.count
        let letterCount = trimmed.filter { $0.isLetter }.count
        
        if letterCount > 0 {
            let uppercaseRatio = Double(uppercaseCount) / Double(letterCount)
            if uppercaseRatio > 0.5 {
                return true
            }
        }
        
        // Short text starting with uppercase
        if trimmed.count <= 50 && trimmed.first?.isUppercase == true {
            let punctuationCount = trimmed.filter { ".,;:!?".contains($0) }.count
            return punctuationCount <= 2
        }
        
        return false
    }
    
    private func getLanguageName(_ code: String) -> String {
        switch code {
        case "auto": return "Auto-detect"
        case "en": return "English"
        case "uk": return "Ukrainian"
        case "ru": return "Russian"
        case "es": return "Spanish"
        case "fr": return "French"
        case "de": return "German"
        case "zh": return "Chinese"
        default: return code.uppercased()
        }
    }
}

// MARK: - PDF Text Section
private struct PDFTextSection {
    let content: String
    let type: PDFTextType
    let indentLevel: Int
    
    init(content: String, type: PDFTextType, indentLevel: Int = 0) {
        self.content = content
        self.type = type
        self.indentLevel = indentLevel
    }
    
    enum PDFTextType {
        case pageHeader
        case heading1 
        case heading2
        case heading3
        case paragraph
        case indentedText
        case lineBreak
        case singleLine  // For individual lines that should not be merged
    }
}