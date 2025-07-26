import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0.0
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var showText = false
    @State private var textOpacity: Double = 0.0
    @State private var showDots = false
    @State private var dotsText = ""
    
    var onAnimationComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Gradient background matching app theme
            LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.appBackground,
                    AppColors.appAccent.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Main animated content
                VStack(spacing: 30) {
                    // Animated globe with orbital elements
                    ZStack {
                        // Background pulse
                        Circle()
                            .fill(AppColors.appAccent.opacity(0.1))
                            .frame(width: 200, height: 200)
                            .scaleEffect(pulseScale)
                            .opacity(isAnimating ? 0.6 : 0.0)
                        
                        // Orbital rings
                        ForEach(0..<3) { index in
                            Circle()
                                .stroke(
                                    AppColors.appAccent.opacity(0.3),
                                    lineWidth: 1
                                )
                                .frame(
                                    width: 120 + CGFloat(index * 30),
                                    height: 120 + CGFloat(index * 30)
                                )
                                .rotationEffect(.degrees(rotationAngle + Double(index * 120)))
                                .opacity(isAnimating ? 0.8 : 0.0)
                        }
                        
                        // Central planet using the Planet asset
                        ZStack {
                            // Planet image
                            Image("Planet")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .shadow(
                                    color: AppColors.appAccent.opacity(0.4),
                                    radius: 15,
                                    x: 0,
                                    y: 0
                                )
                            
                            // Translation arrows around planet
                            ForEach(0..<6) { index in
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(AppColors.appAccent)
                                    .rotationEffect(.degrees(Double(index) * 60))
                                    .offset(
                                        x: cos(Double(index) * .pi / 3) * 60,
                                        y: sin(Double(index) * .pi / 3) * 60
                                    )
                                    .opacity(isAnimating ? 0.9 : 0.0)
                                    .rotationEffect(.degrees(rotationAngle * 0.5))
                                    .shadow(
                                        color: AppColors.appAccent.opacity(0.3),
                                        radius: 2,
                                        x: 0,
                                        y: 0
                                    )
                            }
                        }
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .rotationEffect(.degrees(rotationAngle * 0.3))
                    }
                    
                    // App name and tagline
                    VStack(spacing: 12) {
                        Text("app_name".localized)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.primaryText)
                            .opacity(textOpacity)
                        
                        Text("launch_tagline".localized)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.secondaryText)
                            .opacity(textOpacity)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(showText ? 1.0 : 0.0)
                }
                
                Spacer()
                
                // Loading indicator at bottom
                VStack(spacing: 16) {
                    if showDots {
                        Text("loading_text".localized + dotsText)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.secondaryText)
                            .opacity(0.8)
                    }
                    
                    // Progress dots
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(AppColors.appAccent)
                                .frame(width: 8, height: 8)
                                .scaleEffect(pulseScale)
                                .opacity(isAnimating ? 0.8 : 0.3)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                    value: pulseScale
                                )
                        }
                    }
                    .opacity(showDots ? 1.0 : 0.0)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Phase 1: Scale and fade in (0.5s)
        withAnimation(.easeOut(duration: 0.8)) {
            scale = 1.0
            opacity = 1.0
        }
        
        // Phase 2: Start rotation and pulse (1.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.2
                isAnimating = true
            }
        }
        
        // Phase 3: Show text (1.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.6)) {
                showText = true
                textOpacity = 1.0
            }
        }
        
        // Phase 4: Show loading dots (2.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeInOut(duration: 0.4)) {
                showDots = true
            }
            startDotAnimation()
        }
        
        // Phase 5: Complete animation (3.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            onAnimationComplete()
        }
    }
    
    private func startDotAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            switch dotsText.count {
            case 0:
                dotsText = "."
            case 1:
                dotsText = ".."
            case 2:
                dotsText = "..."
            default:
                dotsText = ""
            }
            
            // Stop after animation completes
            if !showDots {
                timer.invalidate()
            }
        }
    }
}

// MARK: - Preview
struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView {
            print("Animation completed")
        }
        .preferredColorScheme(.light)
        
        LaunchScreenView {
            print("Animation completed")
        }
        .preferredColorScheme(.dark)
    }
}