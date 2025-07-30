import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HeaderView(showMenu: .constant(false), isPremium: $viewModel.isPremium)
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
    }
}

#Preview {
    HomeView(viewModel: ContentViewModel())
}