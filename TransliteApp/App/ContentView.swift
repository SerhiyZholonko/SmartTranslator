import SwiftUI

struct ContentView: View {
    @State private var showingSideMenu = false
    @State private var selectedFeature: FeatureType?
    @State private var isPremium = false
    @State private var showPremiumScreen = false
    @State private var path = NavigationPath()
    
    var body: some View {
        LocalizedView {
        NavigationStack(path: $path) {
            ZStack {
                // Enhanced gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.98, green: 0.98, blue: 1.0),
                        Color(red: 0.95, green: 0.96, blue: 0.99),
                        Color(red: 0.93, green: 0.94, blue: 0.98)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Main content
                VStack(spacing: 0) {
                    // Header
                    HeaderView(showMenu: $showingSideMenu, isPremium: $isPremium)
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
                                isPremium: isPremium,
                                action: { selectedFeature = .textTranslator }
                            )
                            
                            FeatureCard(
                                feature: .voiceChat,
                                isPremium: isPremium,
                                action: { selectedFeature = .voiceChat }
                            )
                        }
                        
                        HStack(spacing: 20) {
                            FeatureCard(
                                feature: .cameraTranslator,
                                isPremium: isPremium,
                                action: { selectedFeature = .cameraTranslator }
                            )
                            
                            FeatureCard(
                                feature: .fileTranslator,
                                isPremium: isPremium,
                                action: { selectedFeature = .fileTranslator }
                            )
                        }
                    }
                    .padding(.horizontal, 25)
                    
                    Spacer()
                }
                
                // Side menu overlay
                if showingSideMenu {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showingSideMenu = false
                            }
                        }
                }
                
                // Side menu
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        SideMenuView(
                            isShowing: $showingSideMenu,
                            isPremium: $isPremium,
                            showPremiumScreen: $showPremiumScreen
                        )
                        .frame(width: geometry.size.width * 0.75)
                        .offset(x: showingSideMenu ? 0 : -geometry.size.width)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showingSideMenu)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showPremiumScreen) {
                PremiumView(isPremium: $isPremium)
            }
            .fullScreenCover(item: $selectedFeature) { feature in
                switch feature {
                case .textTranslator:
                    TextTranslatorView()
                case .voiceChat:
                    VoiceChatView()
                case .cameraTranslator:
                    if isPremium {
                        CameraTranslatorView()
                    } else {
                        PremiumView(isPremium: $isPremium)
                    }
                case .fileTranslator:
                    if isPremium {
                        FileTranslatorView()
                    } else {
                        PremiumView(isPremium: $isPremium)
                    }
                }
            }
        }
        }
    }
}

#Preview {
    ContentView()
}