import SwiftUI

struct BreakoutGameView: View {
    @State private var ballPosition = CGPoint(x: 250, y: 400)
    @State private var ballVelocity = CGVector(dx: 4, dy: -4)
    @State private var paddleX: CGFloat = 200
    @State private var bricks: [[Bool]] = Array(repeating: Array(repeating: true, count: 8), count: 6)
    @State private var score = 0
    @State private var lives = 3
    @State private var gameActive = false
    @State private var gameWon = false

    let ballSize: CGFloat = 12
    let paddleWidth: CGFloat = 80
    let paddleHeight: CGFloat = 15
    let brickWidth: CGFloat = 50
    let brickHeight: CGFloat = 20

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black

                // Bricks
                ForEach(0..<6, id: \.self) { row in
                    ForEach(0..<8, id: \.self) { col in
                        if bricks[row][col] {
                            Rectangle()
                                .fill(brickColor(row: row))
                                .frame(width: brickWidth, height: brickHeight)
                                .position(x: CGFloat(col) * (brickWidth + 5) + brickWidth / 2 + 20,
                                         y: CGFloat(row) * (brickHeight + 5) + brickHeight / 2 + 50)
                        }
                    }
                }

                // Paddle
                Rectangle()
                    .fill(Color.white)
                    .frame(width: paddleWidth, height: paddleHeight)
                    .position(x: paddleX, y: geometry.size.height - 50)

                // Ball
                Circle()
                    .fill(Color.white)
                    .frame(width: ballSize, height: ballSize)
                    .position(ballPosition)

                // HUD
                VStack {
                    HStack {
                        Text("Score: \(score)")
                            .font(Fonts.stats)
                            .foregroundColor(.white)
                        Spacer()
                        Text("Lives: \(lives)")
                            .font(Fonts.stats)
                            .foregroundColor(.white)
                    }
                    .padding()
                    Spacer()
                }

                // Game state overlays
                if !gameActive || gameWon {
                    VStack {
                        if gameWon {
                            Text("You Win!")
                                .font(Fonts.title)
                                .foregroundColor(.green)
                        } else if lives == 0 {
                            Text("Game Over")
                                .font(Fonts.title)
                                .foregroundColor(.red)
                        }

                        RetroButton("Start", isSmall: true) {
                            startGame()
                        }
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        paddleX = max(paddleWidth / 2, min(geometry.size.width - paddleWidth / 2, value.location.x))
                    }
            )
        }
        .onReceive(Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()) { _ in
            if gameActive && !gameWon {
                updateGame()
            }
        }
    }

    private func brickColor(row: Int) -> Color {
        switch row {
        case 0, 1: return .red
        case 2, 3: .orange
        default: return .yellow
        }
    }

    private func startGame() {
        ballPosition = CGPoint(x: 250, y: 400)
        ballVelocity = CGVector(dx: 4, dy: -4)
        paddleX = 200
        bricks = Array(repeating: Array(repeating: true, count: 8), count: 6)
        score = 0
        lives = 3
        gameActive = true
        gameWon = false
    }

    private func updateGame() {
        // Move ball
        ballPosition.x += ballVelocity.dx
        ballPosition.y += ballVelocity.dy

        // Wall collisions
        if ballPosition.x <= ballSize / 2 || ballPosition.x >= 500 - ballSize / 2 {
            ballVelocity.dx *= -1
        }
        if ballPosition.y <= ballSize / 2 {
            ballVelocity.dy *= -1
        }

        // Paddle collision
        if ballPosition.y >= 550 - ballSize / 2,
           ballPosition.x >= paddleX - paddleWidth / 2,
           ballPosition.x <= paddleX + paddleWidth / 2 {
            ballVelocity.dy = -abs(ballVelocity.dy)
            let offset = (ballPosition.x - paddleX) / (paddleWidth / 2)
            ballVelocity.dx += offset * 2
        }

        // Bottom collision (lose life)
        if ballPosition.y >= 600 {
            lives -= 1
            if lives > 0 {
                ballPosition = CGPoint(x: 250, y: 400)
                ballVelocity = CGVector(dx: 4, dy: -4)
            } else {
                gameActive = false
            }
        }

        // Brick collisions
        for row in 0..<6 {
            for col in 0..<8 {
                if bricks[row][col] {
                    let brickX = CGFloat(col) * (brickWidth + 5) + brickWidth / 2 + 20
                    let brickY = CGFloat(row) * (brickHeight + 5) + brickHeight / 2 + 50

                    if abs(ballPosition.x - brickX) < (brickWidth + ballSize) / 2 &&
                       abs(ballPosition.y - brickY) < (brickHeight + ballSize) / 2 {
                        bricks[row][col] = false
                        ballVelocity.dy *= -1
                        score += 10

                        // Check win
                        if bricks.flatMap({ $0 }).allSatisfy({ !$0 }) {
                            gameWon = true
                            gameActive = false
                        }
                        return
                    }
                }
            }
        }
    }
}
