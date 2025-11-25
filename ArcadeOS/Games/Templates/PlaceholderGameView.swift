import SwiftUI

struct PlaceholderGameView: View {
    let game: GameMeta
    @EnvironmentObject var accessManager: AccessManager

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Game icon
            Image(systemName: "gamecontroller.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(Colors.titleBarBlue)

            // Game title
            Text(game.title)
                .font(Fonts.titleSmall)
                .foregroundColor(Colors.textBlack)

            // Status message
            VStack(spacing: 10) {
                Text("Coming Soon!")
                    .font(Fonts.buttonSmall)
                    .foregroundColor(Colors.textBlack)

                if game.isPremium {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Premium Game")
                            .font(Fonts.caption)
                            .foregroundColor(Colors.buttonShadow)
                    }

                    // Show temp unlock status if active
                    if let remainingTime = accessManager.remainingUnlockTime(for: game.id) {
                        Text("Unlocked: \(accessManager.formattedTime(remainingTime)) left")
                            .font(Fonts.caption)
                            .foregroundColor(Colors.greenWin)
                            .padding(.top, 5)
                    }
                }
            }

            Spacer()

            // Implementation note
            Text("This is a placeholder.\nImplement your game logic here!")
                .font(Fonts.caption)
                .foregroundColor(Colors.buttonShadow)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Colors.windowGray)
    }
}
