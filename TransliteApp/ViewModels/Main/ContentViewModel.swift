import SwiftUI
import Combine

@MainActor
final class ContentViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var selectedTab: CustomTabBar.TabItem = .home
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
    
}