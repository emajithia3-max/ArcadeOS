import Foundation
import StoreKit

@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

    @Published var isSubscriber = false
    @Published var products: [Product] = []
    @Published var purchaseInProgress = false

    private let productID = "arcadepass.monthly"

    private init() {
        Task {
            await loadProducts()
            await checkSubscriptionStatus()
            observeTransactionUpdates()
        }
    }

    // MARK: - Load Products

    func loadProducts() async {
        do {
            products = try await Product.products(for: [productID])
            print("✅ Loaded \(products.count) product(s)")
        } catch {
            print("❌ Failed to load products: \(error)")
        }
    }

    // MARK: - Check Subscription Status

    func checkSubscriptionStatus() async {
        var isActive = false

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == productID && !transaction.isUpgraded {
                    isActive = true
                    break
                }
            }
        }

        isSubscriber = isActive
    }

    // MARK: - Purchase Subscription

    func purchase() async throws {
        guard let product = products.first(where: { $0.id == productID }) else {
            throw StoreError.productNotFound
        }

        purchaseInProgress = true
        defer { purchaseInProgress = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                await transaction.finish()
                await checkSubscriptionStatus()
                print("✅ Purchase successful")
            case .unverified(_, let error):
                print("❌ Purchase unverified: \(error)")
                throw StoreError.verificationFailed
            }

        case .userCancelled:
            print("ℹ️ User cancelled purchase")
            break

        case .pending:
            print("⏳ Purchase pending")
            break

        @unknown default:
            break
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkSubscriptionStatus()
            print("✅ Purchases restored")
        } catch {
            print("❌ Failed to restore purchases: \(error)")
        }
    }

    // MARK: - Transaction Observer

    private func observeTransactionUpdates() {
        Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await checkSubscriptionStatus()
                }
            }
        }
    }

    // MARK: - Formatted Price

    var subscriptionPrice: String {
        products.first(where: { $0.id == productID })?.displayPrice ?? "$0.99"
    }
}

// MARK: - Store Errors

enum StoreError: Error {
    case productNotFound
    case verificationFailed
}
