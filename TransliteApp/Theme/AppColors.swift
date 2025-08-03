import SwiftUI

// MARK: - App Colors Helper
struct AppColors {
    // MARK: - Background Colors
    static let appBackground = Color("AppBackground")
    static let secondaryBackground = Color("SecondaryBackground")
    static let tertiaryBackground = Color("TertiaryBackground")
    static let cardBackground = Color("CardBackground")
    
    // MARK: - Text Colors
    static let primaryText = Color("PrimaryText")
    static let secondaryText = Color("SecondaryText")
    static let tertiaryText = Color("TertiaryText")
    static let placeholderText = Color("AppTextPlaceholder")
    
    // MARK: - Dynamic Accent Colors
    static func dynamicAccent(for theme: ColorTheme) -> Color {
        Color(theme.accentColorName)
    }
    
    // MARK: - Static Accent Colors (default blue)
    static let appAccent = Color("AppAccent")
    
    // MARK: - Static Colors
    static let secondaryAccent = Color("SecondaryAccent")
    static let successColor = Color("SuccessColor")
    static let warningColor = Color("WarningColor")
    static let errorColor = Color("ErrorColor")
    
    // MARK: - Component Colors
    static let buttonBackground = Color("ButtonBackground")
    static let buttonText = Color("ButtonText")
    static let inputBackground = Color("InputBackground")
    static let inputBorder = Color("InputBorder")
    static let divider = Color("Divider")
    static let shadow = Color("Shadow")
    
    // MARK: - Feature Colors
    static let premiumGradientStart = Color("PremiumGradientStart")
    static let premiumGradientEnd = Color("PremiumGradientEnd")
    static let translationBackground = Color("TranslationBackground")
    static let translationBorder = Color("TranslationBorder")
    
    // MARK: - Navigation Colors
    static let navigationBackground = Color("NavigationBackground")
    static let navigationTint = Color("NavigationTint")
    static let tabBarBackground = Color("TabBarBackground")
    static let tabBarTint = Color("TabBarTint")
}

// MARK: - Gradient Extensions
extension LinearGradient {
    static var appGradient: LinearGradient {
        LinearGradient(
            colors: [AppColors.appAccent, AppColors.secondaryAccent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var premiumGradient: LinearGradient {
        LinearGradient(
            colors: [AppColors.premiumGradientStart, AppColors.premiumGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [AppColors.cardBackground, AppColors.secondaryBackground],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Dynamic Color View Modifier
struct DynamicAccentColorModifier: ViewModifier {
    @ObservedObject private var themeManager = ThemeManager.shared
    
    func body(content: Content) -> some View {
        content
            .accentColor(AppColors.dynamicAccent(for: themeManager.currentColorTheme))
    }
}

extension View {
    func dynamicAccentColor() -> some View {
        modifier(DynamicAccentColorModifier())
    }
}