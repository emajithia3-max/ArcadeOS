import Foundation
import GoogleMobileAds
import UIKit

@MainActor
class RewardedAdManager: NSObject, ObservableObject {
    static let shared = RewardedAdManager()

    @Published var isAdReady = false
    @Published var isLoadingAd = false

    private var rewardedAd: GADRewardedAd?
    private var onAdWatched: (() -> Void)?

    // Use AdMob test ad unit ID for development
    // Replace with your production ad unit ID before release
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313" // Test ID

    private override init() {
        super.init()
    }

    // MARK: - Initialize AdMob

    func initializeAdMob() {
        GADMobileAds.sharedInstance().start { status in
            print("✅ AdMob initialized")
            Task { @MainActor in
                self.loadAd()
            }
        }
    }

    // MARK: - Load Rewarded Ad (NPA only)

    func loadAd() {
        guard !isLoadingAd else { return }

        isLoadingAd = true
        isAdReady = false

        let request = GADRequest()

        // CRITICAL: Set NPA (Non-Personalized Ads) parameter
        let extras = GADExtras()
        extras.additionalParameters = ["npa": "1"]
        request.register(extras)

        GADRewardedAd.load(withAdUnitID: adUnitID, request: request) { [weak self] ad, error in
            Task { @MainActor [weak self] in
                self?.isLoadingAd = false

                if let error = error {
                    print("❌ Failed to load ad: \(error.localizedDescription)")
                    self?.isAdReady = false
                    return
                }

                self?.rewardedAd = ad
                self?.rewardedAd?.fullScreenContentDelegate = self
                self?.isAdReady = true
                print("✅ Rewarded ad loaded")
            }
        }
    }

    // MARK: - Show Rewarded Ad

    func showAd(from viewController: UIViewController, completion: @escaping () -> Void) {
        guard let ad = rewardedAd, isAdReady else {
            print("⚠️ Ad not ready")
            return
        }

        onAdWatched = completion

        ad.present(fromRootViewController: viewController) { [weak self] in
            print("✅ User earned reward")
            self?.onAdWatched?()
            self?.onAdWatched = nil
        }
    }

    // Helper to get root view controller
    func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return nil
        }
        return rootViewController
    }
}

// MARK: - Full Screen Content Delegate

extension RewardedAdManager: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("ℹ️ Ad dismissed")
        // Load next ad
        loadAd()
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ Failed to present ad: \(error.localizedDescription)")
        loadAd()
    }
}
