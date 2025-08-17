import SwiftUI

/// Reusable AI usage progress indicator component
struct AIUsageProgressView: View {
    let tokenUsagePercentage: Double
    let style: ProgressStyle
    
    enum ProgressStyle {
        case compact    // Small progress bar for headers
        case standard   // Medium size for general use
        case overlay    // Larger with background for camera overlay
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacingForStyle) {
            HStack(spacing: 6) {
                // AI Icon
                Image(systemName: "brain.head.profile")
                    .font(.system(size: iconSizeForStyle, weight: .medium))
                    .foregroundColor(iconColorForStyle)
                
                Text("AI \("token_usage".localized)")
                    .font(fontForStyle)
                    .fontWeight(.medium)
                    .foregroundColor(textColorForStyle)
                
                Spacer()
                
                // Progress percentage with background
                Text("\(String(format: "%.1f", tokenUsagePercentage))%")
                    .font(percentageFontForStyle)
                    .fontWeight(.semibold)
                    .foregroundColor(percentageTextColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(percentageBackgroundColor)
                    )
            }
            
            // Enhanced Progress bar with border and shadow
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: heightForStyle / 2)
                    .fill(backgroundColorForStyle)
                    .frame(width: widthForStyle, height: heightForStyle)
                    .overlay(
                        RoundedRectangle(cornerRadius: heightForStyle / 2)
                            .stroke(borderColorForStyle, lineWidth: 0.5)
                    )

                // Progress fill
                RoundedRectangle(cornerRadius: heightForStyle / 2)
                    .fill(progressGradient)
                    .frame(
                        width: max(2, CGFloat(tokenUsagePercentage / 100.0) * widthForStyle), 
                        height: heightForStyle
                    )
                    .animation(.easeInOut(duration: 0.4), value: tokenUsagePercentage)
                    .shadow(color: progressShadowColor, radius: 1, x: 0, y: 0.5)
            }
            .shadow(color: AppColors.shadow.opacity(0.1), radius: 1, x: 0, y: 1)
        }
        .padding(.horizontal, paddingForStyle)
        .padding(.vertical, verticalPaddingForStyle)
        .background(containerBackgroundForStyle)
        .cornerRadius(cornerRadiusForStyle)
    }
    
    // MARK: - Style Properties
    
    private var spacingForStyle: CGFloat {
        switch style {
        case .compact: return 2
        case .standard: return 3
        case .overlay: return 4
        }
    }
    
    private var fontForStyle: Font {
        switch style {
        case .compact: return .system(size: 10)
        case .standard: return .system(size: 12)
        case .overlay: return .system(size: 12, weight: .medium)
        }
    }
    
    private var textColorForStyle: Color {
        switch style {
        case .compact, .standard: return AppColors.secondaryText
        case .overlay: return AppColors.buttonText
        }
    }
    
    private var backgroundColorForStyle: Color {
        switch style {
        case .compact, .standard: return AppColors.secondaryText.opacity(0.2)
        case .overlay: return AppColors.shadow.opacity(0.5)
        }
    }
    
    private var widthForStyle: CGFloat {
        switch style {
        case .compact: return 80
        case .standard: return 120
        case .overlay: return 200
        }
    }
    
    private var heightForStyle: CGFloat {
        switch style {
        case .compact: return 4
        case .standard: return 6
        case .overlay: return 8
        }
    }
    
    // New style properties for enhanced design
    
    private var iconSizeForStyle: CGFloat {
        switch style {
        case .compact: return 10
        case .standard: return 12
        case .overlay: return 14
        }
    }
    
    private var iconColorForStyle: Color {
        switch style {
        case .compact, .standard: return AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme)
        case .overlay: return AppColors.buttonText
        }
    }
    
    private var percentageFontForStyle: Font {
        switch style {
        case .compact: return .system(size: 9, weight: .semibold)
        case .standard: return .system(size: 11, weight: .semibold)
        case .overlay: return .system(size: 12, weight: .bold)
        }
    }
    
    private var percentageTextColor: Color {
        return tokenUsagePercentage > 80 ? .white : .white
    }
    
    private var percentageBackgroundColor: Color {
        if tokenUsagePercentage > 80 {
            return .red
        } else if tokenUsagePercentage > 50 {
            return .orange
        } else {
            return AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme)
        }
    }
    
    private var borderColorForStyle: Color {
        switch style {
        case .compact, .standard: return AppColors.secondaryText.opacity(0.3)
        case .overlay: return AppColors.buttonText.opacity(0.3)
        }
    }
    
    private var progressShadowColor: Color {
        if tokenUsagePercentage > 80 {
            return .red.opacity(0.3)
        } else if tokenUsagePercentage > 50 {
            return .orange.opacity(0.3)
        } else {
            return AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme).opacity(0.3)
        }
    }
    
    private var paddingForStyle: CGFloat {
        switch style {
        case .compact: return 6
        case .standard: return 8
        case .overlay: return 10
        }
    }
    
    private var verticalPaddingForStyle: CGFloat {
        switch style {
        case .compact: return 4
        case .standard: return 6
        case .overlay: return 8
        }
    }
    
    private var containerBackgroundForStyle: Color {
        switch style {
        case .compact: return AppColors.inputBackground.opacity(0.5)
        case .standard: return AppColors.cardBackground
        case .overlay: return AppColors.shadow.opacity(0.8)
        }
    }
    
    private var cornerRadiusForStyle: CGFloat {
        switch style {
        case .compact: return 6
        case .standard: return 8
        case .overlay: return 10
        }
    }
    
    private var progressGradient: LinearGradient {
        LinearGradient(
            colors: tokenUsagePercentage > 80 ? 
                [.red, .orange] : 
                tokenUsagePercentage > 50 ?
                [.orange, .yellow] :
                [AppColors.dynamicAccent(for: ThemeManager.shared.currentColorTheme), .green],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        AIUsageProgressView(tokenUsagePercentage: 25.5, style: .compact)
        AIUsageProgressView(tokenUsagePercentage: 65.2, style: .standard)
        AIUsageProgressView(tokenUsagePercentage: 85.7, style: .overlay)
    }
    .padding()
    .background(Color.black.opacity(0.3))
}