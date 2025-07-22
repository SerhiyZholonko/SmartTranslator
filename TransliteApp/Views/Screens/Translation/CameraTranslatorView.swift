import SwiftUI
import AVFoundation
import Vision

struct CameraTranslatorView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var camera = CameraManager()
    @StateObject private var permissionsManager = PermissionsManager.shared
    @State private var detectedText = ""
    @State private var translatedText = ""
    @State private var sourceLanguage = "auto"
    @State private var targetLanguage = "en"
    @State private var isProcessing = false
    @State private var showTranslation = false
    
    var body: some View {
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
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Camera Translator")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { camera.toggleFlash() }) {
                        Image(systemName: camera.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
                
                // Scanning area indicator
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.green, lineWidth: 3)
                    .frame(width: 300, height: 200)
                    .overlay(
                        Text("Point camera at text")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(8)
                            .offset(y: -120)
                    )
                
                Spacer()
                
                // Translation result overlay
                if showTranslation && !translatedText.isEmpty {
                    VStack(spacing: 12) {
                        Text("Detected: \(detectedText)")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .lineLimit(2)
                        
                        Text(translatedText)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(15)
                    .padding()
                }
                
                // Bottom controls
                VStack(spacing: 16) {
                    // Language selector
                    HStack(spacing: 20) {
                        LanguagePicker(
                            selectedLanguage: $sourceLanguage,
                            title: "From",
                            includeAuto: true
                        )
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                        
                        LanguagePicker(
                            selectedLanguage: $targetLanguage,
                            title: "To",
                            includeAuto: false
                        )
                    }
                    .padding(.horizontal)
                    
                    // Capture button
                    Button(action: captureAndTranslate) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                            
                            Circle()
                                .stroke(Color.white, lineWidth: 5)
                                .frame(width: 80, height: 80)
                            
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .green))
                            } else {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .disabled(isProcessing)
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
        .alert("Потрібен доступ до камери", isPresented: $camera.showPermissionAlert) {
            Button("Відкрити Налаштування", action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            Button("Скасувати", role: .cancel) { }
        } message: {
            Text("Будь ласка, увімкніть доступ до камери в Налаштуваннях для використання перекладу через камеру.")
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
                        let translator = GoogleTranslateParser()
                        let translated = try await translator.translate(
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
        request.recognitionLanguages = ["en", "uk", "ru", "es", "fr", "de"]
        
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
        var list = [
            ("en", "English"),
            ("uk", "Ukrainian"),
            ("ru", "Russian"),
            ("es", "Spanish"),
            ("fr", "French"),
            ("de", "German")
        ]
        
        if includeAuto {
            list.insert(("auto", "Auto"), at: 0)
        }
        
        return list
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
            
            Menu {
                ForEach(languages, id: \.0) { language in
                    Button(action: {
                        selectedLanguage = language.0
                    }) {
                        Text(language.1)
                    }
                }
            } label: {
                HStack {
                    Text(languages.first(where: { $0.0 == selectedLanguage })?.1 ?? "")
                        .font(.system(size: 14))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.5))
                .cornerRadius(15)
            }
        }
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
            DispatchQueue.global(qos: .userInitiated).async {
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
                    
                    DispatchQueue.main.async {
                        self.isSetup = true
                        print("✅ Camera setup completed")
                    }
                    
                } catch {
                    print("❌ Camera setup error: \(error)")
                    self.session.commitConfiguration()
                    
                    DispatchQueue.main.async {
                        self.showPermissionAlert = true
                    }
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
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
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