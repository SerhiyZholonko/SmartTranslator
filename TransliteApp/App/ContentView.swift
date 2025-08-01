import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @StateObject private var coordinator = AppCoordinator.shared
    @StateObject private var themeManager = ThemeManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        LocalizedView {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Theme-aware background
                AppColors.appBackground
                    .ignoresSafeArea()
                
                // Tab content based on selection
                switch viewModel.selectedTab {
                case .home:
                    HomeView(viewModel: viewModel)
                case .flashcards:
                    FlashcardsView()
                case .history:
                    HistoryView()
                case .settings:
                    SettingsView()
                }
                
                // Custom TabBar
                CustomTabBar(selectedTab: $viewModel.selectedTab)
                    .ignoresSafeArea(.keyboard)
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $viewModel.showTextTranslator) {
                TextTranslatorView()
            }
            .fullScreenCover(isPresented: $viewModel.showVoiceChat) {
                VoiceChatView()
            }
            .fullScreenCover(isPresented: $viewModel.showCameraTranslator) {
                CameraTranslatorView()
            }
            .fullScreenCover(isPresented: $viewModel.showFileTranslator) {
                FileTranslatorView()
            }
            .sheet(isPresented: $viewModel.showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $viewModel.showFlashcards) {
                FlashcardsView()
            }
        }
        .themeAware()
        }
    }
}

#Preview {
    ContentView()
}