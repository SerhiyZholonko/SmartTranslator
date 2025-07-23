import SwiftUI

struct FeatureCard: View {
    let feature: FeatureType
    let isPremium: Bool
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
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 20)
                
                // Enhanced AD badge for premium features
                if feature.requiresPremium && !isPremium {
                    VStack {
                        
                        HStack {
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 9))
                                Text("PRO")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.green, Color.green.opacity(0.5)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .orange.opacity(0.4), radius: 4, x: 0, y: 2)
                        }
                        Spacer()
                    }
                    .padding(6)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(isPressed ? 0.15 : 0.12), radius: isPressed ? 6 : 12, x: 0, y: isPressed ? 2 : 6)
                    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
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
        isPremium: false,
        action: {}
    )
}
