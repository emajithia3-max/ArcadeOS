import SwiftUI

struct DesktopView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var storeKitManager: StoreKitManager
    @EnvironmentObject var accessManager: AccessManager

    @State private var selectedGame: GameMeta?
    @State private var lastTapTime: Date?
    @State private var lastTappedGame: GameMeta?
    @State private var openedGame: GameMeta?
    @State private var showPaywall = false
    @State private var paywallGame: GameMeta?

    // Grid layout
    let columns = [
        GridItem(.adaptive(minimum: 70), spacing: 16)
    ]

    var body: some View {
        ZStack {
            // Desktop background
            LinearGradient(
                gradient: Gradient(colors: [Colors.desktopTeal, Colors.desktopTealDark]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(GameCatalog.allGames) { game in
                        GameIconView(
                            game: game,
                            isSelected: selectedGame?.id == game.id,
                            onTap: { handleTap(game: game) }
                        )
                    }
                }
                .padding(16)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.1)) {
                    selectedGame = nil
                }
            }

            // Game Window
            if let game = openedGame {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Dismiss on background tap
                        closeGame()
                    }

                WindowManager(game: game, onClose: closeGame)
                    .padding(20)
            }

            // Paywall Modal
            if showPaywall, let game = paywallGame {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissPaywall()
                    }

                PaywallModal(
                    game: game,
                    onClose: { dismissPaywall() },
                    onSubscribe: { handleSubscribe() },
                    onWatchAd: { handleWatchAd(game: game) }
                )
                .padding(40)
            }
        }
    }

    // MARK: - Tap Handling

    private func handleTap(game: GameMeta) {
        let now = Date()

        if let lastTap = lastTapTime,
           let lastGame = lastTappedGame,
           lastGame.id == game.id,
           now.timeIntervalSince(lastTap) < 0.5 {
            // Double tap - open game
            audioManager.playClickSound()
            openGame(game)
        } else {
            // Single tap - select
            audioManager.playClickSound()
            withAnimation(.easeInOut(duration: 0.1)) {
                selectedGame = game
            }
        }

        lastTapTime = now
        lastTappedGame = game
    }

    // MARK: - Game Access

    private func openGame(_ game: GameMeta) {
        // Check if user has access
        if accessManager.hasAccess(game, isSubscriber: storeKitManager.isSubscriber) {
            withAnimation {
                openedGame = game
            }
        } else {
            // Show paywall
            paywallGame = game
            withAnimation {
                showPaywall = true
            }
        }
    }

    private func closeGame() {
        audioManager.playBoopSound()
        withAnimation {
            openedGame = nil
        }
    }

    private func dismissPaywall() {
        audioManager.playBoopSound()
        withAnimation {
            showPaywall = false
            paywallGame = nil
        }
    }

    // MARK: - Monetization Actions

    private func handleSubscribe() {
        Task {
            do {
                try await storeKitManager.purchase()
                dismissPaywall()

                // Open game if subscribed
                if storeKitManager.isSubscriber, let game = paywallGame {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        openGame(game)
                    }
                }
            } catch {
                print("❌ Purchase failed: \(error)")
            }
        }
    }

    private func handleWatchAd(game: GameMeta) {
        guard let rootVC = RewardedAdManager.shared.getRootViewController() else {
            print("⚠️ Could not get root view controller")
            return
        }

        RewardedAdManager.shared.showAd(from: rootVC) {
            // Grant temp access
            accessManager.grantTempAccess(game.id)
            dismissPaywall()

            // Open game
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                openGame(game)
            }
        }
    }
}

// MARK: - Game Icon View

struct GameIconView: View {
    let game: GameMeta
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                if isSelected {
                    Rectangle()
                        .fill(Colors.iconHighlight)
                        .frame(width: 72, height: 72)
                }

                // Icon image (SF Symbol as placeholder)
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundColor(.white)
                    .shadow(radius: 2)

                // Premium badge
                if game.isPremium {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                                .padding(4)
                                .background(Circle().fill(Color.black.opacity(0.7)))
                        }
                        Spacer()
                    }
                    .frame(width: 64, height: 64)
                }
            }
            .frame(width: 72, height: 72)
            .border(isSelected ? Color.black : Color.clear, width: 1)

            Text(game.title)
                .font(Fonts.buttonTiny)
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 70)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(isSelected ? Color.blue : Color.clear)
        }
        .frame(width: 80)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }

    private var iconName: String {
        // Map game types to SF Symbol icons
        switch game.id {
        case "pong": return "gamecontroller.fill"
        case "snake": return "arrow.triangle.turn.up.right.circle.fill"
        case "breakout": return "square.grid.3x3.fill"
        case "tetris": return "square.stack.3d.up.fill"
        case "pacman": return "face.smiling.fill"
        case "invaders": return "airplane"
        case "maze": return "map.fill"
        case "chess": return "crown.fill"
        case "puzzle": return "puzzlepiece.fill"
        case "racing": return "car.fill"
        case "golf": return "sportscourt.fill"
        default: return "app.fill"
        }
    }
}
