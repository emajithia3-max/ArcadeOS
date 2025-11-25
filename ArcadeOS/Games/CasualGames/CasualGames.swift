import SwiftUI

// MARK: - Memory Match Game
struct MemoryGameView: View {
    @State private var cards: [Card] = []
    @State private var flipped: Set<Int> = []
    @State private var matched: Set<Int> = []
    @State private var score = 0
    @State private var gameStarted = false

    struct Card: Identifiable {
        let id: Int
        let symbol: String
        let pairId: Int
    }

    var body: some View {
        VStack {
            Text("Score: \(score)").font(Fonts.stats).foregroundColor(.white)

            if gameStarted {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(60)), count: 4), spacing: 10) {
                    ForEach(cards) { card in
                        CardView(
                            symbol: card.symbol,
                            isFlipped: flipped.contains(card.id) || matched.contains(card.id),
                            isMatched: matched.contains(card.id)
                        )
                        .onTapGesture { flipCard(card) }
                    }
                }
            } else {
                RetroButton("Start", isSmall: true) { startGame() }
            }
        }
        .padding()
        .background(Color.black)
    }

    struct CardView: View {
        let symbol: String
        let isFlipped: Bool
        let isMatched: Bool

        var body: some View {
            ZStack {
                Rectangle()
                    .fill(isMatched ? Color.green : isFlipped ? Color.white : Color.blue)
                    .frame(width: 60, height: 80)
                    .border(Color.black, width: 2)

                if isFlipped || isMatched {
                    Text(symbol).font(.system(size: 30))
                }
            }
        }
    }

    func startGame() {
        let symbols = ["🎮", "🎯", "🎲", "🎪", "🎨", "🎭", "🎬", "🎸"]
        var deck: [Card] = []
        for (i, symbol) in symbols.enumerated() {
            deck.append(Card(id: i * 2, symbol: symbol, pairId: i))
            deck.append(Card(id: i * 2 + 1, symbol: symbol, pairId: i))
        }
        cards = deck.shuffled()
        flipped = []
        matched = []
        score = 0
        gameStarted = true
    }

    func flipCard(_ card: Card) {
        guard !matched.contains(card.id), flipped.count < 2 else { return }

        flipped.insert(card.id)

        if flipped.count == 2 {
            let flippedCards = cards.filter { flipped.contains($0.id) }
            if flippedCards[0].pairId == flippedCards[1].pairId {
                matched.formUnion(flipped)
                score += 10
                flipped = []
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    flipped = []
                }
            }
        }
    }
}

// MARK: - 2048 Game
struct Game2048View: View {
    @State private var grid: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    @State private var score = 0
    @State private var gameOver = false
    @State private var gameStarted = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Score: \(score)").font(Fonts.stats).foregroundColor(.white)

            if gameStarted {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(70)), count: 4), spacing: 10) {
                    ForEach(0..<16) { index in
                        let row = index / 4
                        let col = index % 4
                        ZStack {
                            Rectangle()
                                .fill(tileColor(grid[row][col]))
                                .frame(width: 70, height: 70)

                            if grid[row][col] > 0 {
                                Text("\(grid[row][col])")
                                    .font(Fonts.button)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }

                HStack(spacing: 20) {
                    VStack {
                        RetroButton("↑", isSmall: true) { move(.up) }
                        HStack {
                            RetroButton("←", isSmall: true) { move(.left) }
                            RetroButton("→", isSmall: true) { move(.right) }
                        }
                        RetroButton("↓", isSmall: true) { move(.down) }
                    }
                }
            } else {
                RetroButton("Start", isSmall: true) { startGame() }
            }

            if gameOver {
                Text("Game Over!").font(Fonts.button).foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.3))
    }

    enum Direction { case up, down, left, right }

    func tileColor(_ value: Int) -> Color {
        switch value {
        case 0: return .gray
        case 2: return Color(hex: "#eee4da")
        case 4: return Color(hex: "#ede0c8")
        case 8: return Color(hex: "#f2b179")
        case 16: return Color(hex: "#f59563")
        case 32: return Color(hex: "#f67c5f")
        default: return .orange
        }
    }

    func startGame() {
        grid = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        score = 0
        gameOver = false
        gameStarted = true
        addRandomTile()
        addRandomTile()
    }

    func addRandomTile() {
        var empty: [(Int, Int)] = []
        for r in 0..<4 {
            for c in 0..<4 {
                if grid[r][c] == 0 { empty.append((r, c)) }
            }
        }
        guard let pos = empty.randomElement() else { return }
        grid[pos.0][pos.1] = Bool.random() ? 2 : 4
    }

    func move(_ dir: Direction) {
        var moved = false
        var newGrid = grid

        for i in 0..<4 {
            var line = [Int]()
            for j in 0..<4 {
                let (r, c) = coords(dir, i, j)
                if grid[r][c] != 0 { line.append(grid[r][c]) }
            }

            var merged = [Int]()
            var skip = false
            for (idx, val) in line.enumerated() {
                if skip {
                    skip = false
                    continue
                }
                if idx < line.count - 1 && val == line[idx + 1] {
                    merged.append(val * 2)
                    score += val * 2
                    skip = true
                    moved = true
                } else {
                    merged.append(val)
                }
            }

            while merged.count < 4 { merged.append(0) }

            for j in 0..<4 {
                let (r, c) = coords(dir, i, j)
                if newGrid[r][c] != merged[j] { moved = true }
                newGrid[r][c] = merged[j]
            }
        }

        if moved {
            grid = newGrid
            addRandomTile()
            checkGameOver()
        }
    }

    func coords(_ dir: Direction, _ i: Int, _ j: Int) -> (Int, Int) {
        switch dir {
        case .up: return (j, i)
        case .down: return (3 - j, i)
        case .left: return (i, j)
        case .right: return (i, 3 - j)
        }
    }

    func checkGameOver() {
        for r in 0..<4 {
            for c in 0..<4 {
                if grid[r][c] == 0 { return }
                if r < 3 && grid[r][c] == grid[r + 1][c] { return }
                if c < 3 && grid[r][c] == grid[r][c + 1] { return }
            }
        }
        gameOver = true
    }
}

// MARK: - Simon Says
struct SimonSaysGameView: View {
    @State private var sequence: [Int] = []
    @State private var playerInput: [Int] = []
    @State private var activeButton: Int? = nil
    @State private var score = 0
    @State private var gameOver = false
    @State private var gameStarted = false
    @State private var showingSequence = false

    let colors: [Color] = [.red, .blue, .green, .yellow]

    var body: some View {
        VStack(spacing: 30) {
            Text("Score: \(score)").font(Fonts.stats).foregroundColor(.white)

            if gameStarted && !gameOver {
                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 20) {
                    ForEach(0..<4) { index in
                        Button(action: { buttonTapped(index) }) {
                            Rectangle()
                                .fill(colors[index].opacity(activeButton == index ? 1 : 0.5))
                                .frame(width: 100, height: 100)
                        }
                        .disabled(showingSequence)
                    }
                }
            } else {
                RetroButton(gameOver ? "Try Again" : "Start", isSmall: true) { startGame() }
            }

            if gameOver {
                Text("Game Over!").font(Fonts.button).foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.black)
    }

    func startGame() {
        sequence = []
        playerInput = []
        score = 0
        gameOver = false
        gameStarted = true
        addToSequence()
    }

    func addToSequence() {
        sequence.append(Int.random(in: 0..<4))
        playerInput = []
        showSequence()
    }

    func showSequence() {
        showingSequence = true
        for (index, button) in sequence.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.6) {
                activeButton = button
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    activeButton = nil
                    if index == sequence.count - 1 {
                        showingSequence = false
                    }
                }
            }
        }
    }

    func buttonTapped(_ button: Int) {
        guard !showingSequence else { return }

        activeButton = button
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            activeButton = nil
        }

        playerInput.append(button)

        if playerInput.last != sequence[playerInput.count - 1] {
            gameOver = true
            return
        }

        if playerInput.count == sequence.count {
            score += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                addToSequence()
            }
        }
    }
}

// MARK: - Whack-a-Mole
struct WhackAMoleGameView: View {
    @State private var moles: [Bool] = Array(repeating: false, count: 9)
    @State private var score = 0
    @State private var timeLeft = 30
    @State private var gameActive = false

    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Text("Score: \(score)").font(Fonts.stats)
                Spacer()
                Text("Time: \(timeLeft)").font(Fonts.stats)
            }
            .foregroundColor(.white)
            .padding()

            if gameActive {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(80)), count: 3), spacing: 20) {
                    ForEach(0..<9) { index in
                        ZStack {
                            Circle()
                                .fill(Color.brown)
                                .frame(width: 80, height: 80)

                            if moles[index] {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 60, height: 60)
                            }
                        }
                        .onTapGesture {
                            if moles[index] {
                                score += 1
                                moles[index] = false
                            }
                        }
                    }
                }
            } else {
                RetroButton(timeLeft == 0 ? "Play Again" : "Start", isSmall: true) { startGame() }
            }
        }
        .padding()
        .background(Color.green.opacity(0.3))
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if gameActive {
                timeLeft -= 1
                if timeLeft <= 0 {
                    gameActive = false
                }
            }
        }
        .onReceive(Timer.publish(every: 0.8, on: .main, in: .common).autoconnect()) { _ in
            if gameActive { spawnMole() }
        }
    }

    func startGame() {
        moles = Array(repeating: false, count: 9)
        score = 0
        timeLeft = 30
        gameActive = true
    }

    func spawnMole() {
        let availableHoles = moles.indices.filter { !moles[$0] }
        if let hole = availableHoles.randomElement() {
            moles[hole] = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                moles[hole] = false
            }
        }
    }
}

// MARK: - Color Match
struct ColorMatchGameView: View {
    @State private var targetColor: Color = .red
    @State private var currentColor: Color = .blue
    @State private var score = 0
    @State private var gameStarted = false
    @State private var lives = 3

    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]

    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Text("Score: \(score)").font(Fonts.stats)
                Spacer()
                Text("Lives: \(lives)").font(Fonts.stats)
            }
            .foregroundColor(.white)
            .padding()

            if gameStarted && lives > 0 {
                VStack(spacing: 20) {
                    Text("Match this color:")
                        .font(Fonts.button)
                        .foregroundColor(.white)

                    Rectangle()
                        .fill(targetColor)
                        .frame(width: 150, height: 150)
                        .border(Color.white, width: 3)

                    Text("Your color:")
                        .font(Fonts.buttonSmall)
                        .foregroundColor(.white)

                    Rectangle()
                        .fill(currentColor)
                        .frame(width: 150, height: 150)
                        .border(Color.white, width: 3)

                    HStack(spacing: 15) {
                        ForEach(colors.indices, id: \.self) { index in
                            Button(action: { selectColor(colors[index]) }) {
                                Circle()
                                    .fill(colors[index])
                                    .frame(width: 40, height: 40)
                            }
                        }
                    }
                }
            } else {
                RetroButton(lives == 0 ? "Try Again" : "Start", isSmall: true) { startGame() }
            }
        }
        .padding()
        .background(Color.black)
    }

    func startGame() {
        score = 0
        lives = 3
        gameStarted = true
        newRound()
    }

    func newRound() {
        targetColor = colors.randomElement()!
        currentColor = colors.randomElement()!
    }

    func selectColor(_ color: Color) {
        if color == targetColor {
            score += 1
            newRound()
        } else {
            lives -= 1
            if lives == 0 {
                gameStarted = false
            }
        }
    }
}
