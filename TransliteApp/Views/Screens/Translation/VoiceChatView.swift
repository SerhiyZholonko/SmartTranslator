import SwiftUI
import AVFoundation
import Speech

struct VoiceChatView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @StateObject private var permissionsManager = PermissionsManager.shared
    @State private var sourceLanguage = "en"
    @State private var targetLanguage = "uk"
    @State private var conversations: [VoiceConversation] = []
    @State private var isRecording = false
    @State private var currentRecordingSide: ConversationSide = .left
    @State private var showPermissionAlert = false
    @State private var pendingTranslations: Set<String> = []
    @State private var audioLevels: [CGFloat] = [0.2, 0.3, 0.2, 0.4, 0.3]
    @State private var animationTimer: Timer?
    
    enum ConversationSide {
        case left, right
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.9, green: 0.93, blue: 0.98)
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
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("Voice Chat")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Spacer()
                    
                    Button(action: { clearConversations() }) {
                        Image(systemName: "trash")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                    .opacity(conversations.isEmpty ? 0 : 1)
                }
                .padding()
                .background(Color.white)
            
            // Content
            if conversations.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text("No chats yet..")
                        .font(.system(size: 24, weight: .medium))
                    
                    Text("Start conversation")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(conversations) { conversation in
                            ConversationBubble(conversation: conversation)
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
                    
                    Text("Speak up...")
                        .font(.system(size: 20, weight: .medium))
                }
                .padding(30)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
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
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.blue)
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
            .background(Color.gray.opacity(0.1))
        }
        }
        .alert("Потрібен доступ до мікрофона", isPresented: $showPermissionAlert) {
            Button("Відкрити Налаштування", action: openSettings)
            Button("Скасувати", role: .cancel) { }
        } message: {
            Text("Будь ласка, увімкніть доступ до мікрофона в Налаштуваннях для використання голосового перекладу.")
        }
        .onAppear {
            requestPermissions()
            loadLanguageSettings()
        }
    }
    
    private func startRecording(side: ConversationSide) {
        print("🎤 Starting recording for side: \(side)")
        
        Task {
            do {
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
            } catch {
                print("💥 Error in startRecording: \(error)")
                await MainActor.run {
                    isRecording = false
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
    
    private func addConversation(text: String, side: ConversationSide, isTranslation: Bool = false) {
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
            timestamp: Date()
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
                let translator = GoogleTranslateParser()
                let translated = try await translator.translate(text: text, from: from, to: to)
                
                await MainActor.run {
                    // Add translation on opposite side
                    let translationSide: ConversationSide = originalSide == .left ? .right : .left
                    print("➕ Adding translation: '\(translated)' for side: \(translationSide)")
                    addConversation(text: translated, side: translationSide, isTranslation: true)
                    
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
        if let savedSourceLanguage = preferences.string(forKey: "defaultSourceLanguage"),
           savedSourceLanguage != "auto" { // VoiceChat не підтримує auto-detect
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
                        .fill(isRecording ? Color.red : (side == .left ? Color.blue : Color.green))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
            }
            
            Menu {
                Button("🇬🇧 English") { language = "en-US" }
                Button("🇺🇦 Ukrainian") { language = "uk-UA" }
                Button("🇷🇺 Russian") { language = "ru-RU" }
                Button("🇪🇸 Spanish") { language = "es-ES" }
                Button("🇫🇷 French") { language = "fr-FR" }
                Button("🇩🇪 German") { language = "de-DE" }
            } label: {
                HStack {
                    Text(getFlag(for: language))
                    Text(getLanguageName(for: language))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                }
                .font(.system(size: 14))
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(15)
            }
        }
    }
    
    private func getFlag(for languageCode: String) -> String {
        switch languageCode {
        case "en-US", "en": return "🇬🇧"
        case "uk-UA", "uk": return "🇺🇦"
        case "ru-RU", "ru": return "🇷🇺"
        case "es-ES", "es": return "🇪🇸"
        case "fr-FR", "fr": return "🇫🇷"
        case "de-DE", "de": return "🇩🇪"
        default: return "🌐"
        }
    }
    
    private func getLanguageName(for languageCode: String) -> String {
        switch languageCode {
        case "en-US", "en": return "English"
        case "uk-UA", "uk": return "Ukrainian"
        case "ru-RU", "ru": return "Russian"
        case "es-ES", "es": return "Spanish"
        case "fr-FR", "fr": return "French"
        case "de-DE", "de": return "German"
        default: return "Unknown"
        }
    }
}

struct ConversationBubble: View {
    let conversation: VoiceConversation
    
    var body: some View {
        HStack {
            if conversation.side == .right {
                Spacer()
            }
            
            VStack(alignment: conversation.side == .left ? .leading : .trailing, spacing: 4) {
                Text(conversation.text)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        conversation.side == .left ? Color.blue : Color.green
                    )
                    .cornerRadius(20)
                
                Text(conversation.timestamp, style: .time)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
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
        let timeoutTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            print("⏰ Speech recognition timeout - capturing partial result")
            self.stopRecording()
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
                        let newTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                            print("⏰ Using partial result: '\(lastPartialText)'")
                            self.stopRecording()
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
        do {
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
                self?.recognitionRequest?.append(buffer)
            }
            print("✅ Audio tap installed")
        } catch {
            print("❌ Error installing audio tap: \(error)")
            completion(nil)
            return
        }
        
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
                    color: recordingSide == .left ? Color.blue : Color.green
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

#Preview {
    VoiceChatView()
}