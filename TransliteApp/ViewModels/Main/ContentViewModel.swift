import SwiftUI
import Combine
import AVFoundation

@MainActor
final class ContentViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var selectedTab: CustomTabBar.TabItem = .home {
        didSet {
            if oldValue != selectedTab {
                handleTabChange(from: oldValue, to: selectedTab)
            }
        }
    }
    @Published var selectedFeature: FeatureType?
    
    // MARK: - Navigation States
    @Published var showTextTranslator = false
    @Published var showVoiceChat = false
    @Published var showCameraTranslator = false
    @Published var showFileTranslator = false
    @Published var showSettings = false
    @Published var showFlashcards = false
    
    
    override init() {
        super.init()
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Handle feature selection
        $selectedFeature
            .compactMap { $0 }
            .sink { [weak self] feature in
                self?.handleFeatureSelection(feature)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func selectFeature(_ feature: FeatureType) {
        selectedFeature = feature
    }
    
    // MARK: - Private Methods
    private func handleFeatureSelection(_ feature: FeatureType) {
        // Reset all navigation states
        resetNavigationStates()
        
        // Set appropriate navigation state
        switch feature {
        case .textTranslator:
            showTextTranslator = true
        case .voiceChat:
            showVoiceChat = true
        case .cameraTranslator:
            showCameraTranslator = true
        case .fileTranslator:
            showFileTranslator = true
        }
        
        // Clear selection after navigation
        selectedFeature = nil
    }
    
    private func resetNavigationStates() {
        showTextTranslator = false
        showVoiceChat = false
        showCameraTranslator = false
        showFileTranslator = false
    }
    
    private func handleTabChange(from oldTab: CustomTabBar.TabItem, to newTab: CustomTabBar.TabItem) {
        print("🔄 Tab changed from \(oldTab) to \(newTab)")
        
        // Dismiss any open translation views when changing tabs
        if oldTab == .home {
            resetNavigationStates()
            cleanupTranslationViews()
        }
    }
    
    func cleanupTranslationViews() {
        // Stop any ongoing translation tasks
        TranslationManager.shared.isTranslating = false
        
        // Stop any audio sessions
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            print("🔊 Audio session deactivated after translation view")
        } catch {
            print("⚠️ Could not deactivate audio session: \(error)")
        }
        
        // Force garbage collection by clearing references
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Small delay to ensure view cleanup
        }
    }
    
}