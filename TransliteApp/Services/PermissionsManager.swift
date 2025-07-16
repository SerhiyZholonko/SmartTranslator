import Foundation
import AVFoundation
import Speech
import Photos
import UIKit

@MainActor
class PermissionsManager: ObservableObject {
    static let shared = PermissionsManager()
    
    @Published var cameraPermission: PermissionStatus = .notDetermined
    @Published var microphonePermission: PermissionStatus = .notDetermined
    @Published var speechRecognitionPermission: PermissionStatus = .notDetermined
    @Published var photoLibraryPermission: PermissionStatus = .notDetermined
    
    enum PermissionStatus {
        case notDetermined
        case granted
        case denied
        case restricted
    }
    
    private init() {
        checkAllPermissions()
    }
    
    func checkAllPermissions() {
        checkCameraPermission()
        checkMicrophonePermission()
        checkSpeechRecognitionPermission()
        checkPhotoLibraryPermission()
    }
    
    // MARK: - Camera Permission
    
    func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        cameraPermission = convertAVAuthorizationStatus(status)
    }
    
    func requestCameraPermission() async -> Bool {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        cameraPermission = granted ? .granted : .denied
        return granted
    }
    
    // MARK: - Microphone Permission
    
    func checkMicrophonePermission() {
        if #available(iOS 17.0, *) {
            let status = AVCaptureDevice.authorizationStatus(for: .audio)
            microphonePermission = convertAVAuthorizationStatus(status)
        } else {
            let status = AVAudioSession.sharedInstance().recordPermission
            microphonePermission = convertAVAudioSessionRecordPermission(status)
        }
    }
    
    func requestMicrophonePermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            if #available(iOS 17.0, *) {
                // Use newer API for iOS 17+
                AVCaptureDevice.requestAccess(for: .audio) { granted in
                    Task { @MainActor in
                        self.microphonePermission = granted ? .granted : .denied
                    }
                    continuation.resume(returning: granted)
                }
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    Task { @MainActor in
                        self.microphonePermission = granted ? .granted : .denied
                    }
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    // MARK: - Speech Recognition Permission
    
    func checkSpeechRecognitionPermission() {
        let status = SFSpeechRecognizer.authorizationStatus()
        speechRecognitionPermission = convertSFSpeechRecognizerAuthorizationStatus(status)
    }
    
    func requestSpeechRecognitionPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                Task { @MainActor in
                    self.speechRecognitionPermission = self.convertSFSpeechRecognizerAuthorizationStatus(status)
                }
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    // MARK: - Photo Library Permission
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        photoLibraryPermission = convertPHAuthorizationStatus(status)
    }
    
    func requestPhotoLibraryPermission() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        photoLibraryPermission = convertPHAuthorizationStatus(status)
        return status == .authorized || status == .limited
    }
    
    // MARK: - Helper Methods
    
    private func convertAVAuthorizationStatus(_ status: AVAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined: return .notDetermined
        case .authorized: return .granted
        case .denied: return .denied
        case .restricted: return .restricted
        @unknown default: return .notDetermined
        }
    }
    
    private func convertAVAudioSessionRecordPermission(_ permission: AVAudioSession.RecordPermission) -> PermissionStatus {
        switch permission {
        case .undetermined: return .notDetermined
        case .granted: return .granted
        case .denied: return .denied
        @unknown default: return .notDetermined
        }
    }
    
    private func convertSFSpeechRecognizerAuthorizationStatus(_ status: SFSpeechRecognizerAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined: return .notDetermined
        case .authorized: return .granted
        case .denied: return .denied
        case .restricted: return .restricted
        @unknown default: return .notDetermined
        }
    }
    
    private func convertPHAuthorizationStatus(_ status: PHAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined: return .notDetermined
        case .authorized, .limited: return .granted
        case .denied: return .denied
        case .restricted: return .restricted
        @unknown default: return .notDetermined
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}