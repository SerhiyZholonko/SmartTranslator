import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @StateObject private var coordinator = AppCoordinator.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        LocalizedView {
        NavigationStack {
            ZStack {
                // Theme-aware background
                AppColors.appBackground
                    .ignoresSafeArea()
                
                // Main content
                VStack(spacing: 0) {
                    // Header
                    HeaderView(showMenu: $viewModel.showingSideMenu, isPremium: $viewModel.isPremium)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    // Globe illustration with stars
                    GlobeView()
                        .frame(height: 200)
                        .padding(.top, 60)
                        .padding(.bottom, -40)
                    
                    // Feature cards
                    VStack(spacing: 20) {
                        HStack(spacing: 20) {
                            FeatureCard(
                                feature: .textTranslator,
                                isPremium: viewModel.isPremium,
                                action: { viewModel.selectFeature(.textTranslator) }
                            )
                            
                            FeatureCard(
                                feature: .voiceChat,
                                isPremium: viewModel.isPremium,
                                action: { viewModel.selectFeature(.voiceChat) }
                            )
                        }
                        
                        HStack(spacing: 20) {
                            FeatureCard(
                                feature: .cameraTranslator,
                                isPremium: viewModel.isPremium,
                                action: { viewModel.selectFeature(.cameraTranslator) }
                            )
                            
                            FeatureCard(
                                feature: .fileTranslator,
                                isPremium: viewModel.isPremium,
                                action: { viewModel.selectFeature(.fileTranslator) }
                            )
                        }
                    }
                    .padding(.horizontal, 25)
                    
                    Spacer()
                }
                
                // Side menu overlay
                if viewModel.showingSideMenu {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewModel.closeSideMenu()
                        }
                }
                
                // Side menu
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        SideMenuView(
                            isShowing: $viewModel.showingSideMenu,
                            isPremium: $viewModel.isPremium,
                            showPremiumScreen: $viewModel.showPremiumScreen
                        )
                        .frame(width: geometry.size.width * 0.75)
                        .offset(x: viewModel.showingSideMenu ? 0 : -geometry.size.width)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.showingSideMenu)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showPremiumScreen) {
                PremiumView()
            }
            .sheet(isPresented: $viewModel.showTextTranslator) {
                TextTranslatorView()
            }
            .sheet(isPresented: $viewModel.showVoiceChat) {
                VoiceChatView()
            }
            .sheet(isPresented: $viewModel.showCameraTranslator) {
                CameraTranslatorView()
            }
            .sheet(isPresented: $viewModel.showFileTranslator) {
                FileTranslatorView()
            }
        }
        .themeAware()
        }
    }
}

#Preview {
    ContentView()
}