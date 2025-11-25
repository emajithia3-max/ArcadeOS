import SwiftUI

@main
struct ArcadeOSApp: App {
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var storeKitManager = StoreKitManager.shared
    @StateObject private var accessManager = AccessManager.shared
    @StateObject private var adManager = RewardedAdManager.shared

    init() {
        // Initialize AdMob
        Task { @MainActor in
            RewardedAdManager.shared.initializeAdMob()
        }
    }

    var body: some Scene {
        WindowGroup {
            BootView()
                .preferredColorScheme(.dark)
                .statusBarHidden(true)
                .environmentObject(audioManager)
                .environmentObject(storeKitManager)
                .environmentObject(accessManager)
                .environmentObject(adManager)
        }
    }
}
