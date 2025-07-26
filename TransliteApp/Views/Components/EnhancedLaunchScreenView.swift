import SwiftUI

struct EnhancedLaunchScreenView: View {
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0.0
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var showText = false
    @State private var textOffset: CGFloat = 30
    @State private var showParticles = false
    @State private var particleOffset: [CGFloat] = Array(repeating: 0, count: 8)
    @State private var loadingProgress: CGFloat = 0.0
    @State private var showProgressBar = false
    
    var onAnimationComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Dynamic gradient background
            RadialGradient(
                gradient: Gradient(colors: [
                    AppColors.appAccent.opacity(0.3),
                    AppColors.appBackground,
                    AppColors.appAccent.opacity(0.1)
                ]),
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
            .ignoresSafeArea()
            .opacity(isAnimating ? 1.0 : 0.8)
            
            // Floating particles
            if showParticles {
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(AppColors.appAccent.opacity(0.6))
                        .frame(width: 4, height: 4)
                        .offset(
                            x: cos(Double(index) * .pi / 4) * particleOffset[index] * 2,
                            y: sin(Double(index) * .pi / 4) * particleOffset[index] * 2
                        )
                        .opacity(isAnimating ? 0.8 : 0.0)
                        .scaleEffect(pulseScale * 0.5)
                }
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // Main animated content
                VStack(spacing: 30) {
                    // Enhanced animated globe
                    ZStack {
                        // Background glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        AppColors.appAccent.opacity(0.4),
                                        AppColors.appAccent.opacity(0.0)
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)
                            .scaleEffect(pulseScale)
                            .opacity(isAnimating ? 0.8 : 0.0)
                        
                        // Multiple orbital rings with different speeds
                        ForEach(0..<4) { index in
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            AppColors.appAccent.opacity(0.6),
                                            AppColors.appAccent.opacity(0.1),
                                            AppColors.appAccent.opacity(0.6)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                                .frame(
                                    width: 120 + CGFloat(index * 25),
                                    height: 120 + CGFloat(index * 25)
                                )
                                .rotationEffect(.degrees(rotationAngle * (1.0 + Double(index) * 0.3)))
                                .opacity(isAnimating ? (0.8 - Double(index) * 0.15) : 0.0)
                        }
                        
                        // Central animated planet using the Planet asset
                        ZStack {
                            // Planet image with enhanced effects
                            Image("Planet")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                                .shadow(
                                    color: AppColors.appAccent.opacity(0.5),
                                    radius: 20,
                                    x: 0,
                                    y: 0
                                )
                                .overlay(
                                    // Glow effect overlay
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    AppColors.appAccent.opacity(0.6),
                                                    Color.clear
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 3
                                        )
                                        .frame(width: 125, height: 125)
                                        .opacity(isAnimating ? 0.8 : 0.0)
                                )
                            
                            // Animated translation symbols orbiting the planet
                            ForEach(0..<6) { index in
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                AppColors.appAccent,
                                                AppColors.appAccent.opacity(0.7)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .rotationEffect(.degrees(Double(index) * 60))
                                    .offset(
                                        x: cos(Double(index) * .pi / 3) * 75,
                                        y: sin(Double(index) * .pi / 3) * 75
                                    )
                                    .opacity(isAnimating ? 0.9 : 0.0)
                                    .scaleEffect(pulseScale * 0.8)
                                    .rotationEffect(.degrees(rotationAngle * 0.7))
                                    .shadow(
                                        color: AppColors.appAccent.opacity(0.3),
                                        radius: 4,
                                        x: 0,
                                        y: 0
                                    )
                            }
                            
                            // Language symbols floating around
                            ForEach(["A", "文", "א", "Я", "ة", "ह"], id: \.self) { symbol in
                                let index = ["A", "文", "א", "Я", "ة", "ह"].firstIndex(of: symbol) ?? 0
                                Text(symbol)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                AppColors.primaryText,
                                                AppColors.appAccent
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .rotationEffect(.degrees(Double(index) * 60))
                                    .offset(
                                        x: cos(Double(index) * .pi / 3) * 100,
                                        y: sin(Double(index) * .pi / 3) * 100
                                    )
                                    .opacity(isAnimating ? 0.7 : 0.0)
                                    .scaleEffect(pulseScale * 0.6)
                                    .rotationEffect(.degrees(-rotationAngle * 0.5)) // Counter rotation
                                    .shadow(
                                        color: AppColors.shadow.opacity(0.3),
                                        radius: 2,
                                        x: 0,
                                        y: 2
                                    )
                            }
                        }
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .rotationEffect(.degrees(rotationAngle * 0.1))
                    }
                    
                    // Enhanced app name and tagline
                    VStack(spacing: 16) {
                        Text("app_name".localized)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        AppColors.primaryText,
                                        AppColors.appAccent
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .opacity(showText ? 1.0 : 0.0)
                            .offset(y: showText ? 0 : textOffset)
                            .scaleEffect(showText ? 1.0 : 0.8)
                        
                        Text("launch_tagline".localized)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppColors.secondaryText)
                            .opacity(showText ? 0.9 : 0.0)
                            .offset(y: showText ? 0 : textOffset)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }
                
                Spacer()
                
                // Enhanced loading section
                VStack(spacing: 20) {
                    // Progress bar
                    if showProgressBar {
                        VStack(spacing: 8) {
                            HStack {
                                Text("loading_text".localized)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.secondaryText)
                                Spacer()
                                Text("\(Int(loadingProgress * 100))%")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(AppColors.appAccent)
                            }
                            
                            ProgressView(value: loadingProgress)
                                .progressViewStyle(LinearProgressViewStyle(tint: AppColors.appAccent))
                                .scaleEffect(y: 1.5)
                        }
                        .padding(.horizontal, 40)
                        .opacity(showProgressBar ? 1.0 : 0.0)
                    }
                    
                    // Animated loading dots
                    HStack(spacing: 12) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(AppColors.appAccent)
                                .frame(width: 10, height: 10)
                                .scaleEffect(pulseScale)
                                .opacity(isAnimating ? 0.8 : 0.3)
                                .animation(
                                    .easeInOut(duration: 0.8)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                    value: pulseScale
                                )
                        }
                    }
                    .opacity(showProgressBar ? 1.0 : 0.0)
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            startEnhancedAnimation()
        }
    }
    
    private func startEnhancedAnimation() {
        // Phase 1: Globe appearance (0-0.8s)
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0)) {
            scale = 1.0
            opacity = 1.0
        }
        
        // Phase 2: Start rotations and particles (0.3s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.linear(duration: 12.0).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.3
                isAnimating = true
            }
            
            // Animate particles
            showParticles = true
            for i in 0..<8 {
                withAnimation(
                    .easeInOut(duration: 3.0)
                    .repeatForever(autoreverses: true)
                    .delay(Double(i) * 0.1)
                ) {
                    particleOffset[i] = 50
                }
            }
        }
        
        // Phase 3: Show text (0.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0)) {
                showText = true
                textOffset = 0
            }
        }
        
        // Phase 4: Show progress bar (1.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showProgressBar = true
            }
            
            // Animate progress
            withAnimation(.easeInOut(duration: 1.5)) {
                loadingProgress = 1.0
            }
        }
        
        // Phase 5: Complete (3.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            onAnimationComplete()
        }
    }
}

struct EnhancedLaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedLaunchScreenView {
            print("Enhanced animation completed")
        }
    }
}