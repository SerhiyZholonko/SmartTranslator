import SwiftUI
import Speech
import AVFoundation

@MainActor
final class VoiceChatViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var isRecording = false
    @Published var isTranslating = false
    @Published var recognizedText = ""
    @Published var translatedText = ""
    @Published var sourceLanguage = "en"
    @Published var targetLanguage = "en"
    @Published var showLanguagePicker = false
    @Published var isSelectingSourceLanguage = true
    @Published var audioLevel: CGFloat = 0
    
    // MARK: - Services
    private let translationManager = TranslationManager.shared
    private let permissionsManager = PermissionsManager.shared
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    // MARK: - Properties
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioLevelTimer: Timer?
    
    override init() {
        super.init()
        setupAudioSession()
        checkPermissions()
    }
    
    // MARK: - Setup
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            showError("Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Public Methods
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func startRecording() {
        Task {
            let hasPermission = await permissionsManager.requestMicrophonePermission()
            guard hasPermission else {
                showError("microphone_permission_denied".localized)
                return
            }
            
            do {
                try await startSpeechRecognition()
                isRecording = true
                startAudioLevelMonitoring()
            } catch {
                showError("speech_recognition_error".localized)
            }
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        isRecording = false
        stopAudioLevelMonitoring()
        audioLevel = 0
        
        // Translate the recognized text
        if !recognizedText.isEmpty {
            translateText()
        }
    }
    
    func swapLanguages() {
        // Allow swap for all languages
        
        let temp = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = temp
        
        // Update speech recognizer locale
        updateSpeechRecognizerLocale()
    }
    
    func clearAll() {
        recognizedText = ""
        translatedText = ""
        clearError()
    }
    
    func speakTranslation() {
        guard !translatedText.isEmpty else { return }
        
        let utterance = AVSpeechUtterance(string: translatedText)
        utterance.voice = AVSpeechSynthesisVoice(language: targetLanguage)
        utterance.rate = 0.5
        
        speechSynthesizer.speak(utterance)
    }
    
    func selectLanguage(_ language: String, isSource: Bool) {
        if isSource {
            sourceLanguage = language
            updateSpeechRecognizerLocale()
        } else {
            targetLanguage = language
        }
    }
    
    // MARK: - Private Methods
    private func checkPermissions() {
        Task {
            let hasMicPermission = await permissionsManager.requestMicrophonePermission()
            let hasSpeechPermission = await requestSpeechRecognitionPermission()
            
            if !hasMicPermission || !hasSpeechPermission {
                showError("permissions_required".localized)
            }
        }
    }
    
    private func requestSpeechRecognitionPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    private func startSpeechRecognition() async throws {
        // Cancel previous task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let inputNode = audioEngine.inputNode
        
        // Create and configure request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "VoiceChatViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request"])
        }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = false
        
        // Create recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                self.recognizedText = result.bestTranscription.formattedString
            }
            
            if error != nil || result?.isFinal == true {
                self.stopRecording()
            }
        }
        
        // Configure audio input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    private func translateText() {
        guard !recognizedText.isEmpty else { return }
        
        Task {
            isTranslating = true
            clearError()
            
            do {
                let result = try await translationManager.translate(
                    text: recognizedText,
                    from: sourceLanguage,
                    to: targetLanguage
                )
                translatedText = result
                
                // Auto-speak translation
                speakTranslation()
            } catch {
                handleError(error)
            }
            
            isTranslating = false
        }
    }
    
    private func updateSpeechRecognizerLocale() {
        // This would need to recreate the speech recognizer with new locale
        // For now, we'll keep it simple
    }
    
    private func startAudioLevelMonitoring() {
        // Stop any existing monitoring first
        stopAudioLevelMonitoring()
        
        audioLevelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.isRecording else { return }
            
            let inputNode = self.audioEngine.inputNode
            let bus = 0
            
            // Check if tap is already installed to prevent multiple installations
            guard inputNode.numberOfInputs > 0 else { return }
            
            inputNode.installTap(onBus: bus, bufferSize: 2048, format: inputNode.inputFormat(forBus: bus)) { buffer, _ in
                let level = self.getAudioLevel(from: buffer)
                DispatchQueue.main.async {
                    self.audioLevel = CGFloat(level)
                }
            }
        }
    }
    
    private func stopAudioLevelMonitoring() {
        audioLevelTimer?.invalidate()
        audioLevelTimer = nil
        
        // Safely remove tap if audio engine is running
        if audioEngine.isRunning {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
    }
    
    private func getAudioLevel(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return 0 }
        
        let channelDataValue = channelData.pointee
        let channelDataArray = Array(UnsafeBufferPointer(start: channelDataValue, count: Int(buffer.frameLength)))
        
        let rms = sqrt(channelDataArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        let avgPower = 20 * log10(rms)
        
        // Convert to 0-1 range
        let minDb: Float = -80
        let normalizedPower = (avgPower - minDb) / -minDb
        
        return max(0, min(1, normalizedPower))
    }
    
    deinit {
        print("🗑️ VoiceChatViewModel deinit called")
        
        // Stop audio engine and tasks (safe to call from any thread)
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        speechSynthesizer.stopSpeaking(at: .immediate)
        
        // Stop timer (safe to call from any thread)
        audioLevelTimer?.invalidate()
        
        // Deactivate audio session (safe to call from any thread)
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            print("🔊 Audio session deactivated in deinit")
        } catch {
            print("❌ Failed to deactivate audio session: \(error)")
        }
    }
}