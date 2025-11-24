import SwiftUI

// MARK: - Space Invaders
struct InvadersGameView: View {
    @State private var playerX: CGFloat = 225
    @State private var enemies: [(x: CGFloat, y: CGFloat)] = []
    @State private var bullets: [(x: CGFloat, y: CGFloat)] = []
    @State private var score = 0
    @State private var gameOver = false
    @State private var gameStarted = false
    @State private var enemyDirection: CGFloat = 1

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black

                // Player
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 40, height: 20)
                    .position(x: playerX, y: geo.size.height - 50)

                // Enemies
                ForEach(enemies.indices, id: \.self) { i in
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 30, height: 20)
                        .position(x: enemies[i].x, y: enemies[i].y)
                }

                // Bullets
                ForEach(bullets.indices, id: \.self) { i in
                    Rectangle()
                        .fill(Color.yellow)
                        .frame(width: 4, height: 15)
                        .position(x: bullets[i].x, y: bullets[i].y)
                }

                VStack {
                    Text("Score: \(score)")
                        .font(Fonts.stats)
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                }

                if !gameStarted || gameOver {
                    VStack {
                        if gameOver {
                            Text(enemies.isEmpty ? "You Win!" : "Game Over")
                                .font(Fonts.title)
                                .foregroundColor(enemies.isEmpty ? .green : .red)
                        }
                        RetroButton("Start", isSmall: true) { startGame() }
                    }
                }
            }
            .gesture(DragGesture(minimumDistance: 0).onChanged { playerX = $0.location.x })
            .onTapGesture { if gameStarted && !gameOver { shoot() } }
        }
        .onReceive(Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()) { _ in
            if gameStarted && !gameOver { updateGame() }
        }
    }

    func startGame() {
        playerX = 225
        score = 0
        gameOver = false
        gameStarted = true
        bullets = []
        enemies = []
        for row in 0..<4 {
            for col in 0..<8 {
                enemies.append((x: CGFloat(col * 50 + 60), y: CGFloat(row * 40 + 50)))
            }
        }
    }

    func shoot() {
        bullets.append((x: playerX, y: 550))
    }

    func updateGame() {
        // Move bullets
        for i in (0..<bullets.count).reversed() {
            bullets[i].y -= 5
            if bullets[i].y < 0 { bullets.remove(at: i) }
        }

        // Move enemies
        var moveDown = false
        for i in 0..<enemies.count {
            enemies[i].x += enemyDirection
            if enemies[i].x < 20 || enemies[i].x > 480 {
                moveDown = true
            }
        }
        if moveDown {
            enemyDirection *= -1
            for i in 0..<enemies.count {
                enemies[i].y += 20
                if enemies[i].y > 550 { gameOver = true }
            }
        }

        // Check collisions
        for b in (0..<bullets.count).reversed() {
            for e in (0..<enemies.count).reversed() {
                if abs(bullets[b].x - enemies[e].x) < 30 && abs(bullets[b].y - enemies[e].y) < 20 {
                    enemies.remove(at: e)
                    bullets.remove(at: b)
                    score += 10
                    if enemies.isEmpty {
                        gameOver = true
                    }
                    break
                }
            }
        }
    }
}

// MARK: - Asteroids
struct AsteroidsGameView: View {
    @State private var shipAngle: Double = 0
    @State private var shipPos = CGPoint(x: 250, y: 300)
    @State private var shipVel = CGVector.zero
    @State private var asteroids: [(pos: CGPoint, vel: CGVector, size: CGFloat)] = []
    @State private var bullets: [(pos: CGPoint, vel: CGVector)] = []
    @State private var score = 0
    @State private var gameOver = false
    @State private var gameStarted = false

    var body: some View {
        ZStack {
            Color.black

            // Ship
            Path { path in
                path.move(to: CGPoint(x: 0, y: -15))
                path.addLine(to: CGPoint(x: -10, y: 10))
                path.addLine(to: CGPoint(x: 10, y: 10))
                path.closeSubpath()
            }
            .fill(Color.white)
            .rotationEffect(.degrees(shipAngle))
            .position(shipPos)

            // Asteroids
            ForEach(asteroids.indices, id: \.self) { i in
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: asteroids[i].size, height: asteroids[i].size)
                    .position(asteroids[i].pos)
            }

            // Bullets
            ForEach(bullets.indices, id: \.self) { i in
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 4, height: 4)
                    .position(bullets[i].pos)
            }

            VStack {
                Text("Score: \(score)")
                    .font(Fonts.stats)
                    .foregroundColor(.white)
                Spacer()
                HStack {
                    RetroButton("◀", isSmall: true) { shipAngle -= 15 }
                    RetroButton("▲", isSmall: true) { thrust() }
                    RetroButton("▶", isSmall: true) { shipAngle += 15 }
                    RetroButton("•", isSmall: true) { shoot() }
                }
                .padding()
            }

            if !gameStarted || gameOver {
                RetroButton(gameOver ? "Again" : "Start", isSmall: true) { startGame() }
            }
        }
        .onReceive(Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()) { _ in
            if gameStarted && !gameOver { updateGame() }
        }
    }

    func startGame() {
        shipPos = CGPoint(x: 250, y: 300)
        shipVel = .zero
        shipAngle = 0
        score = 0
        gameOver = false
        gameStarted = true
        bullets = []
        asteroids = (0..<5).map { _ in
            (pos: CGPoint(x: .random(in: 50...450), y: .random(in: 50...550)),
             vel: CGVector(dx: .random(in: -2...2), dy: .random(in: -2...2)),
             size: 50)
        }
    }

    func thrust() {
        let rad = shipAngle * .pi / 180
        shipVel.dx += sin(rad) * 0.5
        shipVel.dy -= cos(rad) * 0.5
    }

    func shoot() {
        let rad = shipAngle * .pi / 180
        bullets.append((
            pos: shipPos,
            vel: CGVector(dx: sin(rad) * 8, dy: -cos(rad) * 8)
        ))
    }

    func updateGame() {
        // Update ship
        shipPos.x += shipVel.dx
        shipPos.y += shipVel.dy
        if shipPos.x < 0 { shipPos.x = 500 }
        if shipPos.x > 500 { shipPos.x = 0 }
        if shipPos.y < 0 { shipPos.y = 600 }
        if shipPos.y > 600 { shipPos.y = 0 }

        // Update asteroids
        for i in 0..<asteroids.count {
            asteroids[i].pos.x += asteroids[i].vel.dx
            asteroids[i].pos.y += asteroids[i].vel.dy
            if asteroids[i].pos.x < 0 { asteroids[i].pos.x = 500 }
            if asteroids[i].pos.x > 500 { asteroids[i].pos.x = 0 }
            if asteroids[i].pos.y < 0 { asteroids[i].pos.y = 600 }
            if asteroids[i].pos.y > 600 { asteroids[i].pos.y = 0 }

            // Check ship collision
            let dist = hypot(asteroids[i].pos.x - shipPos.x, asteroids[i].pos.y - shipPos.y)
            if dist < asteroids[i].size / 2 + 15 {
                gameOver = true
            }
        }

        // Update bullets
        for i in (0..<bullets.count).reversed() {
            bullets[i].pos.x += bullets[i].vel.dx
            bullets[i].pos.y += bullets[i].vel.dy
            if bullets[i].pos.x < 0 || bullets[i].pos.x > 500 || bullets[i].pos.y < 0 || bullets[i].pos.y > 600 {
                bullets.remove(at: i)
            }
        }

        // Check bullet collisions
        for b in (0..<bullets.count).reversed() {
            for a in (0..<asteroids.count).reversed() {
                let dist = hypot(bullets[b].pos.x - asteroids[a].pos.x, bullets[b].pos.y - asteroids[a].pos.y)
                if dist < asteroids[a].size / 2 {
                    score += 10
                    if asteroids[a].size > 25 {
                        // Split asteroid
                        let newSize = asteroids[a].size / 2
                        asteroids.append((pos: asteroids[a].pos, vel: CGVector(dx: .random(in: -2...2), dy: .random(in: -2...2)), size: newSize))
                        asteroids.append((pos: asteroids[a].pos, vel: CGVector(dx: .random(in: -2...2), dy: .random(in: -2...2)), size: newSize))
                    }
                    asteroids.remove(at: a)
                    bullets.remove(at: b)
                    break
                }
            }
        }
    }
}

// MARK: - Minesweeper
struct MinesweeperGameView: View {
    @State private var grid: [[CellState]] = []
    @State private var revealed: [[Bool]] = []
    @State private var flagged: [[Bool]] = []
    @State private var gameOver = false
    @State private var gameWon = false
    @State private var gameStarted = false

    let gridSize = 10
    let mineCount = 15

    enum CellState {
        case mine
        case number(Int)
        case empty
    }

    var body: some View {
        VStack {
            Text(gameWon ? "You Win!" : gameOver ? "Game Over" : "Minesweeper")
                .font(Fonts.button)
                .foregroundColor(gameWon ? .green : gameOver ? .red : .white)

            if gameStarted {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(30)), count: gridSize), spacing: 2) {
                    ForEach(0..<gridSize * gridSize, id: \.self) { index in
                        let row = index / gridSize
                        let col = index % gridSize
                        cellView(row: row, col: col)
                    }
                }
            } else {
                RetroButton("Start Game", isSmall: true) { startGame() }
            }
        }
        .padding()
        .background(Color.gray)
    }

    func cellView(row: Int, col: Int) -> some View {
        ZStack {
            Rectangle()
                .fill(revealed[row][col] ? Color.white : Color.gray)
                .frame(width: 30, height: 30)
                .border(Color.black)

            if flagged[row][col] {
                Text("🚩")
                    .font(.system(size: 20))
            } else if revealed[row][col] {
                switch grid[row][col] {
                case .mine:
                    Text("💣").font(.system(size: 20))
                case .number(let n) where n > 0:
                    Text("\(n)").font(Fonts.caption).foregroundColor(.blue)
                default:
                    EmptyView()
                }
            }
        }
        .onTapGesture { revealCell(row: row, col: col) }
        .onLongPressGesture { toggleFlag(row: row, col: col) }
    }

    func startGame() {
        grid = Array(repeating: Array(repeating: .empty, count: gridSize), count: gridSize)
        revealed = Array(repeating: Array(repeating: false, count: gridSize), count: gridSize)
        flagged = Array(repeating: Array(repeating: false, count: gridSize), count: gridSize)
        gameOver = false
        gameWon = false
        gameStarted = true

        // Place mines
        var minesPlaced = 0
        while minesPlaced < mineCount {
            let r = Int.random(in: 0..<gridSize)
            let c = Int.random(in: 0..<gridSize)
            if case .empty = grid[r][c] {
                grid[r][c] = .mine
                minesPlaced += 1
            }
        }

        // Calculate numbers
        for r in 0..<gridSize {
            for c in 0..<gridSize {
                if case .mine = grid[r][c] { continue }
                var count = 0
                for dr in -1...1 {
                    for dc in -1...1 {
                        let nr = r + dr, nc = c + dc
                        if nr >= 0, nr < gridSize, nc >= 0, nc < gridSize,
                           case .mine = grid[nr][nc] {
                            count += 1
                        }
                    }
                }
                grid[r][c] = count > 0 ? .number(count) : .empty
            }
        }
    }

    func revealCell(row: Int, col: Int) {
        guard !gameOver, !gameWon, !revealed[row][col], !flagged[row][col] else { return }

        revealed[row][col] = true

        if case .mine = grid[row][col] {
            gameOver = true
            return
        }

        if case .empty = grid[row][col] {
            for dr in -1...1 {
                for dc in -1...1 {
                    let nr = row + dr, nc = col + dc
                    if nr >= 0, nr < gridSize, nc >= 0, nc < gridSize, !revealed[nr][nc] {
                        revealCell(row: nr, col: nc)
                    }
                }
            }
        }

        checkWin()
    }

    func toggleFlag(row: Int, col: Int) {
        guard !revealed[row][col], !gameOver, !gameWon else { return }
        flagged[row][col].toggle()
    }

    func checkWin() {
        for r in 0..<gridSize {
            for c in 0..<gridSize {
                if case .mine = grid[r][c] { continue }
                if !revealed[r][c] { return }
            }
        }
        gameWon = true
    }
}
