import SwiftUI
import AVFoundation
import Speech

struct VoiceChatView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @StateObject private var permissionsManager = PermissionsManager.shared
    @StateObject private var translationManager = TranslationManager.shared
    @StateObject private var flashcardManager = FlashcardManager.shared
    @State private var sourceLanguage = "en"
    @State private var targetLanguage = "uk"
    @State private var conversations: [VoiceConversation] = []
    @State private var isRecording = false
    @State private var currentRecordingSide: ConversationSide = .left
    @State private var showPermissionAlert = false
    @State private var pendingTranslations: Set<String> = []
    @State private var audioLevels: [CGFloat] = [0.2, 0.3, 0.2, 0.4, 0.3]
    @State private var animationTimer: Timer?
    @State private var showFlashcardOptions = false
    @State private var selectedConversation: VoiceConversation?
    @State private var showDeckSelection = false
    
    enum ConversationSide {
        case left, right
    }
    
    var body: some View {
        LocalizedView {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.appBackground,
                    AppColors.cardBackground
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("voice_chat_title".localized)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppColors.primaryText)
                        
                        // Service picker menu
                        Menu {
                            ForEach(translationManager.getAvailableServices(), id: \.self) { service in
                                Button(action: {
                                    translationManager.setTranslationService(service)
                                }) {
                                    HStack {
                                        Image(systemName: service.systemImageName)
                                        Text(service.displayName)
                                        Spacer()
                                        if service == translationManager.currentService {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: translationManager.currentService.systemImageName)
                                    .font(.caption)
                                Text(translationManager.currentServiceName)
                                    .font(.caption)
                                Image(systemName: "chevron.down")
                                    .font(.caption2)
                            }
                            .foregroundColor(AppColors.secondaryText)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(AppColors.secondaryText.opacity(0.1))
                            )
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { clearConversations() }) {
                        Image(systemName: "trash")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme))
                    }
                    .opacity(conversations.isEmpty ? 0 : 1)
                }
                .padding()
                .background(AppColors.cardBackground)
            
            // Content
            if conversations.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text("no_chats_yet".localized)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("start_conversation".localized)
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.secondaryText)
                    
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(conversations) { conversation in
                            ConversationBubble(conversation: conversation) { selectedConv in
                                selectedConversation = selectedConv
                                showFlashcardOptions = true
                            }
                        }
                    }
                    .padding()
                }
            }
            
            // Recording interface
            if isRecording {
                VStack(spacing: 20) {
                    // Dynamic waveform animation
                    SpeakingAnimationView(audioLevels: audioLevels, recordingSide: currentRecordingSide)
                    
                    Text("speak_up".localized)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(AppColors.primaryText)
                }
                .padding(30)
                .background(AppColors.cardBackground)
                .cornerRadius(20)
                .shadow(color: AppColors.primaryText.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding()
                .transition(.scale.combined(with: .opacity))
            }
            
            // Language selectors and record buttons
            HStack(spacing: 20) {
                // Left language button
                VoiceButton(
                    language: $sourceLanguage,
                    isRecording: isRecording && currentRecordingSide == .left,
                    side: .left,
                    action: {
                        startRecording(side: .left)
                    }
                )
                
                // Swap button
                Button(action: swapLanguages) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.buttonText)
                        .frame(width: 50, height: 50)
                        .background(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme))
                        .clipShape(Circle())
                }
                
                // Right language button
                VoiceButton(
                    language: $targetLanguage,
                    isRecording: isRecording && currentRecordingSide == .right,
                    side: .right,
                    action: {
                        startRecording(side: .right)
                    }
                )
            }
            .padding()
            .background(AppColors.inputBackground)
        }
        }
        .alert("microphone_access_needed".localized, isPresented: $showPermissionAlert) {
            Button("open_settings".localized, action: openSettings)
            Button("cancel".localized, role: .cancel) { }
        } message: {
            Text("please_enable_microphone".localized)
        }
        .sheet(isPresented: $showFlashcardOptions) {
            if let conversation = selectedConversation {
                VoiceFlashcardSelectionView(
                    originalText: conversation.originalText ?? "",
                    translatedText: conversation.text,
                    sourceLanguage: conversation.side == .left ? targetLanguage : sourceLanguage,
                    targetLanguage: conversation.language,
                    onSave: {
                        showFlashcardOptions = false
                        selectedConversation = nil
                    }
                )
            }
        }
        .onAppear {
            requestPermissions()
            loadLanguageSettings()
        }
        }
    }
    
    private func startRecording(side: ConversationSide) {
        print("🎤 Starting recording for side: \(side)")
        
        Task {
            // Check permissions first
            print("🔐 Checking permissions...")
            let micGranted = await permissionsManager.requestMicrophonePermission()
            let speechGranted = await permissionsManager.requestSpeechRecognitionPermission()
            
            print("🔐 Microphone granted: \(micGranted), Speech granted: \(speechGranted)")
            
            guard micGranted && speechGranted else {
                print("❌ Permissions denied")
                await MainActor.run {
                    showPermissionAlert = true
                }
                return
            }
            
            await MainActor.run {
                if isRecording {
                    print("🛑 Stopping existing recording")
                    stopRecording()
                } else {
                    print("▶️ Starting new recording")
                    currentRecordingSide = side
                    isRecording = true
                    startAudioAnimation()
                    
                    let language = side == .left ? sourceLanguage : targetLanguage
                    print("🌍 Recording language: \(language)")
                    
                    speechRecognizer.startRecording(language: language) { text in
                        Task { @MainActor in
                            print("📝 Recognition result: \(text ?? "nil")")
                            // Handle recognized text
                            if let text = text, !text.isEmpty {
                                print("➕ Adding original text: '\(text)' for side: \(side)")
                                addConversation(text: text, side: side, isTranslation: false)
                                translateAndSpeak(text: text, from: language, to: side == .left ? targetLanguage : sourceLanguage, originalSide: side)
                            }
                            isRecording = false
                        }
                    }
                }
            }
        }
    }
    
    private func stopRecording() {
        speechRecognizer.stopRecording()
        isRecording = false
        stopAudioAnimation()
    }
    
    private func startAudioAnimation() {
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.6)) {
                // Generate random audio levels to simulate speech
                audioLevels = (0..<5).map { _ in
                    CGFloat.random(in: 0.2...0.8)
                }
            }
        }
    }
    
    private func stopAudioAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        withAnimation(.easeOut(duration: 0.8)) {
            audioLevels = [0.2, 0.3, 0.2, 0.4, 0.3]
        }
    }
    
    private func addConversation(text: String, side: ConversationSide, isTranslation: Bool = false, originalText: String? = nil) {
        // Create unique key for this text+side combination
        let conversationKey = "\(text)-\(side)"
        
        // Check for exact duplicates (same text, same side)
        let exactDuplicate = conversations.contains { conversation in
            conversation.text == text && conversation.side == side
        }
        
        if exactDuplicate {
            print("🚫 Preventing exact duplicate: '\(text)' for side: \(side)")
            return
        }
        
        // If this is a translation, check if we're already processing it
        if isTranslation {
            if pendingTranslations.contains(conversationKey) {
                print("🚫 Translation already pending for: '\(text)' side: \(side)")
                return
            }
            pendingTranslations.insert(conversationKey)
        }
        
        let conversation = VoiceConversation(
            text: text,
            side: side,
            language: side == .left ? sourceLanguage : targetLanguage,
            timestamp: Date(),
            isTranslation: isTranslation,
            originalText: originalText
        )
        
        print("✅ Adding conversation: '\(text)' for side: \(side), isTranslation: \(isTranslation)")
        conversations.append(conversation)
        
        // Remove from pending after adding
        if isTranslation {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                pendingTranslations.remove(conversationKey)
            }
        }
    }
    
    private func translateAndSpeak(text: String, from: String, to: String, originalSide: ConversationSide) {
        Task {
            do {
                let translated = try await translationManager.translate(text: text, from: from, to: to)
                
                await MainActor.run {
                    // Add translation on opposite side
                    let translationSide: ConversationSide = originalSide == .left ? .right : .left
                    print("➕ Adding translation: '\(translated)' for side: \(translationSide)")
                    addConversation(text: translated, side: translationSide, isTranslation: true, originalText: text)
                    
                    // Speak the translation
                    let synthesizer = AVSpeechSynthesizer()
                    let utterance = AVSpeechUtterance(string: translated)
                    utterance.voice = AVSpeechSynthesisVoice(language: to)
                    utterance.rate = 0.5
                    synthesizer.speak(utterance)
                }
            } catch {
                print("Translation error: \(error)")
            }
        }
    }
    
    private func swapLanguages() {
        let temp = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = temp
    }
    
    private func clearConversations() {
        conversations.removeAll()
    }
    
    private func requestPermissions() {
        Task {
            let microphoneGranted = await permissionsManager.requestMicrophonePermission()
            let speechGranted = await permissionsManager.requestSpeechRecognitionPermission()
            
            if !microphoneGranted || !speechGranted {
                await MainActor.run {
                    showPermissionAlert = true
                }
            }
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
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

struct VoiceButton: View {
    @Binding var language: String
    let isRecording: Bool
    let side: VoiceChatView.ConversationSide
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: action) {
                ZStack {
                    Circle()
                        .fill(isRecording ? AppColors.errorColor : (side == .left ? AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme) : AppColors.successColor))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 30))
                        .foregroundColor(AppColors.buttonText)
                }
            }
            
            Menu {
                Button("🇬🇧 \("language_english".localized)") { language = "en-US" }
                Button("🇺🇦 \("language_ukrainian".localized)") { language = "uk-UA" }
                Button("🇨🇳 \("language_chinese_simplified".localized)") { language = "zh-CN" }
                Button("🇪🇸 \("language_spanish".localized)") { language = "es-ES" }
                Button("🇫🇷 \("language_french".localized)") { language = "fr-FR" }
                Button("🇩🇪 \("language_german".localized)") { language = "de-DE" }
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(getFlag(for: language))
                    Text(getLanguageName(for: language))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .minimumScaleFactor(0.7)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                }
                .font(.system(size: 14))
                .foregroundColor(AppColors.primaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppColors.cardBackground)
                .cornerRadius(15)
            }
        }
    }
    
    private func getFlag(for languageCode: String) -> String {
        switch languageCode {
        case "en-US", "en": return "🇬🇧"
        case "uk-UA", "uk": return "🇺🇦"
        case "zh-CN", "zh": return "🇨🇳"
        case "es-ES", "es": return "🇪🇸"
        case "fr-FR", "fr": return "🇫🇷"
        case "de-DE", "de": return "🇩🇪"
        default: return "🌐"
        }
    }
    
    private func getLanguageName(for languageCode: String) -> String {
        switch languageCode {
        case "en-US", "en": return "language_english".localized
        case "uk-UA", "uk": return "language_ukrainian".localized
        case "zh-CN", "zh": return "language_chinese_simplified".localized
        case "es-ES", "es": return "language_spanish".localized
        case "fr-FR", "fr": return "language_french".localized
        case "de-DE", "de": return "language_german".localized
        default: return "unknown".localized
        }
    }
}

struct ConversationBubble: View {
    let conversation: VoiceConversation
    let onAddToFlashcard: (VoiceConversation) -> Void
    
    var body: some View {
        HStack {
            if conversation.side == .right {
                Spacer()
            }
            
            VStack(alignment: conversation.side == .left ? .leading : .trailing, spacing: 4) {
                HStack {
                    if conversation.side == .right {
                        // Кнопка додавання в картки для перекладів (зелені бульбашки)
                        if conversation.isTranslation {
                            Button(action: {
                                onAddToFlashcard(conversation)
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme))
                            }
                        }
                    }
                    
                    Text(conversation.text)
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.buttonText)
                        .padding()
                        .background(
                            conversation.side == .left ? AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme) : AppColors.successColor
                        )
                        .cornerRadius(20)
                    
                    if conversation.side == .left {
                        // Кнопка додавання в картки для перекладів (сині бульбашки)
                        if conversation.isTranslation {
                            Button(action: {
                                onAddToFlashcard(conversation)
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme))
                            }
                        }
                    }
                }
                
                Text(conversation.timestamp, style: .time)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            if conversation.side == .left {
                Spacer()
            }
        }
    }
}

struct VoiceConversation: Identifiable {
    let id = UUID()
    let text: String
    let side: VoiceChatView.ConversationSide
    let language: String
    let timestamp: Date
    let isTranslation: Bool
    let originalText: String? // Оригінальний текст для перекладу
}

// Speech Recognizer
@MainActor
class SpeechRecognizer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private nonisolated let audioEngine = AVAudioEngine()
    private var completion: ((String?) -> Void)?
    private var hasCompletedRecognition = false
    
    override init() {
        super.init()
        // Initialize with default locale
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        speechRecognizer?.delegate = self
    }
    
    deinit {
        print("🗑️ SpeechRecognizer deinit called")
        
        // Clean up audio engine safely (nonisolated)
        if audioEngine.isRunning {
            print("🛑 Stopping audio engine in deinit")
            audioEngine.stop()
            
            if audioEngine.inputNode.numberOfInputs > 0 {
                audioEngine.inputNode.removeTap(onBus: 0)
            }
        }
        
        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            print("🔊 Audio session deactivated in deinit")
        } catch {
            print("⚠️ Error deactivating audio session in deinit: \(error)")
        }
    }
    
    func startRecording(language: String, completion: @escaping (String?) -> Void) {
        print("🎤 SpeechRecognizer.startRecording called with language: \(language)")
        
        // Check permissions first
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        print("🔐 Speech authorization status: \(speechStatus)")
        guard speechStatus == .authorized else {
            print("❌ Speech recognition not authorized: \(speechStatus)")
            completion(nil)
            return
        }
        
        // Check microphone permission
        let microphonePermission: Bool
        if #available(iOS 17.0, *) {
            let micStatus = AVCaptureDevice.authorizationStatus(for: .audio)
            microphonePermission = micStatus == .authorized
            print("🔐 iOS 17+ Microphone status: \(micStatus)")
        } else {
            let micStatus = AVAudioSession.sharedInstance().recordPermission
            microphonePermission = micStatus == .granted
            print("🔐 Legacy Microphone status: \(micStatus)")
        }
        
        guard microphonePermission else {
            print("❌ Microphone permission not granted")
            completion(nil)
            return
        }
        
        self.completion = completion
        
        // Stop any existing recording first
        print("🛑 Stopping any existing recording...")
        stopRecording()
        
        // Configure speech recognizer for the selected language
        print("🌍 Creating speech recognizer for locale: \(language)")
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: language))
        
        guard let speechRecognizer = speechRecognizer else {
            print("❌ Could not create speech recognizer for language: \(language)")
            completion(nil)
            return
        }
        
        guard speechRecognizer.isAvailable else {
            print("❌ Speech recognizer not available for language: \(language)")
            completion(nil)
            return
        }
        
        print("✅ Speech recognizer created and available")
        speechRecognizer.delegate = self
        
        // Configure audio session with better error handling
        print("🔊 Configuring audio session...")
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Try simpler configuration first
            try audioSession.setCategory(.record, mode: .default, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("✅ Audio session configured successfully")
        } catch {
            print("❌ Audio session setup error: \(error)")
            completion(nil)
            return
        }
        
        // Create recognition request
        print("📄 Creating recognition request...")
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            print("❌ Could not create recognition request")
            completion(nil)
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        if #available(iOS 13.0, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        print("✅ Recognition request configured")
        
        // Start recognition task with better error handling
        print("🚀 Starting recognition task...")
        // Timer to capture partial results if no final result comes
        let timeoutTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            print("⏰ Speech recognition timeout - capturing partial result")
            Task { @MainActor in
                self?.stopRecording()
            }
        }
        
        var lastPartialText = ""
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self = self else { 
                    print("⚠️ Self is nil in recognition callback")
                    timeoutTimer.invalidate()
                    return 
                }
                
                if let result = result {
                    let text = result.bestTranscription.formattedString
                    print("📝 Recognition result: '\(text)', isFinal: \(result.isFinal)")
                    
                    lastPartialText = text
                    
                    if result.isFinal {
                        print("✅ Final result received, stopping recording")
                        timeoutTimer.invalidate()
                        self.stopRecording()
                        completion(text.isEmpty ? nil : text)
                        return
                    }
                    
                    // If we have good partial text and no final result after 2 seconds
                    if !text.isEmpty && text.count > 3 {
                        timeoutTimer.invalidate()
                        let newTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                            print("⏰ Using partial result: '\(lastPartialText)'")
                            Task { @MainActor in
                                self?.stopRecording()
                            }
                            completion(lastPartialText.isEmpty ? nil : lastPartialText)
                        }
                        // Store timer reference to invalidate if needed
                        self.completion = { text in
                            newTimer.invalidate()
                            completion(text)
                        }
                    }
                }
                
                if let error = error {
                    print("❌ Recognition error: \(error.localizedDescription)")
                    timeoutTimer.invalidate()
                    self.stopRecording()
                    // Use last partial text if available
                    completion(lastPartialText.isEmpty ? nil : lastPartialText)
                }
            }
        }
        
        // Configure audio engine with better error handling
        print("🔊 Configuring audio engine...")
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        print("🎤 Recording format: \(recordingFormat)")
        
        // Remove any existing tap first
        if inputNode.numberOfInputs > 0 {
            inputNode.removeTap(onBus: 0)
            print("🧩 Removed existing tap")
        }
        
        // Install new tap
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        print("✅ Audio tap installed")
        
        // Prepare and start audio engine
        print("🚀 Preparing audio engine...")
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            print("✅ Audio engine started successfully")
        } catch {
            print("❌ Audio engine start error: \(error)")
            stopRecording()
            completion(nil)
            return
        }
        
        print("✅ Recording started successfully")
        
        // Global timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            if !self.hasCompletedRecognition {
                print("⏰ Global recognition timeout")
                self.completeRecognitionSafely(with: lastPartialText, completion: completion)
            }
        }
    }
    
    private func completeRecognitionSafely(with text: String, completion: @escaping (String?) -> Void) {
        guard !hasCompletedRecognition else {
            print("🚫 Recognition already completed, ignoring duplicate")
            return
        }
        
        hasCompletedRecognition = true
        print("✅ Safely completing recognition with: '\(text)'")
        
        stopRecording()
        completion(text.isEmpty ? nil : text)
    }
    
    func stopRecording() {
        print("🛑 SpeechRecognizer.stopRecording called")
        
        // Stop audio engine safely
        if audioEngine.isRunning {
            print("🛑 Stopping audio engine...")
            audioEngine.stop()
            
            if audioEngine.inputNode.numberOfInputs > 0 {
                audioEngine.inputNode.removeTap(onBus: 0)
                print("🧩 Removed audio tap")
            }
        }
        
        // Clean up recognition objects
        if let request = recognitionRequest {
            print("📄 Ending recognition request...")
            request.endAudio()
            recognitionRequest = nil
        }
        
        if let task = recognitionTask {
            print("🚫 Canceling recognition task...")
            task.cancel()
            recognitionTask = nil
        }
        
        // Reset completion callback
        completion = nil
        print("🧩 Cleared completion callback")
        
        // Deactivate audio session safely
        Task.detached {
            do {
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                print("🔊 Audio session deactivated")
            } catch {
                print("⚠️ Error deactivating audio session: \(error)")
            }
        }
        
        print("✅ Recording stopped successfully")
    }
}

// Speaking Animation View
struct SpeakingAnimationView: View {
    let audioLevels: [CGFloat]
    let recordingSide: VoiceChatView.ConversationSide
    @State private var animatingBars = Set<Int>()
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<audioLevels.count, id: \.self) { index in
                SpeakingBar(
                    height: 10 + (audioLevels[index] * 30),
                    isAnimating: animatingBars.contains(index),
                    color: recordingSide == .left ? AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme) : AppColors.successColor
                )
            }
        }
        .frame(height: 50)
        .onAppear {
            startRandomAnimation()
        }
    }
    
    private func startRandomAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.8)) {
                let randomBar = Int.random(in: 0..<audioLevels.count)
                if animatingBars.contains(randomBar) {
                    animatingBars.remove(randomBar)
                } else {
                    animatingBars.insert(randomBar)
                }
            }
        }
    }
}

struct SpeakingBar: View {
    let height: CGFloat
    let isAnimating: Bool
    let color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        color.opacity(0.8),
                        color
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .frame(width: 8, height: height)
            .scaleEffect(y: isAnimating ? 1.3 : 1.0, anchor: .bottom)
            .animation(
                isAnimating ? 
                    Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true) :
                    Animation.easeOut(duration: 0.5),
                value: isAnimating
            )
    }
}

// View для вибору деку та збереження картки з голосового чату
struct VoiceFlashcardSelectionView: View {
    let originalText: String
    let translatedText: String
    let sourceLanguage: String
    let targetLanguage: String
    let onSave: () -> Void
    
    @StateObject private var flashcardManager = FlashcardManager.shared
    @State private var selectedDeck: FlashcardDeck?
    @State private var showCreateDeck = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Preview of flashcard
                VStack(alignment: .leading, spacing: 12) {
                    Text("add_to_flashcards_title".localized)
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Front (\(getLanguageName(sourceLanguage)))")
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryText)
                            Text(originalText)
                                .font(.body)
                                .foregroundColor(AppColors.primaryText)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(AppColors.secondaryText)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Back (\(getLanguageName(targetLanguage)))")
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryText)
                            Text(translatedText)
                                .font(.body)
                                .foregroundColor(AppColors.primaryText)
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                }
                
                // Deck selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("choose_deck_to_add".localized)
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                    
                    let compatibleDecks = getCompatibleDecks()
                    
                    if compatibleDecks.isEmpty {
                        VStack(spacing: 12) {
                            Text("no_compatible_decks".localized)
                                .foregroundColor(AppColors.secondaryText)
                            
                            Button("create_deck_for_languages".localized(with: getLanguageName(sourceLanguage), getLanguageName(targetLanguage))) {
                                showCreateDeck = true
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme))
                        }
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(compatibleDecks) { deck in
                                Button(action: {
                                    selectedDeck = deck
                                    saveFlashcard()
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(deck.name)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(AppColors.primaryText)
                                            Text("cards_count_simple".localized(with: deck.flashcardIds.count))
                                                .font(.caption)
                                                .foregroundColor(AppColors.secondaryText)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(AppColors.secondaryText)
                                    }
                                    .padding()
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        Button("create_new_deck".localized) {
                            showCreateDeck = true
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme))
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("add_to_flashcards".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                    .foregroundColor(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme))
                }
            }
            .sheet(isPresented: $showCreateDeck) {
                // Here would be create deck view - simplified for now
                Text("Create deck feature coming soon")
            }
        }
    }
    
    private func getCompatibleDecks() -> [FlashcardDeck] {
        return flashcardManager.decks.filter { deck in
            deck.sourceLanguage == sourceLanguage && deck.targetLanguage == targetLanguage
        }
    }
    
    private func getLanguageName(_ code: String) -> String {
        let languageNames: [String: String] = [
            "en": "English",
            "uk": "Ukrainian",
            "es": "Spanish",
            "fr": "French",
            "de": "German",
            "zh": "Chinese"
        ]
        return languageNames[code] ?? code.uppercased()
    }
    
    private func saveFlashcard() {
        guard let deck = selectedDeck else { return }
        
        let newCard = Flashcard(
            frontText: originalText,
            backText: translatedText,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            category: "Voice Chat"
        )
        
        _ = flashcardManager.addFlashcardToDeck(newCard, deck: deck)
        onSave()
        dismiss()
    }
}

#Preview {
    VoiceChatView()
}