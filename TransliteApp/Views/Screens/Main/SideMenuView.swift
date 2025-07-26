import SwiftUI
import StoreKit

struct SideMenuView: View {
    @Binding var isShowing: Bool
    @Binding var isPremium: Bool
    @Binding var showPremiumScreen: Bool
    @State private var showHistory = false
    @State private var showFlashcards = false
    @State private var showSettings = false
    @State private var showShareSheet = false
    @State private var showContactSheet = false
    @State private var showPrivacySheet = false
    @State private var menuItemsOpacity: Double = 0
    
    var body: some View {
        // Menu container with shadow
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                    // Header with gradient background
                    ZStack(alignment: .bottom) {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppColors.appAccent,
                                AppColors.appAccent.opacity(0.5)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 220)
                        
                        // Animated wave overlay
                        GeometryReader { geometry in
                            Path { path in
                                let width = geometry.size.width
                                let height = geometry.size.height
                                path.move(to: CGPoint(x: 0, y: height * 0.8))
                                path.addCurve(
                                    to: CGPoint(x: width, y: height * 0.7),
                                    control1: CGPoint(x: width * 0.3, y: height * 0.75),
                                    control2: CGPoint(x: width * 0.7, y: height * 0.85)
                                )
                                path.addLine(to: CGPoint(x: width, y: height))
                                path.addLine(to: CGPoint(x: 0, y: height))
                            }
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [AppColors.buttonText.opacity(0.1), Color.clear]),
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                        }
                        .frame(height: 220)
                
                        VStack(spacing: 12) {
                            // Globe with animated stars
                            ZStack {
                                // Animated stars
                                ForEach(0..<12) { index in
                                    Circle()
                                        .fill(AppColors.buttonText.opacity(Double.random(in: 0.3...0.9)))
                                        .frame(width: CGFloat.random(in: 2...4))
                                        .position(
                                            x: CGFloat.random(in: 30...200),
                                            y: CGFloat.random(in: 30...120)
                                        )
                                        .opacity(menuItemsOpacity)
                                        .scaleEffect(menuItemsOpacity)
                                        .animation(
                                            .easeInOut(duration: 2)
                                            .repeatForever(autoreverses: true)
                                            .delay(Double(index) * 0.2),
                                            value: menuItemsOpacity
                                        )
                                }
                                
                                Image("Planet")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 80)
                                    .shadow(color: AppColors.shadow.opacity(0.3), radius: 10, x: 0, y: 5)
                                    .opacity(menuItemsOpacity)
                                    .scaleEffect(menuItemsOpacity)
                            }
                            .frame(width: 230, height: 100)
                    
                            Text("app_name".localized)
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.buttonText)
                                .shadow(color: AppColors.shadow.opacity(0.3), radius: 2, x: 0, y: 2)
                                .opacity(menuItemsOpacity)
                        }
                        .padding(.bottom, 25)
                        .padding(.top, 40)
                    }
            
                    // Get Premium button with gradient
                    Button(action: {
                        showPremiumScreen = true
                        closeMenu()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(AppColors.buttonText)
                                .font(.system(size: 18))
                            Text("get_premium".localized)
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.buttonText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppColors.successColor,
                                    AppColors.successColor.opacity(0.8)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                        .shadow(color: AppColors.successColor.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .opacity(menuItemsOpacity)
                    .scaleEffect(menuItemsOpacity)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.1), value: menuItemsOpacity)
            
                    // Menu items with staggered animation
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                        MenuItemView(
                            icon: "clock.arrow.circlepath",
                            title: "menu_history".localized,
                            iconColor: AppColors.appAccent,
                            action: {
                                showHistory = true
                            }
                        )
                        .opacity(menuItemsOpacity)
                        .offset(x: menuItemsOpacity == 1 ? 0 : -50)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.15), value: menuItemsOpacity)
                
                        MenuItemView(
                            icon: "rectangle.stack.fill",
                            title: "menu_flashcards".localized,
                            iconColor: AppColors.secondaryAccent,
                            action: {
                                showFlashcards = true
                            }
                        )
                        .opacity(menuItemsOpacity)
                        .offset(x: menuItemsOpacity == 1 ? 0 : -50)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.18), value: menuItemsOpacity)
                
                        MenuItemView(
                            icon: "gear",
                            title: "menu_settings".localized,
                            iconColor: AppColors.secondaryText,
                            action: {
                                showSettings = true
                                closeMenu()
                            }
                        )
                        .opacity(menuItemsOpacity)
                        .offset(x: menuItemsOpacity == 1 ? 0 : -50)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.21), value: menuItemsOpacity)
                
                        MenuItemView(
                            icon: "star.fill",
                            title: "menu_rate_us".localized,
                            iconColor: AppColors.warningColor,
                            action: {
                                rateApp()
                            }
                        )
                        .opacity(menuItemsOpacity)
                        .offset(x: menuItemsOpacity == 1 ? 0 : -50)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.24), value: menuItemsOpacity)
                
                        MenuItemView(
                            icon: "square.and.arrow.up",
                            title: "menu_share_app".localized,
                            iconColor: AppColors.successColor,
                            action: {
                                showShareSheet = true
                            }
                        )
                        .opacity(menuItemsOpacity)
                        .offset(x: menuItemsOpacity == 1 ? 0 : -50)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.27), value: menuItemsOpacity)
                
                        MenuItemView(
                            icon: "message.fill",
                            title: "menu_contact_us".localized,
                            iconColor: AppColors.appAccent,
                            action: {
                                showContactSheet = true
                            }
                        )
                        .opacity(menuItemsOpacity)
                        .offset(x: menuItemsOpacity == 1 ? 0 : -50)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.30), value: menuItemsOpacity)
                
                        MenuItemView(
                            icon: "lock.shield.fill",
                            title: "menu_privacy_policy".localized,
                            iconColor: AppColors.errorColor,
                            action: {
                                showPrivacySheet = true
                            }
                        )
                        .opacity(menuItemsOpacity)
                        .offset(x: menuItemsOpacity == 1 ? 0 : -50)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.33), value: menuItemsOpacity)
                        }
                        .padding(.top, 10)
                    }
                    .scrollIndicators(.hidden)
            
                    Spacer()
                    
                    // Premium status indicator
                    if isPremium {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(AppColors.successColor)
                            Text("premium_active".localized)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.successColor)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(AppColors.successColor.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppColors.successColor.opacity(0.3), lineWidth: 1)
                        )
                        .padding()
                        .opacity(menuItemsOpacity)
                        .scaleEffect(menuItemsOpacity)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.36), value: menuItemsOpacity)
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.75)
                .frame(maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(AppColors.cardBackground)
                        .shadow(color: AppColors.shadow.opacity(0.3), radius: 20, x: 10, y: 0)
                )
                .clipped()
                
                Spacer()
            }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            openMenu()
        }
        .onChange(of: isShowing) { newValue in
            if newValue {
                openMenu()
            } else {
                closeMenu()
            }
        }
        .fullScreenCover(isPresented: $showHistory) {
            HistoryView()
        }
        .fullScreenCover(isPresented: $showFlashcards) {
            FlashcardsView()
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showShareSheet) {
            ShareView()
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showContactSheet) {
            ContactView()
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showPrivacySheet) {
            PrivacyPolicyView()
                .presentationDetents([.large])
        }
    }
    
    // MARK: - Animation Functions
    private func openMenu() {
        // Show menu items
        withAnimation(.easeInOut(duration: 0.3)) {
            menuItemsOpacity = 1
        }
        
        // Then fade in the content
        withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
            menuItemsOpacity = 1
        }
    }
    
    private func closeMenu() {
        // Hide menu items
        withAnimation(.easeIn(duration: 0.15)) {
            menuItemsOpacity = 0
        }
        
        // Close the menu
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isShowing = false
        }
    }
    
    // MARK: - Helper Functions
    private func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

struct MenuItemView: View {
    let icon: String
    let title: String
    let iconColor: Color
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            // Animate press
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                action()
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconColor.opacity(isPressed ? 0.3 : (isHovered ? 0.2 : 0.15)))
                        .frame(width: 44, height: 44)
                        .shadow(color: iconColor.opacity(0.2), radius: isPressed ? 2 : 4, x: 0, y: isPressed ? 1 : 2)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(iconColor)
                        .scaleEffect(isPressed ? 0.9 : 1.0)
                }
                .scaleEffect(isPressed ? 0.95 : 1.0)
                
                Text(title)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
                    .offset(x: isHovered ? 2 : 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                AppColors.tertiaryBackground.opacity(isHovered ? 0.5 : 0.0)
            )
            .padding(.horizontal, 4)
            .contentShape(Rectangle())
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

#Preview {
    SideMenuView(
        isShowing: .constant(true),
        isPremium: .constant(false),
        showPremiumScreen: .constant(false)
    )
}

// MARK: - Additional Views
struct ShareView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        LocalizedView {
        NavigationView {
            ScrollView {
            VStack(spacing: 30) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 80))
                    .foregroundColor(AppColors.appAccent)
                
                Text("share_app_title".localized)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("share_app_description".localized)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppColors.secondaryText)
                
                VStack(spacing: 15) {
                    ShareButton(
                        icon: "message.fill",
                        title: "share_via_messages".localized,
                        action: { shareViaMessages() }
                    )
                    
                    ShareButton(
                        icon: "envelope.fill",
                        title: "share_via_email".localized,
                        action: { shareViaEmail() }
                    )
                    
                    ShareButton(
                        icon: "square.and.arrow.up.fill",
                        title: "more_options".localized,
                        action: { shareViaActivityController() }
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            }
            .navigationTitle("menu_share_app".localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("done".localized) { dismiss() })
        }
        }
    }
    
    private func shareViaMessages() {
        let text = "Check out this amazing Voice Translate app! https://apps.apple.com/app/voice-translate"
        if let url = URL(string: "sms:?body=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            UIApplication.shared.open(url)
        }
    }
    
    private func shareViaEmail() {
        let subject = "Amazing Voice Translate App"
        let body = "Hi! I wanted to share this amazing translation app with you: https://apps.apple.com/app/voice-translate"
        let emailString = "mailto:?subject=\(subject)&body=\(body)"
        if let url = URL(string: emailString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
            UIApplication.shared.open(url)
        }
    }
    
    private func shareViaActivityController() {
        let text = "Check out Voice Translate - the best translation app!"
        let url = URL(string: "https://apps.apple.com/app/voice-translate")!
        
        let activityVC = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            }
            
            rootViewController.present(activityVC, animated: true)
        }
    }
}

struct ShareButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.appAccent)
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.secondaryText)
            }
            .padding()
            .background(AppColors.tertiaryBackground.opacity(0.5))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ContactView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        LocalizedView {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "message.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppColors.appAccent)
                
                Text("menu_contact_us".localized)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("contact_description".localized)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppColors.secondaryText)
                
                VStack(spacing: 15) {
                    ContactButton(
                        icon: "envelope.fill",
                        title: "email_support".localized,
                        subtitle: "support@voicetranslate.com",
                        action: { contactViaEmail() }
                    )
                    
                    ContactButton(
                        icon: "globe",
                        title: "visit_website".localized,
                        subtitle: "www.voicetranslate.com",
                        action: { openWebsite() }
                    )
                    
                    ContactButton(
                        icon: "star.fill",
                        title: "rate_and_review".localized,
                        subtitle: "rate_help_improve".localized,
                        action: { openAppStore() }
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("menu_contact_us".localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("done".localized) { dismiss() })
        }
        }
    }
    
    private func contactViaEmail() {
        let email = "support@voicetranslate.com"
        let subject = "Voice Translate App Support"
        let body = "Hello Support Team,\n\nI need help with...\n\nApp Version: 1.0\nDevice: \(UIDevice.current.model)\niOS Version: \(UIDevice.current.systemVersion)"
        
        let emailString = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let emailURL = URL(string: emailString) {
            UIApplication.shared.open(emailURL)
        }
    }
    
    private func openWebsite() {
        if let url = URL(string: "https://voicetranslate.com") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openAppStore() {
        if let url = URL(string: "https://apps.apple.com/app/voice-translate") {
            UIApplication.shared.open(url)
        }
    }
}

struct ContactButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.appAccent)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.primaryText)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.secondaryText)
            }
            .padding()
            .background(AppColors.tertiaryBackground.opacity(0.5))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        LocalizedView {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    PolicySection(
                        title: "information_we_collect".localized,
                        content: "information_collect_description".localized
                    )
                    
                    PolicySection(
                        title: "how_we_use_information".localized,
                        content: "how_we_use_description".localized
                    )
                    
                    PolicySection(
                        title: "data_storage".localized,
                        content: "data_storage_description".localized
                    )
                    
                    PolicySection(
                        title: "third_party_services".localized,
                        content: "third_party_description".localized
                    )
                    
                    PolicySection(
                        title: "your_rights".localized,
                        content: "your_rights_description".localized
                    )
                    
                    PolicySection(
                        title: "menu_contact_us".localized,
                        content: "privacy_contact_description".localized
                    )
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Button("view_full_privacy_policy".localized) {
                            openFullPrivacyPolicy()
                        }
                        .foregroundColor(AppColors.appAccent)
                        
                        Text("last_updated_date".localized)
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("menu_privacy_policy".localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("done".localized) { dismiss() })
        }
        }
    }
    
    private func openFullPrivacyPolicy() {
        if let url = URL(string: "https://voicetranslate.com/privacy") {
            UIApplication.shared.open(url)
        }
    }
}

struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
            
            Text(content)
                .font(.body)
                .foregroundColor(AppColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
