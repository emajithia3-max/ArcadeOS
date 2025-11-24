import SwiftUI

struct PongGameView: View {
    @State private var ballPosition = CGPoint(x: 250, y: 300)
    @State private var ballVelocity = CGVector(dx: 3, dy: 3)
    @State private var playerPaddleY: CGFloat = 250
    @State private var aiPaddleY: CGFloat = 250
    @State private var playerScore = 0
    @State private var aiScore = 0
    @State private var gameActive = false
    @State private var gameOver = false
    @State private var winner = ""

    let paddleWidth: CGFloat = 15
    let paddleHeight: CGFloat = 80
    let ballSize: CGFloat = 12
    let winningScore = 7

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black

                // Center line
                VStack(spacing: 8) {
                    ForEach(0..<20) { _ in
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 2, height: 15)
                    }
                }

                // Player paddle (left)
                Rectangle()
                    .fill(Color.white)
                    .frame(width: paddleWidth, height: paddleHeight)
                    .position(x: 30, y: playerPaddleY)

                // AI paddle (right)
                Rectangle()
                    .fill(Color.white)
                    .frame(width: paddleWidth, height: paddleHeight)
                    .position(x: geometry.size.width - 30, y: aiPaddleY)

                // Ball
                Circle()
                    .fill(Color.white)
                    .frame(width: ballSize, height: ballSize)
                    .position(ballPosition)

                // Score
                HStack {
                    Text("\(playerScore)")
                        .font(Fonts.statsLarge)
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: geometry.size.width / 2)

                    Text("\(aiScore)")
                        .font(Fonts.statsLarge)
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: geometry.size.width / 2)
                }
                .position(x: geometry.size.width / 2, y: 30)

                // Game Over / Start overlay
                if gameOver || !gameActive {
                    VStack(spacing: 20) {
                        if gameOver {
                            Text(winner)
                                .font(Fonts.title)
                                .foregroundColor(.white)
                        }

                        RetroButton(gameOver ? "Play Again" : "Start Game", isSmall: true) {
                            startGame()
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        playerPaddleY = max(paddleHeight / 2, min(geometry.size.height - paddleHeight / 2, value.location.y))
                    }
            )
            .onAppear {
                resetBall(in: geometry.size)
            }
        }
        .onReceive(Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()) { _ in
            if gameActive && !gameOver {
                updateGame()
            }
        }
    }

    // MARK: - Game Logic

    private func startGame() {
        playerScore = 0
        aiScore = 0
        gameOver = false
        winner = ""
        gameActive = true
        resetBall(in: CGSize(width: 500, height: 600))
    }

    private func updateGame() {
        // Move ball
        ballPosition.x += ballVelocity.dx
        ballPosition.y += ballVelocity.dy

        // Ball collision with top/bottom
        if ballPosition.y <= ballSize / 2 || ballPosition.y >= 600 - ballSize / 2 {
            ballVelocity.dy *= -1
        }

        // Ball collision with player paddle
        if ballPosition.x <= 30 + paddleWidth / 2 + ballSize / 2,
           ballPosition.y >= playerPaddleY - paddleHeight / 2,
           ballPosition.y <= playerPaddleY + paddleHeight / 2 {
            ballVelocity.dx = abs(ballVelocity.dx)
            // Add spin based on where ball hits paddle
            let offset = (ballPosition.y - playerPaddleY) / (paddleHeight / 2)
            ballVelocity.dy += offset * 2
        }

        // Ball collision with AI paddle
        if ballPosition.x >= 500 - 30 - paddleWidth / 2 - ballSize / 2,
           ballPosition.y >= aiPaddleY - paddleHeight / 2,
           ballPosition.y <= aiPaddleY + paddleHeight / 2 {
            ballVelocity.dx = -abs(ballVelocity.dx)
            // Add spin
            let offset = (ballPosition.y - aiPaddleY) / (paddleHeight / 2)
            ballVelocity.dy += offset * 2
        }

        // AI paddle movement (tracks ball)
        let aiSpeed: CGFloat = 3.5
        if aiPaddleY < ballPosition.y - 10 {
            aiPaddleY = min(aiPaddleY + aiSpeed, 600 - paddleHeight / 2)
        } else if aiPaddleY > ballPosition.y + 10 {
            aiPaddleY = max(aiPaddleY - aiSpeed, paddleHeight / 2)
        }

        // Score points
        if ballPosition.x <= 0 {
            aiScore += 1
            checkWin()
            resetBall(in: CGSize(width: 500, height: 600))
        } else if ballPosition.x >= 500 {
            playerScore += 1
            checkWin()
            resetBall(in: CGSize(width: 500, height: 600))
        }
    }

    private func resetBall(in size: CGSize) {
        ballPosition = CGPoint(x: size.width / 2, y: size.height / 2)
        let angle = Double.random(in: -45...45) * .pi / 180
        let speed: CGFloat = 4
        ballVelocity = CGVector(
            dx: Bool.random() ? speed * cos(angle) : -speed * cos(angle),
            dy: speed * sin(angle)
        )
    }

    private func checkWin() {
        if playerScore >= winningScore {
            winner = "You Win!"
            gameOver = true
            gameActive = false
        } else if aiScore >= winningScore {
            winner = "AI Wins!"
            gameOver = true
            gameActive = false
        }
    }
}
