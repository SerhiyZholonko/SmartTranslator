import SwiftUI

struct FeatureCard: View {
    let feature: FeatureType
    let action: () -> Void
    @State private var isPressed = false
    @State private var hasAppeared = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                VStack(spacing: 12) {
                    // Icon container with enhanced shadow
                    if feature.isTextIcon {
                        // Special T icon for Text Translator with circular design
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            feature.iconBackgroundColor.opacity(0.1),
                                            feature.iconBackgroundColor.opacity(0.05)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 64, height: 64)
                            
                            Text("T")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(feature.iconBackgroundColor)
                        }
                    } else {
                        // Use image from assets with enhanced styling
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            feature.iconBackgroundColor.opacity(0.1),
                                            feature.iconBackgroundColor.opacity(0.05)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 64, height: 64)
                            
                            Image(feature.icon)
                                .resizable()
                                .renderingMode(.template)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                                .foregroundColor(feature.iconBackgroundColor)
                        }
                    }
                    
                    Text(feature.localizedTitle)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppColors.primaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 20)
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.cardBackground)
                    .shadow(color: AppColors.shadow.opacity(isPressed ? 0.2 : 0.15), radius: isPressed ? 6 : 12, x: 0, y: isPressed ? 2 : 6)
                    .shadow(color: AppColors.shadow.opacity(0.05), radius: 1, x: 0, y: 1)
            )
            .scaleEffect(isPressed ? 0.98 : (hasAppeared ? 1.0 : 0.8))
            .opacity(hasAppeared ? 1.0 : 0.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double.random(in: 0...0.3))) {
                hasAppeared = true
            }
        }
    }
}

#Preview {
    FeatureCard(
        feature: .textTranslator,
        action: {}
    )
}
