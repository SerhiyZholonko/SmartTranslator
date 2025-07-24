import SwiftUI
import StoreKit

@MainActor
final class SideMenuViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var showHistory = false
    @Published var showSettings = false
    @Published var showOfflineTranslation = false
    @Published var showShareSheet = false
    @Published var shareItems: [Any] = []
    
    // MARK: - Properties
    let menuItems: [MenuItem] = [
        MenuItem(icon: "clock.arrow.circlepath", title: "history", action: .history),
        MenuItem(icon: "square.and.arrow.down", title: "offline_translation", action: .offlineTranslation),
        MenuItem(icon: "gearshape", title: "settings", action: .settings),
        MenuItem(icon: "star", title: "rate_us", action: .rateUs),
        MenuItem(icon: "square.and.arrow.up", title: "share_app", action: .shareApp),
        MenuItem(icon: "envelope", title: "contact_us", action: .contactUs),
        MenuItem(icon: "shield.lefthalf.filled", title: "privacy_policy", action: .privacyPolicy)
    ]
    
    // MARK: - Public Methods
    func handleMenuAction(_ action: MenuAction) {
        switch action {
        case .history:
            showHistory = true
        case .offlineTranslation:
            showOfflineTranslation = true
        case .settings:
            showSettings = true
        case .rateUs:
            requestAppReview()
        case .shareApp:
            shareApp()
        case .contactUs:
            contactSupport()
        case .privacyPolicy:
            openPrivacyPolicy()
        }
    }
    
    // MARK: - Private Methods
    private func requestAppReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    private func shareApp() {
        let appName = "app_name".localized
        let shareText = "share_app_text".localized(with: appName)
        let appStoreURL = URL(string: "https://apps.apple.com/app/id123456789") // TODO: Replace with actual App Store ID
        
        shareItems = [shareText]
        if let url = appStoreURL {
            shareItems.append(url)
        }
        
        showShareSheet = true
    }
    
    private func contactSupport() {
        let email = "support@smarttranslator.app" // TODO: Replace with actual support email
        let subject = "contact_subject".localized(with: "app_name".localized)
        let emailURL = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        
        if let url = emailURL, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showError("cannot_open_email".localized)
        }
    }
    
    private func openPrivacyPolicy() {
        let privacyURL = URL(string: "https://smarttranslator.app/privacy") // TODO: Replace with actual privacy policy URL
        
        if let url = privacyURL, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showError("cannot_open_link".localized)
        }
    }
}

// MARK: - Supporting Types
struct MenuItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let action: MenuAction
}

enum MenuAction {
    case history
    case offlineTranslation
    case settings
    case rateUs
    case shareApp
    case contactUs
    case privacyPolicy
}