import SwiftUI
import StoreKit

struct PremiumView: View {
    @StateObject private var viewModel = PremiumViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        LocalizedView {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    .blue,
                    .blue.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                
                // Globe illustrations with stars
                GeometryReader { geometry in
                    ZStack {
                        // Stars background
                        ForEach(0..<15) { _ in
                            Circle()
                                .fill(Color.white.opacity(Double.random(in: 0.3...0.7)))
                                .frame(width: CGFloat.random(in: 2...4))
                                .position(
                                    x: CGFloat.random(in: 50...geometry.size.width - 50),
                                    y: CGFloat.random(in: 0...200)
                                )
                        }
                        
                        // Left planet - притиснута до лівого краю
                        Image("planetLeftPS")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(0.7)
                            .frame(
                                width: geometry.size.width * 0.35, // 35% від ширини екрану
                                height: geometry.size.width * 0.35
                            )
                            .position(
                                x: (geometry.size.width * 0.35) / 2 - 20, // Половина ширини планети
                                y: geometry.size.height * 0.3
                            )

                        // Right planet - притиснута до правого краю
                        Image("PlanetRightPS")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(0.7)
                            .frame(
                                width: geometry.size.width * 0.2, // 20% від ширини екрану
                                height: geometry.size.width * 0.2
                            )
                            .position(
                                x: geometry.size.width - (geometry.size.width * 0.2) / 2 + 10, // Ширина екрану мінус половина ширини планети
                                y: geometry.size.height * 0.7
                            )
                    }
                }
                .frame(height: 250) // Фіксована висота для секції з планетами
                
                // Premium badge
                Text("lifetime_premium".localized)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.green)
                    .padding(.top, 30)
                
                // Features list
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(text: "premium_no_ads_full".localized)
                    FeatureRow(text: "premium_faster_translation".localized)
                    FeatureRow(text: "premium_unlimited_camera".localized)
                    FeatureRow(text: "premium_unlimited_photo".localized)
                }
                .padding(.horizontal, 50)
                .padding(.vertical, 40)
                
                Spacer()
                
                // Purchase button
                Button(action: {
                    if let selectedProduct = viewModel.selectedProduct {
                        viewModel.purchase(selectedProduct)
                    }
                }) {
                    if viewModel.isPurchasing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("get_premium_for_price".localized)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.green)
                .cornerRadius(28)
                .padding(.horizontal, 35)
                .disabled(viewModel.isPurchasing)
                
                // Restore purchase button
                Button(action: {
                    viewModel.restorePurchases()
                }) {
                    Text("restore_purchase".localized)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.vertical, 20)
            }
        }
        }
    }
}

struct FeatureRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "checkmark")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(text)
                .font(.system(size: 17))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

#Preview {
    PremiumView()
}
