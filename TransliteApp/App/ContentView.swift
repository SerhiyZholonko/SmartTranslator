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
                    .onDisappear {
                        // Force cleanup when dismissing translation view
                        viewModel.cleanupTranslationViews()
                    }
            }
            .fullScreenCover(isPresented: $viewModel.showVoiceChat) {
                VoiceChatView()
                    .onDisappear {
                        // Force cleanup when dismissing voice chat view
                        viewModel.cleanupTranslationViews()
                    }
            }
            .fullScreenCover(isPresented: $viewModel.showCameraTranslator) {
                CameraTranslatorView()
                    .onDisappear {
                        // Force cleanup when dismissing camera view
                        viewModel.cleanupTranslationViews()
                    }
            }
            .fullScreenCover(isPresented: $viewModel.showFileTranslator) {
                FileTranslatorView()
                    .onDisappear {
                        // Force cleanup when dismissing file translator view
                        viewModel.cleanupTranslationViews()
                    }
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