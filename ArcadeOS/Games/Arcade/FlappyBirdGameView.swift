import SwiftUI

struct FlappyBirdGameView: View {
    @State private var birdY: CGFloat = 300
    @State private var birdVelocity: CGFloat = 0
    @State private var pipes: [(x: CGFloat, gapY: CGFloat)] = []
    @State private var score = 0
    @State private var gameActive = false
    @State private var gameOver = false

    let gravity: CGFloat = 0.6
    let jumpForce: CGFloat = -12
    let birdSize: CGFloat = 30
    let pipeWidth: CGFloat = 60
    let gapHeight: CGFloat = 150

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Sky
                LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom)

                // Pipes
                ForEach(pipes.indices, id: \.self) { index in
                    let pipe = pipes[index]

                    // Top pipe
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: pipeWidth, height: pipe.gapY)
                        .position(x: pipe.x, y: pipe.gapY / 2)

                    // Bottom pipe
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: pipeWidth, height: geometry.size.height - pipe.gapY - gapHeight)
                        .position(x: pipe.x, y: pipe.gapY + gapHeight + (geometry.size.height - pipe.gapY - gapHeight) / 2)
                }

                // Bird
                Circle()
                    .fill(Color.yellow)
                    .frame(width: birdSize, height: birdSize)
                    .position(x: 100, y: birdY)

                // Score
                VStack {
                    Text("Score: \(score)")
                        .font(Fonts.stats)
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                }

                // Game state
                if !gameActive || gameOver {
                    VStack {
                        if gameOver {
                            Text("Game Over!")
                                .font(Fonts.title)
                                .foregroundColor(.red)
                        }
                        RetroButton(gameOver ? "Play Again" : "Tap to Start", isSmall: true) {
                            startGame()
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if gameActive && !gameOver {
                    birdVelocity = jumpForce
                }
            }
        }
        .onReceive(Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()) { _ in
            if gameActive && !gameOver {
                updateGame()
            }
        }
    }

    private func startGame() {
        birdY = 300
        birdVelocity = 0
        pipes = []
        score = 0
        gameOver = false
        gameActive = true
    }

    private func updateGame() {
        // Bird physics
        birdVelocity += gravity
        birdY += birdVelocity

        // Check bounds
        if birdY <= 0 || birdY >= 600 {
            gameOver = true
            return
        }

        // Move pipes
        for i in 0..<pipes.count {
            pipes[i].x -= 3
        }

        // Remove off-screen pipes
        pipes.removeAll { $0.x < -pipeWidth }

        // Spawn new pipes
        if pipes.isEmpty || pipes.last!.x < 300 {
            pipes.append((x: 500, gapY: CGFloat.random(in: 100...400)))
        }

        // Check collisions
        for pipe in pipes {
            if abs(100 - pipe.x) < (birdSize + pipeWidth) / 2 {
                if birdY < pipe.gapY || birdY > pipe.gapY + gapHeight {
                    gameOver = true
                    return
                }
                // Score if passing pipe center
                if abs(100 - pipe.x) < 2 {
                    score += 1
                }
            }
        }
    }
}
