import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var storeKitManager: StoreKitManager

    var body: some View {
        WindowFrame(title: "Settings.exe") {
            VStack(spacing: 20) {
                // Audio Settings
                VStack(alignment: .leading, spacing: 10) {
                    Text("Audio")
                        .font(Fonts.button)
                        .foregroundColor(Colors.textBlack)

                    HStack {
                        Text("Sound Effects")
                            .font(Fonts.buttonSmall)
                            .foregroundColor(Colors.textBlack)
                        Spacer()
                        Toggle("", isOn: $audioManager.sfxEnabled)
                            .labelsHidden()
                    }
                    .padding(.horizontal, 10)
                }

                Divider()

                // Subscription Settings
                VStack(alignment: .leading, spacing: 10) {
                    Text("Subscription")
                        .font(Fonts.button)
                        .foregroundColor(Colors.textBlack)

                    VStack(spacing: 8) {
                        HStack {
                            Text("Status:")
                                .font(Fonts.buttonSmall)
                                .foregroundColor(Colors.textBlack)
                            Spacer()
                            Text(storeKitManager.isSubscriber ? "Active" : "Not Active")
                                .font(Fonts.buttonSmall)
                                .foregroundColor(storeKitManager.isSubscriber ? Colors.greenWin : Colors.redLose)
                        }
                        .padding(.horizontal, 10)

                        if !storeKitManager.isSubscriber {
                            RetroButton("Subscribe to ArcadePass", isSmall: true) {
                                Task {
                                    try? await storeKitManager.purchase()
                                }
                            }
                        }

                        RetroButton("Restore Purchases", isSmall: true) {
                            Task {
                                await storeKitManager.restorePurchases()
                            }
                        }
                    }
                }

                Spacer()

                // About
                VStack(spacing: 5) {
                    Text("ArcadeOS - Retro Arcade")
                        .font(Fonts.caption)
                        .foregroundColor(Colors.buttonShadow)
                    Text("v1.0.0")
                        .font(Fonts.caption)
                        .foregroundColor(Colors.buttonShadow)
                }
                .padding(.bottom, 10)
            }
            .padding()
        }
    }
}
