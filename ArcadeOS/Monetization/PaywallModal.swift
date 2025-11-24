import SwiftUI

struct PaywallModal: View {
    let game: GameMeta
    let onClose: () -> Void
    let onSubscribe: () -> Void
    let onWatchAd: () -> Void

    @EnvironmentObject var storeKitManager: StoreKitManager
    @EnvironmentObject var accessManager: AccessManager
    @EnvironmentObject var adManager: RewardedAdManager

    var body: some View {
        WindowFrame(title: "Premium Game", onClose: onClose) {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.yellow)

                    Text(game.title)
                        .font(Fonts.titleSmall)
                        .foregroundColor(Colors.textBlack)

                    Text("This is a premium game")
                        .font(Fonts.caption)
                        .foregroundColor(Colors.buttonShadow)
                }
                .padding(.top, 20)

                Divider()

                // Options
                VStack(spacing: 16) {
                    // Watch Ad option
                    VStack(spacing: 8) {
                        Text("Watch Ad (30 minutes)")
                            .font(Fonts.button)
                            .foregroundColor(Colors.textBlack)

                        if canWatchAd {
                            RetroButton("Watch Ad", isSmall: true, isDisabled: !adManager.isAdReady) {
                                onWatchAd()
                            }

                            if !adManager.isAdReady {
                                Text("Loading ad...")
                                    .font(Fonts.caption)
                                    .foregroundColor(Colors.buttonShadow)
                            }
                        } else {
                            Text(limitMessage)
                                .font(Fonts.caption)
                                .foregroundColor(Colors.redLose)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 10)
                        }
                    }

                    Divider()

                    // Subscribe option
                    VStack(spacing: 8) {
                        Text("Subscribe to ArcadePass")
                            .font(Fonts.button)
                            .foregroundColor(Colors.textBlack)

                        Text("\(storeKitManager.subscriptionPrice)/month")
                            .font(Fonts.buttonSmall)
                            .foregroundColor(Colors.titleBarBlue)

                        Text("Unlock ALL premium games")
                            .font(Fonts.caption)
                            .foregroundColor(Colors.buttonShadow)

                        RetroButton("Subscribe", isSmall: true, isDisabled: storeKitManager.purchaseInProgress) {
                            onSubscribe()
                        }

                        if storeKitManager.purchaseInProgress {
                            Text("Processing...")
                                .font(Fonts.caption)
                                .foregroundColor(Colors.buttonShadow)
                        }
                    }
                }

                Spacer()

                // Close button
                RetroButton("Cancel", isSmall: true) {
                    onClose()
                }
                .padding(.bottom, 10)
            }
            .padding()
        }
        .frame(maxWidth: 400, maxHeight: 500)
    }

    // MARK: - Ad Eligibility

    private var canWatchAd: Bool {
        accessManager.canWatchAd(for: game.id)
    }

    private var limitMessage: String {
        guard let nextAvailable = accessManager.nextAvailableTime(for: game.id) else {
            return "Not available"
        }

        let now = Date()
        if nextAvailable > now {
            let interval = nextAvailable.timeIntervalSince(now)
            if interval > 3600 {
                // Tomorrow
                return "Daily limit reached\nAvailable tomorrow"
            } else {
                // Cooldown
                return "Cooldown: \(accessManager.formattedTime(interval)) remaining"
            }
        }

        return "Not available"
    }
}
