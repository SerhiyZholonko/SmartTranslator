import SwiftUI

struct ThemePreviewView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Theme Preview")
                .font(.title)
                .foregroundColor(AppColors.primaryText)
            
            // Show current theme colors
            VStack(spacing: 12) {
                HStack {
                    Text("Current Theme:")
                    Text(themeManager.currentColorTheme.localizedName)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.dynamicAccent(for: themeManager.currentColorTheme))
                }
                
                // Color preview
                AppColors.dynamicAccent(for: themeManager.currentColorTheme)
                    .frame(height: 60)
                    .cornerRadius(12)
                    .overlay(
                        Text("Accent Color")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    )
            }
            
            // Theme selector buttons
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(ColorTheme.allCases, id: \.self) { theme in
                    Button(action: {
                        withAnimation(.spring()) {
                            themeManager.setColorTheme(theme)
                        }
                    }) {
                        HStack {
                            Circle()
                                .fill(AppColors.dynamicAccent(for: theme))
                                .frame(width: 20, height: 20)
                            
                            Text(theme.localizedName)
                                .foregroundColor(AppColors.primaryText)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(themeManager.currentColorTheme == theme ? 
                                      AppColors.secondaryBackground : AppColors.cardBackground)
                        )
                    }
                }
            }
        }
        .padding()
        .background(AppColors.appBackground)
        .dynamicAccentColor()
    }
}

#Preview {
    ThemePreviewView()
}