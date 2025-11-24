import SwiftUI

struct WindowManager: View {
    let game: GameMeta
    let onClose: () -> Void

    var body: some View {
        WindowFrame(title: game.title, onClose: onClose) {
            gameContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Colors.windowGray)
        }
        .frame(maxWidth: 500, maxHeight: 600)
    }

    @ViewBuilder
    private var gameContent: some View {
        switch game.id {
        case "pong":
            PongGameView()
        default:
            PlaceholderGameView(game: game)
        }
    }
}
