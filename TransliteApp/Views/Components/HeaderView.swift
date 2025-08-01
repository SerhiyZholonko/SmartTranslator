import SwiftUI

struct HeaderView: View {
    @Binding var showMenu: Bool
    @State private var menuButtonScale: CGFloat = 1.0
    @State private var headerOpacity: Double = 0.0
    
    var body: some View {
        HStack {
            Spacer()
            
            Text("app_name".localized)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
                .shadow(color: AppColors.shadow, radius: 1, x: 0, y: 1)
            
            Spacer()
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
    HeaderView(showMenu: .constant(false))
}