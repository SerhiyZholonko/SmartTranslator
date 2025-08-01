import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    // MARK: - Navigation States
    @Published var activeSheet: SheetDestination?
    @Published var activeFullScreenCover: FullScreenDestination?
    @Published var showingSideMenu = false
    
    // MARK: - Singleton
    static let shared = AppCoordinator()
    
    private init() {}
    
    // MARK: - Navigation Methods
    func navigate(to destination: SheetDestination) {
        activeSheet = destination
    }
    
    func presentFullScreen(_ destination: FullScreenDestination) {
        activeFullScreenCover = destination
    }
    
    func dismiss() {
        activeSheet = nil
        activeFullScreenCover = nil
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
}

// MARK: - Navigation Destinations
enum SheetDestination: Identifiable {
    case textTranslator
    case voiceChat
    case cameraTranslator
    case fileTranslator
    case offlineTranslation
    case flashcards
    case history
    case settings
    case addFlashcard(deck: FlashcardDeck?)
    case createDeck
    case studyDeck(deck: FlashcardDeck)
    
    var id: String {
        switch self {
        case .textTranslator: return "textTranslator"
        case .voiceChat: return "voiceChat"
        case .cameraTranslator: return "cameraTranslator"
        case .fileTranslator: return "fileTranslator"
        case .offlineTranslation: return "offlineTranslation"
        case .flashcards: return "flashcards"
        case .history: return "history"
        case .settings: return "settings"
        case .addFlashcard: return "addFlashcard"
        case .createDeck: return "createDeck"
        case .studyDeck: return "studyDeck"
        }
    }
}

enum FullScreenDestination: Identifiable {
    case onboarding
    
    var id: String {
        switch self {
        case .onboarding: return "onboarding"
        }
    }
}

// MARK: - AppCoordinatorView
struct AppCoordinatorView<Content: View>: View {
    @StateObject private var coordinator = AppCoordinator.shared
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .sheet(item: $coordinator.activeSheet) { destination in
                switch destination {
                case .textTranslator:
                    TextTranslatorView()
                case .voiceChat:
                    VoiceChatView()
                case .cameraTranslator:
                    CameraTranslatorView()
                case .fileTranslator:
                    FileTranslatorView()
                case .offlineTranslation:
                    OfflineTranslationView()
                case .flashcards:
                    FlashcardsView()
                case .history:
                    HistoryView()
                case .settings:
                    SettingsView()
                case .addFlashcard(_):
                    EmptyView() // TODO: Fix AddCardView parameters
                case .createDeck:
                    EmptyView() // TODO: CreateDeckView() 
                case .studyDeck(_):
                    EmptyView() // TODO: Fix StudyView parameters
                }
            }
            .fullScreenCover(item: $coordinator.activeFullScreenCover) { destination in
                switch destination {
                case .onboarding:
                    // OnboardingView() // TODO: Create onboarding view
                    EmptyView()
                }
            }
    }
}

// MARK: - View Extension for Navigation
extension View {
    func withAppNavigation() -> some View {
        AppCoordinatorView {
            self
        }
    }
}