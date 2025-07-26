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
    static let placeholderText = Color("PlaceholderText")
    
    // MARK: - Accent Colors
    static let appAccent = Color("AppAccent")
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