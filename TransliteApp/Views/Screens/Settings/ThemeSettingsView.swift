import SwiftUI

struct ThemeSettingsView: View {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Theme-aware background matching main screen
                AppColors.appBackground
                    .ignoresSafeArea()
                
            Form {
                Section(header: Text("app_theme".localized)) {
                    ForEach(ThemePreference.allCases, id: \.self) { theme in
                        HStack {
                            // Theme icon
                            Image(systemName: themeIcon(for: theme))
                                .foregroundColor(AppColors.dynamicAccent(for: themeManager.currentColorTheme))
                                .frame(width: 24)
                            
                            // Theme name
                            Text(theme.localizedName)
                                .foregroundColor(AppColors.primaryText)
                            
                            Spacer()
                            
                            // Check mark for selected theme
                            if themeManager.currentTheme == theme {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.dynamicAccent(for: themeManager.currentColorTheme))
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                themeManager.setTheme(theme)
                            }
                        }
                    }
                }
                .listRowBackground(AppColors.cardBackground)
                
                Section(header: Text("color_theme".localized)) {
                    VStack(spacing: 8) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                            ForEach(ColorTheme.allCases, id: \.self) { theme in
                                ColorThemeCard(
                                    theme: theme,
                                    isSelected: themeManager.currentColorTheme == theme
                                ) {
                                    themeManager.setColorTheme(theme)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listRowBackground(AppColors.cardBackground)
                
                Section(footer: Text("theme_description".localized)) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(AppColors.dynamicAccent(for: themeManager.currentColorTheme))
                            .frame(width: 24)
                        
                        Text("current_theme_info".localized)
                            .foregroundColor(AppColors.secondaryText)
                            .font(.footnote)
                        
                        Spacer()
                        
                        Text(themeManager.currentTheme.localizedName)
                            .foregroundColor(AppColors.primaryText)
                            .font(.footnote)
                            .fontWeight(.medium)
                    }
                }
                .listRowBackground(AppColors.cardBackground)
            }
            .background(AppColors.appBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("app_theme".localized)
            .navigationBarTitleDisplayMode(.inline)
            }
        }
        .tint(AppColors.dynamicAccent(for: themeManager.currentColorTheme))
    }
    
    private func themeIcon(for theme: ThemePreference) -> String {
        switch theme {
        case .system:
            return "gearshape.2"
        case .light:
            return "sun.max"
        case .dark:
            return "moon"
        }
    }
}

// MARK: - Color Theme Card
struct ColorThemeCard: View {
    let theme: ColorTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Color preview circle
                Circle()
                    .fill(Color(theme.accentColorName))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? AppColors.primaryText : Color.clear, lineWidth: 2)
                    )
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                // Theme name
                Text(theme.localizedName)
                    .font(.caption)
                    .foregroundColor(AppColors.primaryText)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppColors.inputBackground : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.3), value: isSelected)
    }
}

// MARK: - Preview
#Preview {
    ThemeSettingsView()
}