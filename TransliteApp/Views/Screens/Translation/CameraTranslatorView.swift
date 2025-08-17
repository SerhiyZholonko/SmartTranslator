import SwiftUI
import AVFoundation
import Vision

struct CameraTranslatorView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var camera = CameraManager()
    @StateObject private var permissionsManager = PermissionsManager.shared
    @StateObject private var translationManager = TranslationManager.shared
    @State private var detectedText = ""
    @State private var translatedText = ""
    @State private var sourceLanguage = "en"
    @State private var targetLanguage = "en"
    @State private var isProcessing = false
    @State private var showTranslation = false
    @State private var showLimitWarning = false
    @State private var limitWarningMessage = ""
    
    var body: some View {
        LocalizedView {
        ZStack {
            // Camera preview
            CameraPreview(camera: camera)
                .ignoresSafeArea()
            
            // Overlay UI
            VStack {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.buttonText)
                            .frame(width: 40, height: 40)
                            .background(AppColors.shadow)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("camera_translator_title".localized)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppColors.buttonText)
                    
                    Spacer()
                    
                    Button(action: { camera.toggleFlash() }) {
                        Image(systemName: camera.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.buttonText)
                            .frame(width: 40, height: 40)
                            .background(AppColors.shadow)
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
                
                // Scanning area indicator
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme), lineWidth: 3)
                    .frame(width: 300, height: 200)
                    .overlay(
                        Text("point_camera_at_text".localized)
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.buttonText)
                            .padding(8)
                            .background(AppColors.shadow)
                            .cornerRadius(8)
                            .offset(y: -120)
                    )
                
                Spacer()
                
                // Translation result overlay
                if showTranslation && !translatedText.isEmpty {
                    VStack(spacing: 12) {
                        Text("detected_text".localized(with: detectedText))
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.buttonText)
                            .padding(.horizontal)
                            .lineLimit(2)
                        
                        Text(translatedText)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.buttonText)
                            .padding()
                            .background(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme))
                            .cornerRadius(12)
                    }
                    .padding()
                    .background(AppColors.shadow)
                    .cornerRadius(15)
                    .padding()
                }
                
                // Bottom controls
                VStack(spacing: 16) {
                    // Language selector
                    HStack(spacing: 20) {
                        LanguagePicker(
                            selectedLanguage: $sourceLanguage,
                            title: "from".localized,
                            includeAuto: true
                        )
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme))
                        
                        LanguagePicker(
                            selectedLanguage: $targetLanguage,
                            title: "to".localized,
                            includeAuto: false
                        )
                    }
                    .padding(.horizontal)
                    
                    // Capture button
                    Button(action: captureAndTranslate) {
                        ZStack {
                            Circle()
                                .fill(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme))
                                .frame(width: 70, height: 70)
                            
                            Circle()
                                .stroke(AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme), lineWidth: 5)
                                .frame(width: 80, height: 80)
                            
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.successColor))
                            } else {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(AppColors.buttonText)
                            }
                        }
                    }
                    .disabled(isProcessing)
                    
                    // AI service usage progress bar
                    if translationManager.currentService == .groqAI {
                        AIUsageProgressView(
                            tokenUsagePercentage: translationManager.groqService.tokenUsagePercentage,
                            style: .overlay
                        )
                        .padding(.horizontal, 60)
                        .padding(.top, 10)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            loadLanguageSettings()
            Task {
                print("📷 CameraTranslatorView appeared")
                let granted = await permissionsManager.requestCameraPermission()
                print("📷 Camera permission granted: \(granted)")
                
                if granted {
                    await camera.setupCameraAsync()
                } else {
                    print("❌ Camera permission denied")
                    camera.showPermissionAlert = true
                }
            }
        }
        .alert("camera_permission_required".localized, isPresented: $camera.showPermissionAlert) {
            Button("open_settings".localized, action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            Button("cancel".localized, role: .cancel) { }
        } message: {
            Text("camera_permission_required_message".localized)
        }
        }
    }
    
    private func captureAndTranslate() {
        isProcessing = true
        showTranslation = false
        
        camera.capturePhoto { image in
            guard let image = image else {
                isProcessing = false
                return
            }
            
            // Perform text recognition
            recognizeText(in: image) { recognizedText in
                guard let text = recognizedText, !text.isEmpty else {
                    isProcessing = false
                    return
                }
                
                detectedText = text
                
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
                            showTranslation = true
                            isProcessing = false
                            
                            // Hide translation after 5 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                withAnimation {
                                    showTranslation = false
                                }
                            }
                        }
                    } catch {
                        print("Translation error: \(error)")
                        isProcessing = false
                    }
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
            
            let fullText = recognizedStrings.joined(separator: " ")
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

struct LanguagePicker: View {
    @Binding var selectedLanguage: String
    let title: String
    let includeAuto: Bool
    
    var languages: [(String, String)] {
        let list = LanguageHelpers.getLanguagesForDisplayWithoutFlags()
        
        if includeAuto {
            // Remove auto-detect option
        }
        
        return list
    }
    
    var body: some View {
        VStack(spacing: 4) {
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
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(getFlag(for: selectedLanguage))
                    Text(languages.first(where: { $0.0 == selectedLanguage })?.1 ?? "")
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                }
                .foregroundColor(AppColors.buttonText)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(AppColors.shadow)
                .cornerRadius(15)
            }
        }
    }
    
    private func getFlag(for languageCode: String) -> String {
        LanguageHelpers.getFlag(for: languageCode)
    }
}

// Camera Manager
@MainActor
class CameraManager: NSObject, ObservableObject {
    @Published var isFlashOn = false
    @Published var showPermissionAlert = false
    @Published var isSetup = false
    
    let session = AVCaptureSession()  // Made public for CameraPreview
    private var videoOutput = AVCaptureVideoDataOutput()
    private var photoOutput = AVCapturePhotoOutput()
    private var captureCompletion: ((UIImage?) -> Void)?
    
    override init() {
        super.init()
        print("📷 CameraManager init")
        // Don't setup camera in init - wait for permissions
    }
    
    func checkPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        print("📷 Camera permission status: \(status)")
        
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            print("📷 Camera permission requested, granted: \(granted)")
            if !granted {
                showPermissionAlert = true
            }
            return granted
        default:
            showPermissionAlert = true
            return false
        }
    }
    
    func setupCameraAsync() async {
        print("📷 Setting up camera...")
        
        guard !isSetup else {
            print("📷 Camera already setup")
            return
        }
        
        // Check permission first
        let hasPermission = await checkPermission()
        guard hasPermission else {
            print("❌ Camera setup failed - no permission")
            return
        }
        
        await setupCameraSync()
    }
    
    private func setupCameraSync() async {
        return await withCheckedContinuation { continuation in
            Task { @MainActor in
                do {
                    print("📷 Configuring camera session...")
                    self.session.beginConfiguration()
                    
                    // Remove existing inputs
                    for input in self.session.inputs {
                        self.session.removeInput(input)
                    }
                    
                    // Remove existing outputs  
                    for output in self.session.outputs {
                        self.session.removeOutput(output)
                    }
                    
                    guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                        print("❌ Could not get camera device")
                        self.session.commitConfiguration()
                        continuation.resume()
                        return
                    }
                    
                    print("📷 Camera device found: \(device.localizedName)")
                    
                    let input = try AVCaptureDeviceInput(device: device)
                    
                    if self.session.canAddInput(input) {
                        self.session.addInput(input)
                        print("✅ Camera input added")
                    } else {
                        print("❌ Cannot add camera input")
                        self.session.commitConfiguration()
                        continuation.resume()
                        return
                    }
                    
                    if self.session.canAddOutput(self.photoOutput) {
                        self.session.addOutput(self.photoOutput)
                        print("✅ Photo output added")
                    } else {
                        print("❌ Cannot add photo output")
                    }
                    
                    self.session.commitConfiguration()
                    print("✅ Camera configuration committed")
                    
                    // Start session
                    if !self.session.isRunning {
                        self.session.startRunning()
                        print("✅ Camera session started")
                    }
                    
                    self.isSetup = true
                    print("✅ Camera setup completed")
                    
                } catch {
                    print("❌ Camera setup error: \(error)")
                    self.session.commitConfiguration()
                    
                    self.showPermissionAlert = true
                }
                
                continuation.resume()
            }
        }
    }
    
    func toggleFlash() {
        isFlashOn.toggle()
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        print("📷 Capture photo requested")
        
        guard isSetup && session.isRunning else {
            print("❌ Camera not ready for capture")
            completion(nil)
            return
        }
        
        captureCompletion = completion
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = isFlashOn ? .on : .off
        
        print("📷 Capturing photo with flash: \(isFlashOn)")
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("📷 Photo capture completed")
        
        if let error = error {
            print("❌ Photo capture error: \(error)")
            DispatchQueue.main.async {
                self.captureCompletion?(nil)
            }
            return
        }
        
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            print("❌ Failed to convert photo to image")
            DispatchQueue.main.async {
                self.captureCompletion?(nil)
            }
            return
        }
        
        print("✅ Photo captured successfully")
        DispatchQueue.main.async {
            self.captureCompletion?(image)
        }
    }
}

// Camera Preview
struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: camera.session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    CameraTranslatorView()
}