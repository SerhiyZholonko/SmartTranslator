import SwiftUI
import AVFoundation
import Vision

@MainActor
final class CameraTranslatorViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var capturedImage: UIImage?
    @Published var recognizedText = ""
    @Published var translatedText = ""
    @Published var sourceLanguage = "auto"
    @Published var targetLanguage = "en"
    @Published var isProcessing = false
    @Published var showLanguagePicker = false
    @Published var isSelectingSourceLanguage = true
    @Published var showCamera = true
    
    // MARK: - Services
    private let translationManager = TranslationManager.shared
    private let permissionsManager = PermissionsManager.shared
    
    override init() {
        super.init()
        checkCameraPermission()
    }
    
    // MARK: - Public Methods
    func capturePhoto(_ image: UIImage) {
        capturedImage = image
        showCamera = false
        recognizeText(from: image)
    }
    
    func retakePhoto() {
        capturedImage = nil
        recognizedText = ""
        translatedText = ""
        showCamera = true
        clearError()
    }
    
    func translate() {
        guard !recognizedText.isEmpty else {
            showError("no_text_recognized".localized)
            return
        }
        
        Task {
            isProcessing = true
            clearError()
            
            do {
                let result = try await translationManager.translate(
                    text: recognizedText,
                    from: sourceLanguage,
                    to: targetLanguage
                )
                translatedText = result
            } catch {
                handleError(error)
            }
            
            isProcessing = false
        }
    }
    
    func selectLanguage(_ language: String, isSource: Bool) {
        if isSource {
            sourceLanguage = language
        } else {
            targetLanguage = language
        }
        
        // Re-translate if we have text
        if !recognizedText.isEmpty && !translatedText.isEmpty {
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
    
    // MARK: - Private Methods
    private func checkCameraPermission() {
        Task {
            let hasPermission = await permissionsManager.requestCameraPermission()
            if !hasPermission {
                showError("camera_permission_denied".localized)
                showCamera = false
            }
        }
    }
    
    private func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else {
            showError("invalid_image".localized)
            return
        }
        
        isProcessing = true
        clearError()
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.handleError(error)
                    self.isProcessing = false
                }
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                DispatchQueue.main.async {
                    self.showError("text_recognition_failed".localized)
                    self.isProcessing = false
                }
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            DispatchQueue.main.async {
                self.recognizedText = recognizedStrings.joined(separator: "\n")
                
                if self.recognizedText.isEmpty {
                    self.showError("no_text_found".localized)
                } else {
                    // Auto-translate
                    self.translate()
                }
                
                self.isProcessing = false
            }
        }
        
        // Configure recognition
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        // Set recognition languages based on source language
        if sourceLanguage != "auto" {
            request.recognitionLanguages = [sourceLanguage]
        }
        
        // Create handler
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Perform recognition
        Task {
            do {
                try handler.perform([request])
            } catch {
                await MainActor.run {
                    self.handleError(error)
                    self.isProcessing = false
                }
            }
        }
    }
}