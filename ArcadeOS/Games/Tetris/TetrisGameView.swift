import SwiftUI

struct TetrisGameView: View {
    @State private var grid: [[Color?]] = Array(repeating: Array(repeating: nil, count: 10), count: 20)
    @State private var currentPiece: TetrisPiece?
    @State private var score = 0
    @State private var gameOver = false
    @State private var gameStarted = false

    let cellSize: CGFloat = 20

    var body: some View {
        ZStack {
            Color.black

            VStack(spacing: 20) {
                Text("Score: \(score)")
                    .font(Fonts.stats)
                    .foregroundColor(.white)

                // Game grid
                Canvas { context, size in
                    // Draw placed blocks
                    for row in 0..<20 {
                        for col in 0..<10 {
                            let rect = CGRect(x: CGFloat(col) * cellSize, y: CGFloat(row) * cellSize,
                                            width: cellSize, height: cellSize)

                            if let color = grid[row][col] {
                                context.fill(Path(rect), with: .color(color))
                            }
                            context.stroke(Path(rect), with: .color(.gray.opacity(0.3)), lineWidth: 1)
                        }
                    }

                    // Draw current piece
                    if let piece = currentPiece {
                        for (row, col) in piece.blocks {
                            let rect = CGRect(x: CGFloat(col) * cellSize, y: CGFloat(row) * cellSize,
                                            width: cellSize, height: cellSize)
                            context.fill(Path(rect), with: .color(piece.color))
                        }
                    }
                }
                .frame(width: 10 * cellSize, height: 20 * cellSize)
                .border(Color.white, width: 2)

                // Controls
                if !gameStarted || gameOver {
                    RetroButton(gameOver ? "Play Again" : "Start", isSmall: true) {
                        startGame()
                    }
                    if gameOver {
                        Text("Game Over!")
                            .font(Fonts.button)
                            .foregroundColor(.red)
                    }
                } else {
                    HStack(spacing: 20) {
                        RetroButton("⟲", isSmall: true) {
                            rotatePiece()
                        }
                        RetroButton("←", isSmall: true) {
                            movePiece(dx: -1)
                        }
                        RetroButton("↓", isSmall: true) {
                            movePiece(dy: 1)
                        }
                        RetroButton("→", isSmall: true) {
                            movePiece(dx: 1)
                        }
                    }
                }
            }
        }
        .onReceive(Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()) { _ in
            if gameStarted && !gameOver {
                dropPiece()
            }
        }
    }

    private func startGame() {
        grid = Array(repeating: Array(repeating: nil, count: 10), count: 20)
        score = 0
        gameOver = false
        gameStarted = true
        spawnPiece()
    }

    private func spawnPiece() {
        let shapes = TetrisPiece.allShapes
        currentPiece = TetrisPiece(shape: shapes.randomElement()!, position: (0, 4))

        if !canMove(piece: currentPiece!, dy: 0, dx: 0) {
            gameOver = true
        }
    }

    private func dropPiece() {
        if let piece = currentPiece {
            if canMove(piece: piece, dy: 1, dx: 0) {
                currentPiece?.position.0 += 1
            } else {
                lockPiece()
            }
        }
    }

    private func movePiece(dy: Int = 0, dx: Int = 0) {
        guard let piece = currentPiece, canMove(piece: piece, dy: dy, dx: dx) else { return }
        currentPiece?.position.0 += dy
        currentPiece?.position.1 += dx
    }

    private func rotatePiece() {
        guard var piece = currentPiece else { return }
        piece.rotate()
        if canMove(piece: piece, dy: 0, dx: 0) {
            currentPiece = piece
        }
    }

    private func canMove(piece: TetrisPiece, dy: Int, dx: Int) -> Bool {
        for (row, col) in piece.blocks {
            let newRow = row + dy
            let newCol = col + dx
            if newRow >= 20 || newCol < 0 || newCol >= 10 || (newRow >= 0 && grid[newRow][newCol] != nil) {
                return false
            }
        }
        return true
    }

    private func lockPiece() {
        guard let piece = currentPiece else { return }

        for (row, col) in piece.blocks {
            if row >= 0 {
                grid[row][col] = piece.color
            }
        }

        clearLines()
        spawnPiece()
    }

    private func clearLines() {
        var clearedLines = 0
        for row in (0..<20).reversed() {
            if grid[row].allSatisfy({ $0 != nil }) {
                grid.remove(at: row)
                grid.insert(Array(repeating: nil, count: 10), at: 0)
                clearedLines += 1
            }
        }
        score += clearedLines * 100
    }
}

struct TetrisPiece {
    var shape: [[Bool]]
    var position: (Int, Int)
    var color: Color

    var blocks: [(Int, Int)] {
        var result: [(Int, Int)] = []
        for (i, row) in shape.enumerated() {
            for (j, cell) in row.enumerated() {
                if cell {
                    result.append((position.0 + i, position.1 + j))
                }
            }
        }
        return result
    }

    mutating func rotate() {
        let n = shape.count
        var rotated = Array(repeating: Array(repeating: false, count: n), count: n)
        for i in 0..<n {
            for j in 0..<n {
                rotated[j][n - 1 - i] = shape[i][j]
            }
        }
        shape = rotated
    }

    static let allShapes: [[[Bool]]] = [
        [[true, true, true, true]], // I
        [[true, true], [true, true]], // O
        [[false, true, false], [true, true, true]], // T
        [[true, true, false], [false, true, true]], // S
        [[false, true, true], [true, true, false]], // Z
        [[true, false, false], [true, true, true]], // L
        [[false, false, true], [true, true, true]]  // J
    ]

    init(shape: [[Bool]], position: (Int, Int)) {
        self.shape = shape
        self.position = position
        self.color = [.cyan, .yellow, .purple, .green, .red, .orange, .blue].randomElement()!
    }
}
