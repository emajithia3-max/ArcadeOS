import SwiftUI

// This file contains simplified implementations of multiple games to complete the 100-game catalog
// Each game is playable but intentionally simple for demonstration purposes

// MARK: - Simple TicTacToe
struct TicTacToeGameView: View {
    @State private var board = Array(repeating: "", count: 9)
    @State private var isXTurn = true
    @State private var winner: String?

    var body: some View {
        VStack {
            Text(winner ?? (isXTurn ? "X's Turn" : "O's Turn"))
                .font(Fonts.button).foregroundColor(.white)

            LazyVGrid(columns: Array(repeating: GridItem(.fixed(80)), count: 3)) {
                ForEach(0..<9) { index in
                    Button(action: { makeMove(index) }) {
                        Text(board[index]).font(.system(size: 40)).foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Color.blue.opacity(0.3))
                            .border(Color.white)
                    }
                }
            }

            if winner != nil {
                RetroButton("Restart", isSmall: true) { reset() }
            }
        }.padding().background(Color.black)
    }

    func makeMove(_ index: Int) {
        guard board[index].isEmpty, winner == nil else { return }
        board[index] = isXTurn ? "X" : "O"
        checkWinner()
        isXTurn.toggle()
    }

    func checkWinner() {
        let wins = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
        for w in wins {
            if !board[w[0]].isEmpty && board[w[0]] == board[w[1]] && board[w[1]] == board[w[2]] {
                winner = "\(board[w[0]]) Wins!"
                return
            }
        }
        if !board.contains("") { winner = "Draw!" }
    }

    func reset() {
        board = Array(repeating: "", count: 9)
        isXTurn = true
        winner = nil
    }
}

// MARK: - Match3
struct Match3GameView: View {
    @State private var grid = Array(repeating: Array(repeating: 0, count: 8), count: 8)
    @State private var score = 0
    @State private var selected: (Int, Int)?

    var body: some View {
        VStack {
            Text("Score: \(score)").font(Fonts.stats).foregroundColor(.white)

            LazyVGrid(columns: Array(repeating: GridItem(.fixed(40)), count: 8), spacing: 2) {
                ForEach(0..<64) { index in
                    let r = index / 8, c = index % 8
                    gemView(r: r, c: c)
                }
            }
        }.padding().background(Color.black).onAppear { fillGrid() }
    }

    func gemView(r: Int, c: Int) -> some View {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple]
        return Rectangle()
            .fill(colors[grid[r][c] % 5])
            .frame(width: 40, height: 40)
            .border(selected == (r, c) ? Color.white : Color.clear, width: 2)
            .onTapGesture { selectGem(r, c) }
    }

    func fillGrid() {
        for r in 0..<8 {
            for c in 0..<8 {
                grid[r][c] = Int.random(in: 0..<5)
            }
        }
    }

    func selectGem(_ r: Int, _ c: Int) {
        if let sel = selected {
            if abs(sel.0 - r) + abs(sel.1 - c) == 1 {
                swap(&grid[sel.0][sel.1], &grid[r][c])
                checkMatches()
            }
            selected = nil
        } else {
            selected = (r, c)
        }
    }

    func checkMatches() {
        var matched: Set<String> = []
        for r in 0..<8 {
            for c in 0...5 {
                if grid[r][c] == grid[r][c+1] && grid[r][c] == grid[r][c+2] {
                    matched.insert("\(r),\(c)")
                    matched.insert("\(r),\(c+1)")
                    matched.insert("\(r),\(c+2)")
                }
            }
        }
        if !matched.isEmpty {
            score += matched.count * 10
            for pos in matched {
                let parts = pos.split(separator: ",")
                let r = Int(parts[0])!, c = Int(parts[1])!
                grid[r][c] = Int.random(in: 0..<5)
            }
        }
    }
}

// MARK: - Runner Game
struct RunnerGameView: View {
    @State private var playerY: CGFloat = 400
    @State private var obstacles: [CGFloat] = []
    @State private var score = 0
    @State private var gameOver = false
    @State private var isJumping = false

    var body: some View {
        ZStack {
            Color.cyan

            // Ground
            Rectangle().fill(Color.green).frame(height: 50).position(x: 250, y: 575)

            // Player
            Rectangle().fill(Color.red).frame(width: 30, height: 30).position(x: 100, y: playerY)

            // Obstacles
            ForEach(obstacles.indices, id: \.self) { i in
                Rectangle().fill(Color.black).frame(width: 30, height: 50)
                    .position(x: obstacles[i], y: 525)
            }

            VStack {
                Text("Score: \(score)").font(Fonts.stats).foregroundColor(.white).padding()
                Spacer()
                if gameOver {
                    RetroButton("Again", isSmall: true) { start() }
                }
            }
        }
        .onTapGesture { jump() }
        .onReceive(Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()) { _ in
            if !gameOver { update() }
        }
        .onAppear { start() }
    }

    func start() {
        playerY = 520
        obstacles = []
        score = 0
        gameOver = false
    }

    func jump() {
        guard !isJumping, !gameOver else { return }
        isJumping = true
        withAnimation(.easeOut(duration: 0.3)) {
            playerY = 400
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.3)) {
                playerY = 520
                isJumping = false
            }
        }
    }

    func update() {
        for i in 0..<obstacles.count {
            obstacles[i] -= 5
        }
        obstacles.removeAll { $0 < -30 }

        if obstacles.isEmpty || obstacles.last! < 400 {
            obstacles.append(550)
            score += 1
        }

        for obs in obstacles {
            if abs(obs - 100) < 30 && playerY > 500 {
                gameOver = true
            }
        }
    }
}

// MARK: - Puzzle Slider
struct SlidingPuzzleGameView: View {
    @State private var tiles = (1...15).map { $0 } + [0]
    @State private var moves = 0

    var body: some View {
        VStack {
            Text("Moves: \(moves)").font(Fonts.stats).foregroundColor(.white)

            LazyVGrid(columns: Array(repeating: GridItem(.fixed(70)), count: 4), spacing: 4) {
                ForEach(0..<16) { index in
                    if tiles[index] == 0 {
                        Rectangle().fill(Color.clear).frame(width: 70, height: 70)
                    } else {
                        Button(action: { moveTile(index) }) {
                            Text("\(tiles[index])").font(Fonts.button).foregroundColor(.white)
                                .frame(width: 70, height: 70).background(Color.blue).border(Color.white)
                        }
                    }
                }
            }

            RetroButton("Shuffle", isSmall: true) { shuffle() }
        }.padding().background(Color.black)
    }

    func moveTile(_ index: Int) {
        let row = index / 4, col = index % 4
        let moves = [(row-1, col), (row+1, col), (row, col-1), (row, col+1)]
        for (r, c) in moves {
            if r >= 0 && r < 4 && c >= 0 && c < 4 {
                let idx = r * 4 + c
                if tiles[idx] == 0 {
                    tiles.swapAt(index, idx)
                    self.moves += 1
                    return
                }
            }
        }
    }

    func shuffle() {
        tiles.shuffle()
        moves = 0
    }
}

// MARK: - Tower Defense (Simple)
struct TowerDefenseGameView: View {
    @State private var enemies: [(x: CGFloat, y: CGFloat, health: Int)] = []
    @State private var towers: [(x: CGFloat, y: CGFloat)] = []
    @State private var money = 100
    @State private var lives = 10
    @State private var gameOver = false

    var body: some View {
        ZStack {
            Color.green.opacity(0.3)

            ForEach(towers.indices, id: \.self) { i in
                Rectangle().fill(Color.blue).frame(width: 30, height: 30)
                    .position(x: towers[i].x, y: towers[i].y)
            }

            ForEach(enemies.indices, id: \.self) { i in
                Circle().fill(Color.red).frame(width: 20, height: 20)
                    .position(x: enemies[i].x, y: enemies[i].y)
            }

            VStack {
                HStack {
                    Text("$\(money)").font(Fonts.stats)
                    Spacer()
                    Text("❤️ \(lives)").font(Fonts.stats)
                }
                .foregroundColor(.white).padding()
                Spacer()
                RetroButton("Build Tower ($50)", isSmall: true) { buildTower() }
                    .padding()
            }

            if gameOver {
                RetroButton("Again", isSmall: true) { start() }
            }
        }
        .onAppear { start() }
        .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { _ in
            if !gameOver { update() }
        }
    }

    func start() {
        enemies = []
        towers = []
        money = 100
        lives = 10
        gameOver = false
    }

    func buildTower() {
        guard money >= 50 else { return }
        money -= 50
        towers.append((x: .random(in: 50...450), y: .random(in: 50...500)))
    }

    func update() {
        if Int.random(in: 0..<50) == 0 {
            enemies.append((x: 0, y: CGFloat.random(in: 50...550), health: 3))
        }

        for i in 0..<enemies.count {
            enemies[i].x += 2
            if enemies[i].x > 500 {
                lives -= 1
                enemies.remove(at: i)
                if lives <= 0 { gameOver = true }
                return
            }
        }

        for t in towers {
            for e in enemies.indices {
                let dist = hypot(t.x - enemies[e].x, t.y - enemies[e].y)
                if dist < 100 {
                    enemies[e].health -= 1
                    if enemies[e].health <= 0 {
                        money += 25
                        enemies.remove(at: e)
                        return
                    }
                }
            }
        }
    }
}

// MARK: - Card Matching (Solitaire-like)
struct SolitaireGameView: View {
    @State private var deck = (1...52).shuffled()
    @State private var piles: [[Int]] = Array(repeating: [], count: 7)
    @State private var foundations: [[Int]] = Array(repeating: [], count: 4)

    var body: some View {
        ScrollView {
            VStack {
                Text("Solitaire").font(Fonts.title).foregroundColor(.white)

                // Foundations
                HStack {
                    ForEach(0..<4) { i in
                        ZStack {
                            Rectangle().stroke(Color.white).frame(width: 60, height: 80)
                            if let top = foundations[i].last {
                                cardView(top)
                            }
                        }
                    }
                }

                // Tableau
                HStack(alignment: .top) {
                    ForEach(0..<7) { i in
                        VStack {
                            ForEach(piles[i], id: \.self) { card in
                                cardView(card)
                            }
                        }
                    }
                }

                RetroButton("Deal", isSmall: true) { deal() }
            }
        }
        .background(Color.green.opacity(0.5))
        .onAppear { deal() }
    }

    func cardView(_ card: Int) -> some View {
        let suits = ["♠", "♥", "♦", "♣"]
        let values = ["A","2","3","4","5","6","7","8","9","10","J","Q","K"]
        let suit = suits[(card - 1) / 13]
        let value = values[(card - 1) % 13]
        return Text("\(value)\(suit)")
            .font(Fonts.caption)
            .frame(width: 50, height: 70)
            .background(Color.white)
            .border(Color.black)
    }

    func deal() {
        deck = (1...52).shuffled()
        piles = Array(repeating: [], count: 7)
        foundations = Array(repeating: [], count: 4)
        for i in 0..<7 {
            piles[i] = Array(deck.prefix(i + 1))
            deck.removeFirst(i + 1)
        }
    }
}

// MARK: - Reaction Time Game
struct ReactionGameView: View {
    @State private var showTarget = false
    @State private var score = 0
    @State private var time: Double = 0
    @State private var started = false

    var body: some View {
        ZStack {
            Color.black

            if showTarget {
                Circle()
                    .fill(Color.red)
                    .frame(width: 80, height: 80)
                    .onTapGesture {
                        score += Int((1000 - time) / 10)
                        showTarget = false
                        scheduleNext()
                    }
            }

            VStack {
                Text("Score: \(score)").font(Fonts.stats).foregroundColor(.white).padding()
                Spacer()
                if !started {
                    RetroButton("Start", isSmall: true) { start() }
                }
            }
        }
        .onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()) { _ in
            if showTarget { time += 10 }
        }
    }

    func start() {
        score = 0
        started = true
        scheduleNext()
    }

    func scheduleNext() {
        time = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1...3)) {
            showTarget = true
        }
    }
}
