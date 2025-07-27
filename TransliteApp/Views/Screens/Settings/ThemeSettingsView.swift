import SwiftUI

struct ThemeSettingsView: View {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationView {
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
                                .foregroundColor(AppColors.appAccent)
                                .frame(width: 24)
                            
                            // Theme name
                            Text(theme.localizedName)
                                .foregroundColor(AppColors.primaryText)
                            
                            Spacer()
                            
                            // Check mark for selected theme
                            if themeManager.currentTheme == theme {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.appAccent)
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
                
                Section(footer: Text("theme_description".localized)) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(AppColors.appAccent)
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
        .tint(AppColors.appAccent)
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

// MARK: - Preview
#Preview {
    ThemeSettingsView()
}