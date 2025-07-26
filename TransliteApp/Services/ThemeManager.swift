import SwiftUI
import Combine

// MARK: - Theme Preference
enum ThemePreference: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var localizedName: String {
        switch self {
        case .system:
            return "theme_system".localized
        case .light:
            return "theme_light".localized
        case .dark:
            return "theme_dark".localized
        }
    }
}

// MARK: - Theme Manager
@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: ThemePreference = .system {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
        }
    }
    
    @Published var isDarkMode: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadThemePreference()
        setupThemeObserver()
    }
    
    private func loadThemePreference() {
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = ThemePreference(rawValue: savedTheme) {
            currentTheme = theme
        }
    }
    
    private func setupThemeObserver() {
        // Observe system color scheme changes
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.updateDarkModeStatus()
            }
            .store(in: &cancellables)
        
        // Initial update
        updateDarkModeStatus()
    }
    
    func updateDarkModeStatus() {
        let systemColorScheme = UITraitCollection.current.userInterfaceStyle
        
        switch currentTheme {
        case .system:
            isDarkMode = systemColorScheme == .dark
        case .light:
            isDarkMode = false
        case .dark:
            isDarkMode = true
        }
    }
    
    func setTheme(_ theme: ThemePreference) {
        currentTheme = theme
        updateDarkModeStatus()
        
        // Apply theme to all windows
        applyThemeToAllWindows()
    }
    
    private func applyThemeToAllWindows() {
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
        
        windows.forEach { window in
            switch currentTheme {
            case .system:
                window.overrideUserInterfaceStyle = .unspecified
            case .light:
                window.overrideUserInterfaceStyle = .light
            case .dark:
                window.overrideUserInterfaceStyle = .dark
            }
        }
    }
}

// MARK: - View Modifier for Theme
struct ThemeAwareModifier: ViewModifier {
    @ObservedObject private var themeManager = ThemeManager.shared
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(themeManager.currentTheme == .system ? nil : 
                                  themeManager.currentTheme == .dark ? .dark : .light)
    }
}

extension View {
    func themeAware() -> some View {
        modifier(ThemeAwareModifier())
    }
}

// MARK: - Theme-aware Components
struct ThemedButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .primary
    
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
    }
    
    var backgroundColor: Color {
        switch style {
        case .primary:
            return AppColors.buttonBackground
        case .secondary:
            return AppColors.secondaryBackground
        case .destructive:
            return AppColors.errorColor
        }
    }
    
    var foregroundColor: Color {
        switch style {
        case .primary:
            return AppColors.buttonText
        case .secondary:
            return AppColors.primaryText
        case .destructive:
            return .white
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .cornerRadius(12)
        }
    }
}

struct ThemedTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(AppColors.inputBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColors.inputBorder, lineWidth: 1)
        )
        .foregroundColor(AppColors.primaryText)
    }
}

struct ThemedCard: View {
    let content: () -> AnyView
    
    var body: some View {
        VStack {
            content()
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: AppColors.shadow, radius: 4, x: 0, y: 2)
    }
}