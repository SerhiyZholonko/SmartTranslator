import SwiftUI
import Combine

@MainActor
final class ContentViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var showingSideMenu = false
    @Published var selectedFeature: FeatureType?
    @Published var isPremium = false
    @Published var showPremiumScreen = false
    
    // MARK: - Navigation States
    @Published var showTextTranslator = false
    @Published var showVoiceChat = false
    @Published var showCameraTranslator = false
    @Published var showFileTranslator = false
    
    // MARK: - Services
    private let premiumManager = PremiumManager.shared
    
    override init() {
        super.init()
        setupBindings()
        checkPremiumStatus()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Observe premium status changes
        premiumManager.$isPremium
            .assign(to: &$isPremium)
        
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
        if feature.requiresPremium && !isPremium {
            showPremiumScreen = true
        } else {
            selectedFeature = feature
        }
    }
    
    func toggleSideMenu() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showingSideMenu.toggle()
        }
    }
    
    func closeSideMenu() {
        withAnimation {
            showingSideMenu = false
        }
    }
    
    func openPremiumScreen() {
        showPremiumScreen = true
        closeSideMenu()
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
    
    private func checkPremiumStatus() {
        Task {
            await premiumManager.checkPremiumStatus()
        }
    }
}

// MARK: - Premium Manager (Temporary)
@MainActor
class PremiumManager: ObservableObject {
    static let shared = PremiumManager()
    
    @Published var isPremium = false
    
    private init() {}
    
    func checkPremiumStatus() async {
        // TODO: Implement actual premium check with StoreKit
        // For now, just return false
        isPremium = false
    }
    
    func purchasePremium() async throws {
        // TODO: Implement StoreKit purchase
        // For now, just set to true for testing
        isPremium = true
    }
}