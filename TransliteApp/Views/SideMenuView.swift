import SwiftUI
import StoreKit

struct SideMenuView: View {
    @Binding var isShowing: Bool
    @Binding var isPremium: Bool
    @Binding var showPremiumScreen: Bool
    @State private var showHistory = false
    @State private var showShareSheet = false
    @State private var showContactSheet = false
    @State private var showPrivacySheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with gradient background
            ZStack(alignment: .bottom) {
                LinearGradient(
                    gradient: Gradient(colors: [
                        .blue,
                        .blue.opacity(0.2),
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 200)
                
                VStack(spacing: 12) {
                    // Globe with stars
                    ZStack {
                        // Small stars
                        ForEach(0..<8) { _ in
                            Circle()
                                .fill(Color.white.opacity(Double.random(in: 0.4...0.8)))
                                .frame(width: CGFloat.random(in: 2...3))
                                .position(
                                    x: CGFloat.random(in: 40...150),
                                    y: CGFloat.random(in: 40...120)
                                )
                        }
                        
                        Image("Planet")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)

                    }
                    .frame(width: 190, height: 100)
                    
                    Text("Voice Translate")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 20)
            }
            
            // Get Premium button
            Button(action: {
                showPremiumScreen = true
                withAnimation {
                    isShowing = false
                }
            }) {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.white)
                    Text("Get Premium")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.green)
                .cornerRadius(25)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            
            // Menu items
            VStack(alignment: .leading, spacing: 5) {
                MenuItemView(
                    icon: "clock.arrow.circlepath",
                    title: "History",
                    iconColor: Color(red: 0.4, green: 0.6, blue: 1.0),
                    action: {
                        showHistory = true
                        withAnimation {
                            isShowing = false
                        }
                    }
                )
                
                MenuItemView(
                    icon: "star.fill",
                    title: "Rate us",
                    iconColor: Color(red: 0.4, green: 0.6, blue: 1.0),
                    action: {
                        rateApp()
                        withAnimation {
                            isShowing = false
                        }
                    }
                )
                
                MenuItemView(
                    icon: "square.and.arrow.up",
                    title: "Share app",
                    iconColor: Color(red: 0.4, green: 0.6, blue: 1.0),
                    action: {
                        showShareSheet = true
                        withAnimation {
                            isShowing = false
                        }
                    }
                )
                
                MenuItemView(
                    icon: "message.fill",
                    title: "Contact Us",
                    iconColor: Color(red: 0.4, green: 0.6, blue: 1.0),
                    action: {
                        showContactSheet = true
                        withAnimation {
                            isShowing = false
                        }
                    }
                )
                
                MenuItemView(
                    icon: "lock.shield.fill",
                    title: "Privacy Policy",
                    iconColor: Color(red: 0.4, green: 0.6, blue: 1.0),
                    action: {
                        showPrivacySheet = true
                        withAnimation {
                            isShowing = false
                        }
                    }
                )
            }
            .padding(.top, 10)
            
            Spacer()
            
            // Premium status indicator
            if isPremium {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.green)
                    Text("Premium Active")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .fullScreenCover(isPresented: $showHistory) {
            HistoryView()
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
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                }
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
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
        NavigationView {
            ScrollView {
            VStack(spacing: 30) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Share Voice Translate")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Help your friends discover this amazing translation app!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                
                VStack(spacing: 15) {
                    ShareButton(
                        icon: "message.fill",
                        title: "Share via Messages",
                        action: { shareViaMessages() }
                    )
                    
                    ShareButton(
                        icon: "envelope.fill",
                        title: "Share via Email",
                        action: { shareViaEmail() }
                    )
                    
                    ShareButton(
                        icon: "square.and.arrow.up.fill",
                        title: "More Options",
                        action: { shareViaActivityController() }
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Share App")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
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
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ContactView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "message.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Contact Us")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("We'd love to hear from you! Get in touch with our support team.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                
                VStack(spacing: 15) {
                    ContactButton(
                        icon: "envelope.fill",
                        title: "Email Support",
                        subtitle: "support@voicetranslate.com",
                        action: { contactViaEmail() }
                    )
                    
                    ContactButton(
                        icon: "globe",
                        title: "Visit Website",
                        subtitle: "www.voicetranslate.com",
                        action: { openWebsite() }
                    )
                    
                    ContactButton(
                        icon: "star.fill",
                        title: "Rate & Review",
                        subtitle: "Help us improve the app",
                        action: { openAppStore() }
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Contact")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
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
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    PolicySection(
                        title: "Information We Collect",
                        content: "We collect minimal information necessary to provide translation services. This includes text you translate, language preferences, and basic usage analytics to improve our service."
                    )
                    
                    PolicySection(
                        title: "How We Use Information",
                        content: "Your translation data is processed locally on your device whenever possible. We use anonymous analytics to improve translation accuracy and app performance."
                    )
                    
                    PolicySection(
                        title: "Data Storage",
                        content: "Translation history is stored locally on your device. We do not store your personal translations on our servers unless you explicitly enable cloud sync."
                    )
                    
                    PolicySection(
                        title: "Third-Party Services",
                        content: "We use Google Translate API for online translations. Please refer to Google's Privacy Policy for information about their data handling practices."
                    )
                    
                    PolicySection(
                        title: "Your Rights",
                        content: "You can delete your translation history at any time through the app settings. You can also disable analytics collection in the privacy settings."
                    )
                    
                    PolicySection(
                        title: "Contact Us",
                        content: "If you have questions about this privacy policy, please contact us at privacy@voicetranslate.com"
                    )
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Button("View Full Privacy Policy") {
                            openFullPrivacyPolicy()
                        }
                        .foregroundColor(.blue)
                        
                        Text("Last updated: December 2024")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
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
                .foregroundColor(.primary)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
