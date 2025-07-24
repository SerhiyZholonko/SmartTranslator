import SwiftUI
import StoreKit

@MainActor
final class PremiumViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var isSubscribed = false
    @Published var isPurchasing = false
    @Published var products: [Product] = []
    @Published var selectedProduct: Product?
    @Published var showSuccessAnimation = false
    
    // MARK: - Properties
    private let premiumManager = PremiumManager.shared
    private var purchaseTask: Task<Void, Never>?
    
    // Premium Features
    let premiumFeatures = [
        PremiumFeature(
            icon: "camera.fill",
            title: "camera_translation",
            description: "camera_translation_desc"
        ),
        PremiumFeature(
            icon: "doc.text.fill",
            title: "file_translation",
            description: "file_translation_desc"
        ),
        PremiumFeature(
            icon: "infinity",
            title: "unlimited_translations",
            description: "unlimited_translations_desc"
        ),
        PremiumFeature(
            icon: "bolt.fill",
            title: "faster_processing",
            description: "faster_processing_desc"
        ),
        PremiumFeature(
            icon: "speaker.wave.3.fill",
            title: "premium_voices",
            description: "premium_voices_desc"
        ),
        PremiumFeature(
            icon: "rectangle.stack.fill",
            title: "no_ads",
            description: "no_ads_desc"
        )
    ]
    
    // Product IDs
    private let productIds = [
        "com.smarttranslator.premium.monthly",
        "com.smarttranslator.premium.yearly",
        "com.smarttranslator.premium.lifetime"
    ]
    
    override init() {
        super.init()
        setupBindings()
        loadProducts()
        checkSubscriptionStatus()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        premiumManager.$isPremium
            .assign(to: &$isSubscribed)
    }
    
    // MARK: - Public Methods
    func purchase(_ product: Product) {
        guard !isPurchasing else { return }
        
        purchaseTask?.cancel()
        purchaseTask = Task {
            await purchaseProduct(product)
        }
    }
    
    func restorePurchases() {
        Task {
            isPurchasing = true
            clearError()
            
            do {
                try await AppStore.sync()
                await checkSubscriptionStatus()
                
                if isSubscribed {
                    showSuccessAnimation = true
                    showError("purchases_restored".localized)
                } else {
                    showError("no_purchases_found".localized)
                }
            } catch {
                handleError(error)
            }
            
            isPurchasing = false
        }
    }
    
    func selectProduct(_ product: Product) {
        selectedProduct = product
    }
    
    // MARK: - Private Methods
    private func loadProducts() {
        Task {
            isLoading = true
            
            do {
                products = try await Product.products(for: productIds)
                
                // Sort products by price
                products.sort { $0.price < $1.price }
                
                // Select default product (usually monthly)
                selectedProduct = products.first
            } catch {
                showError("failed_to_load_products".localized)
                print("Failed to load products: \(error)")
            }
            
            isLoading = false
        }
    }
    
    private func purchaseProduct(_ product: Product) async {
        isPurchasing = true
        clearError()
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Verify the purchase
                switch verification {
                case .verified(let transaction):
                    // Update premium status
                    await premiumManager.checkPremiumStatus()
                    
                    // Finish the transaction
                    await transaction.finish()
                    
                    // Show success
                    showSuccessAnimation = true
                    
                case .unverified:
                    showError("purchase_unverified".localized)
                }
                
            case .userCancelled:
                // User cancelled, no need to show error
                break
                
            case .pending:
                showError("purchase_pending".localized)
                
            @unknown default:
                showError("purchase_failed".localized)
            }
        } catch {
            handleError(error)
        }
        
        isPurchasing = false
    }
    
    private func checkSubscriptionStatus() {
        Task {
            await premiumManager.checkPremiumStatus()
        }
    }
    
    deinit {
        purchaseTask?.cancel()
    }
}

// MARK: - Supporting Types
struct PremiumFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

// MARK: - Product Extensions
extension Product {
    var localizedPeriod: String {
        switch self.subscription?.subscriptionPeriod.unit {
        case .day:
            return "daily".localized
        case .week:
            return "weekly".localized
        case .month:
            return "monthly".localized
        case .year:
            return "yearly".localized
        default:
            return "lifetime".localized
        }
    }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: price as NSDecimalNumber) ?? displayPrice
    }
}