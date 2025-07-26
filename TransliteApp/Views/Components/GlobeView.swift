import SwiftUI

struct GlobeView: View {
    @State private var rotationAngle: Double = 0
    @State private var starsOpacity: Double = 0
    @State private var globeScale: CGFloat = 0.8
    
    var body: some View {
        ZStack {
            // Animated background stars
            ForEach(0..<15, id: \.self) { index in
                Circle()
                    .fill(AppColors.buttonText)
                    .frame(width: CGFloat.random(in: 2...4), height: CGFloat.random(in: 2...4))
                    .position(
                        x: CGFloat.random(in: 50...350),
                        y: CGFloat.random(in: 50...150)
                    )
                    .opacity(starsOpacity)
                    .scaleEffect(CGFloat.random(in: 0.5...1.5))
                    .animation(.easeInOut(duration: Double.random(in: 2...4)).repeatForever(autoreverses: true).delay(Double.random(in: 0...2)), value: starsOpacity)
            }
            
            // Glowing effect behind planet
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            AppColors.appAccent.opacity(0.3),
                            AppColors.appAccent.opacity(0.1),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 100,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .scaleEffect(globeScale)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: globeScale)
            
            // Main planet with rotation
            Image("Planet")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(rotationAngle))
                .mask(
                    Rectangle()
                        .frame(width: 400, height: 200)
                        .offset(y: -60)
                )
                .shadow(color: AppColors.shadow.opacity(0.2), radius: 20, x: 0, y: 10)
                .scaleEffect(globeScale)
            
            // Floating particles
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(AppColors.appAccent.opacity(0.6))
                    .frame(width: 3, height: 3)
                    .position(
                        x: 200 + cos(Double(index) * 0.785 + rotationAngle * 0.01) * 120,
                        y: 100 + sin(Double(index) * 0.785 + rotationAngle * 0.01) * 60
                    )
                    .opacity(starsOpacity * 0.7)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 100).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            
            withAnimation(.easeInOut(duration: 1.5)) {
                starsOpacity = 1.0
                globeScale = 1.0
            }
        }
    }
}

#Preview {
    GlobeView()
        .frame(height: 200)
}
