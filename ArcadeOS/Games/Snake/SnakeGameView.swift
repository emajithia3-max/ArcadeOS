import SwiftUI

struct SnakeGameView: View {
    @State private var snake: [(x: Int, y: Int)] = [(10, 10)]
    @State private var food: (x: Int, y: Int) = (15, 15)
    @State private var direction: Direction = .right
    @State private var nextDirection: Direction = .right
    @State private var score = 0
    @State private var gameOver = false
    @State private var gameStarted = false

    let gridSize = 20
    let cellSize: CGFloat = 15

    enum Direction {
        case up, down, left, right
    }

    var body: some View {
        ZStack {
            Color.black

            VStack(spacing: 20) {
                // Score
                Text("Score: \(score)")
                    .font(Fonts.stats)
                    .foregroundColor(.green)

                // Game grid
                Canvas { context, size in
                    // Draw snake
                    for segment in snake {
                        let rect = CGRect(
                            x: CGFloat(segment.x) * cellSize,
                            y: CGFloat(segment.y) * cellSize,
                            width: cellSize,
                            height: cellSize
                        )
                        context.fill(Path(rect), with: .color(.green))
                    }

                    // Draw food
                    let foodRect = CGRect(
                        x: CGFloat(food.x) * cellSize,
                        y: CGFloat(food.y) * cellSize,
                        width: cellSize,
                        height: cellSize
                    )
                    context.fill(Path(foodRect), with: .color(.red))
                }
                .frame(width: CGFloat(gridSize) * cellSize, height: CGFloat(gridSize) * cellSize)
                .border(Color.green, width: 2)

                // Controls
                if !gameStarted || gameOver {
                    RetroButton(gameOver ? "Play Again" : "Start", isSmall: true) {
                        startGame()
                    }
                } else {
                    VStack(spacing: 10) {
                        Button(action: { changeDirection(.up) }) {
                            Image(systemName: "arrowtriangle.up.fill")
                                .foregroundColor(.green)
                                .frame(width: 40, height: 40)
                        }

                        HStack(spacing: 20) {
                            Button(action: { changeDirection(.left) }) {
                                Image(systemName: "arrowtriangle.left.fill")
                                    .foregroundColor(.green)
                                    .frame(width: 40, height: 40)
                            }

                            Button(action: { changeDirection(.right) }) {
                                Image(systemName: "arrowtriangle.right.fill")
                                    .foregroundColor(.green)
                                    .frame(width: 40, height: 40)
                            }
                        }

                        Button(action: { changeDirection(.down) }) {
                            Image(systemName: "arrowtriangle.down.fill")
                                .foregroundColor(.green)
                                .frame(width: 40, height: 40)
                        }
                    }
                }

                if gameOver {
                    Text("Game Over!")
                        .font(Fonts.button)
                        .foregroundColor(.red)
                }
            }
        }
        .onReceive(Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()) { _ in
            if gameStarted && !gameOver {
                updateGame()
            }
        }
    }

    private func startGame() {
        snake = [(10, 10)]
        direction = .right
        nextDirection = .right
        score = 0
        gameOver = false
        gameStarted = true
        spawnFood()
    }

    private func changeDirection(_ newDirection: Direction) {
        // Prevent 180-degree turns
        switch (direction, newDirection) {
        case (.up, .down), (.down, .up), (.left, .right), (.right, .left):
            return
        default:
            nextDirection = newDirection
        }
    }

    private func updateGame() {
        direction = nextDirection

        var newHead = snake[0]

        switch direction {
        case .up: newHead.y -= 1
        case .down: newHead.y += 1
        case .left: newHead.x -= 1
        case .right: newHead.x += 1
        }

        // Check wall collision
        if newHead.x < 0 || newHead.x >= gridSize || newHead.y < 0 || newHead.y >= gridSize {
            gameOver = true
            return
        }

        // Check self collision
        if snake.contains(where: { $0.x == newHead.x && $0.y == newHead.y }) {
            gameOver = true
            return
        }

        snake.insert(newHead, at: 0)

        // Check food collision
        if newHead.x == food.x && newHead.y == food.y {
            score += 10
            spawnFood()
        } else {
            snake.removeLast()
        }
    }

    private func spawnFood() {
        repeat {
            food = (Int.random(in: 0..<gridSize), Int.random(in: 0..<gridSize))
        } while snake.contains(where: { $0.x == food.x && $0.y == food.y })
    }
}
