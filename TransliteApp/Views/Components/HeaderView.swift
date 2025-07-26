import SwiftUI

struct HeaderView: View {
    @Binding var showMenu: Bool
    @Binding var isPremium: Bool
    @State private var menuButtonScale: CGFloat = 1.0
    @State private var headerOpacity: Double = 0.0
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    showMenu.toggle()
                }
                
                // Button animation
                withAnimation(.easeInOut(duration: 0.1)) {
                    menuButtonScale = 0.95
                }
                withAnimation(.easeInOut(duration: 0.1).delay(0.1)) {
                    menuButtonScale = 1.0
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.cardBackground)
                        .frame(width: 44, height: 44)
                        .shadow(color: AppColors.shadow, radius: 8, x: 0, y: 2)
                        .shadow(color: AppColors.shadow.opacity(0.5), radius: 1, x: 0, y: 1)
                    
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppColors.appAccent)
                }
                .scaleEffect(menuButtonScale)
            }
            
            Spacer()
            
            Text("app_name".localized)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
                .shadow(color: AppColors.shadow, radius: 1, x: 0, y: 1)
            
            Spacer()
            
            // Premium toggle
            Toggle("", isOn: $isPremium)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: AppColors.successColor))
                .scaleEffect(0.8)
        }
        .opacity(headerOpacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                headerOpacity = 1.0
            }
        }
    }
}

#Preview {
    HeaderView(showMenu: .constant(false), isPremium: .constant(false))
}