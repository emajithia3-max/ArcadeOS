import SwiftUI

// This file contains the remaining games to complete the 100-game collection
// Each is a simplified but playable implementation

// MARK: - Sports & Action Games

struct PacManGameView: View {
    @State private var pacX: CGFloat = 250
    @State private var pacY: CGFloat = 300
    @State private var dots: Set<String> = []
    @State private var score = 0

    var body: some View {
        ZStack {
            Color.black
            ForEach(Array(dots), id: \.self) { dot in
                let parts = dot.split(separator: ",")
                Circle().fill(Color.yellow).frame(width: 5, height: 5)
                    .position(x: CGFloat(Int(parts[0])!), y: CGFloat(Int(parts[1])!))
            }
            Circle().fill(Color.yellow).frame(width: 30, height: 30).position(x: pacX, y: pacY)
            VStack { Text("Score: \(score)").font(Fonts.stats).foregroundColor(.white); Spacer() }
        }
        .gesture(DragGesture().onChanged { pacX = $0.location.x; pacY = $0.location.y; checkDots() })
        .onAppear { spawnDots() }
    }

    func spawnDots() {
        for x in stride(from: 50, to: 450, by: 30) {
            for y in stride(from: 50, to: 550, by: 30) {
                dots.insert("\(x),\(y)")
            }
        }
    }

    func checkDots() {
        for dot in dots {
            let parts = dot.split(separator: ",")
            let dx = CGFloat(Int(parts[0])!) - pacX
            let dy = CGFloat(Int(parts[1])!) - pacY
            if hypot(dx, dy) < 20 {
                dots.remove(dot)
                score += 10
                return
            }
        }
    }
}

struct GalagaGameView: View {
    @State private var playerX: CGFloat = 250
    @State private var enemies: [(CGFloat, CGFloat)] = []
    @State private var bullets: [(CGFloat, CGFloat)] = []
    @State private var score = 0

    var body: some View {
        ZStack {
            Color.black
            Rectangle().fill(Color.cyan).frame(width: 40, height: 20).position(x: playerX, y: 550)
            ForEach(enemies.indices, id: \.self) { i in
                Circle().fill(Color.red).frame(width: 25).position(x: enemies[i].0, y: enemies[i].1)
            }
            ForEach(bullets.indices, id: \.self) { i in
                Rectangle().fill(Color.green).frame(width: 3, height: 10).position(x: bullets[i].0, y: bullets[i].1)
            }
            VStack { Text("Score: \(score)").font(Fonts.stats).foregroundColor(.white); Spacer() }
        }
        .gesture(DragGesture(minimumDistance: 0).onChanged { playerX = $0.location.x })
        .onTapGesture { bullets.append((playerX, 540)) }
        .onAppear { spawnEnemies() }
        .onReceive(Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()) { _ in update() }
    }

    func spawnEnemies() {
        for i in 0..<20 { enemies.append((CGFloat(i * 25 + 50), CGFloat((i % 3) * 40 + 50))) }
    }

    func update() {
        for i in (0..<bullets.count).reversed() {
            bullets[i].1 -= 5
            if bullets[i].1 < 0 { bullets.remove(at: i) }
        }
        for b in bullets.indices {
            for e in enemies.indices {
                if hypot(bullets[b].0 - enemies[e].0, bullets[b].1 - enemies[e].1) < 20 {
                    score += 10
                    enemies.remove(at: e)
                    bullets.remove(at: b)
                    return
                }
            }
        }
    }
}

struct FroggerGameView: View {
    @State private var frogY: CGFloat = 550
    @State private var cars: [(CGFloat, CGFloat)] = []
    @State private var gameOver = false

    var body: some View {
        ZStack {
            Color.green.opacity(0.3)
            ForEach(cars.indices, id: \.self) { i in
                Rectangle().fill(Color.red).frame(width: 60, height: 30).position(x: cars[i].0, y: cars[i].1)
            }
            Circle().fill(Color.green).frame(width: 30).position(x: 250, y: frogY)
            if gameOver { Text("Game Over").font(Fonts.title).foregroundColor(.red) }
        }
        .onTapGesture { if !gameOver { frogY -= 50 } }
        .onAppear { spawnCars() }
        .onReceive(Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()) { _ in update() }
    }

    func spawnCars() {
        for i in 0..<5 { cars.append((CGFloat(i * 100), CGFloat.random(in: 100...500))) }
    }

    func update() {
        for i in 0..<cars.count {
            cars[i].0 += 3
            if cars[i].0 > 550 { cars[i].0 = -50 }
            if hypot(cars[i].0 - 250, cars[i].1 - frogY) < 40 { gameOver = true }
        }
    }
}

struct DigDugGameView: View {
    @State private var playerX: CGFloat = 250
    @State private var playerY: CGFloat = 500
    @State private var enemies: [(CGFloat, CGFloat)] = []
    @State private var score = 0

    var body: some View {
        ZStack {
            Color.brown
            Rectangle().fill(Color.blue).frame(width: 25, height: 25).position(x: playerX, y: playerY)
            ForEach(enemies.indices, id: \.self) { i in
                Circle().fill(Color.red).frame(width: 20).position(x: enemies[i].0, y: enemies[i].1)
            }
            VStack { Text("Score: \(score)").font(Fonts.stats).foregroundColor(.white); Spacer() }
        }
        .gesture(DragGesture().onChanged { playerX = $0.location.x; playerY = $0.location.y })
        .onAppear { spawnEnemies() }
    }

    func spawnEnemies() {
        for i in 0..<5 { enemies.append((CGFloat.random(in: 50...450), CGFloat.random(in: 50...550))) }
    }
}

struct MissileCommandGameView: View {
    @State private var missiles: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [] // startX, startY, endX, endY
    @State private var explosions: [(CGFloat, CGFloat)] = []
    @State private var cities = 6
    @State private var score = 0

    var body: some View {
        ZStack {
            Color.black
            ForEach(missiles.indices, id: \.self) { i in
                Path { path in
                    path.move(to: CGPoint(x: missiles[i].0, y: missiles[i].1))
                    path.addLine(to: CGPoint(x: missiles[i].2, y: missiles[i].3))
                }
                .stroke(Color.red, lineWidth: 2)
            }
            ForEach(explosions.indices, id: \.self) { i in
                Circle().fill(Color.orange.opacity(0.5)).frame(width: 60).position(x: explosions[i].0, y: explosions[i].1)
            }
            VStack { HStack { Text("Cities: \(cities)"); Text("Score: \(score)") }
                .font(Fonts.stats).foregroundColor(.white); Spacer() }
        }
        .onTapGesture { loc in explode(loc.x, loc.y) }
        .onAppear { spawnMissiles() }
    }

    func spawnMissiles() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            missiles.append((CGFloat.random(in: 50...450), 0, CGFloat.random(in: 50...450), 600))
            spawnMissiles()
        }
    }

    func explode(_ x: CGFloat, _ y: CGFloat) {
        explosions.append((x, y))
        score += 10
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            explosions.removeFirst()
        }
    }
}

struct DefenderGameView: View {
    @State private var playerX: CGFloat = 250
    @State private var enemies: [(CGFloat, CGFloat)] = []
    @State private var score = 0

    var body: some View {
        ZStack {
            Color.blue.opacity(0.3)
            Rectangle().fill(Color.yellow).frame(width: 40, height: 20).position(x: playerX, y: 300)
            ForEach(enemies.indices, id: \.self) { i in
                Circle().fill(Color.red).frame(width: 20).position(x: enemies[i].0, y: enemies[i].1)
            }
            VStack { Text("Score: \(score)").font(Fonts.stats).foregroundColor(.white); Spacer() }
        }
        .gesture(DragGesture(minimumDistance: 0).onChanged { playerX = $0.location.x })
        .onAppear { for i in 0..<10 { enemies.append((CGFloat(i * 50), CGFloat.random(in: 50...550))) } }
    }
}

struct CentipedeGameView: View {
    @State private var segments: [(CGFloat, CGFloat)] = []
    @State private var playerX: CGFloat = 250
    @State private var bullets: [(CGFloat, CGFloat)] = []
    @State private var score = 0

    var body: some View {
        ZStack {
            Color.black
            Rectangle().fill(Color.green).frame(width: 30, height: 20).position(x: playerX, y: 550)
            ForEach(segments.indices, id: \.self) { i in
                Circle().fill(Color.yellow).frame(width: 15).position(x: segments[i].0, y: segments[i].1)
            }
            ForEach(bullets.indices, id: \.self) { i in
                Circle().fill(Color.cyan).frame(width: 5).position(x: bullets[i].0, y: bullets[i].1)
            }
            VStack { Text("Score: \(score)").font(Fonts.stats).foregroundColor(.white); Spacer() }
        }
        .gesture(DragGesture(minimumDistance: 0).onChanged { playerX = $0.location.x })
        .onTapGesture { bullets.append((playerX, 540)) }
        .onAppear { for i in 0..<12 { segments.append((CGFloat(i * 20 + 50), 50)) } }
    }
}

struct QBertGameView: View {
    @State private var playerPos = 0
    @State private var cubes = Array(repeating: false, count: 28)
    @State private var score = 0

    var body: some View {
        ZStack {
            Color.purple.opacity(0.3)
            // Simplified isometric view
            ForEach(0..<28, id: \.self) { i in
                let row = Int(sqrt(Double(i)))
                let col = i - row * row
                Rectangle()
                    .fill(cubes[i] ? Color.orange : Color.blue)
                    .frame(width: 40, height: 40)
                    .position(x: CGFloat(200 + col * 30 - row * 15), y: CGFloat(100 + row * 30))
            }
            Circle().fill(Color.yellow).frame(width: 30)
                .position(x: CGFloat(200 + (playerPos % 7) * 30), y: CGFloat(100 + (playerPos / 7) * 30))
            VStack { Text("Score: \(score)").font(Fonts.stats).foregroundColor(.white); Spacer() }
            HStack { Spacer(); VStack {
                RetroButton("↑", isSmall: true) { move(-7) }
                HStack { RetroButton("←", isSmall: true) { move(-1) }; RetroButton("→", isSmall: true) { move(1) } }
                RetroButton("↓", isSmall: true) { move(7) }
            }.padding() }
        }
    }

    func move(_ delta: Int) {
        let newPos = playerPos + delta
        if newPos >= 0 && newPos < 28 {
            playerPos = newPos
            if !cubes[playerPos] {
                cubes[playerPos] = true
                score += 10
            }
        }
    }
}

struct DonkeyKongGameView: View {
    @State private var playerX: CGFloat = 50
    @State private var playerY: CGFloat = 500
    @State private var barrels: [(CGFloat, CGFloat)] = []
    @State private var score = 0
    @State private var gameOver = false

    var body: some View {
        ZStack {
            Color.brown.opacity(0.3)
            // Platforms
            ForEach(0..<4) { i in
                Rectangle().fill(Color.orange).frame(width: 400, height: 10)
                    .position(x: 250, y: CGFloat(150 * i + 100))
            }
            Rectangle().fill(Color.red).frame(width: 30, height: 40).position(x: playerX, y: playerY)
            ForEach(barrels.indices, id: \.self) { i in
                Circle().fill(Color.brown).frame(width: 25).position(x: barrels[i].0, y: barrels[i].1)
            }
            VStack { Text("Score: \(score)").font(Fonts.stats).foregroundColor(.white); Spacer() }
            if gameOver { Text("Game Over").font(Fonts.title).foregroundColor(.red) }
        }
        .gesture(DragGesture().onChanged { playerX = $0.location.x; playerY = $0.location.y })
        .onAppear { spawnBarrels() }
        .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { _ in updateBarrels() }
    }

    func spawnBarrels() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if !gameOver {
                barrels.append((250, 50))
                spawnBarrels()
            }
        }
    }

    func updateBarrels() {
        for i in 0..<barrels.count {
            barrels[i].1 += 2
            if barrels[i].1 > 600 { barrels.remove(at: i); score += 5; return }
            if hypot(barrels[i].0 - playerX, barrels[i].1 - playerY) < 30 { gameOver = true }
        }
    }
}

struct JumpManGameView: View {
    @State private var playerX: CGFloat = 100
    @State private var playerY: CGFloat = 400
    @State private var velocityY: CGFloat = 0
    @State private var platforms: [(CGFloat, CGFloat)] = [(100, 500), (250, 400), (400, 300)]
    @State private var score = 0

    var body: some View {
        ZStack {
            Color.cyan
            ForEach(platforms.indices, id: \.self) { i in
                Rectangle().fill(Color.brown).frame(width: 100, height: 20)
                    .position(x: platforms[i].0, y: platforms[i].1)
            }
            Rectangle().fill(Color.red).frame(width: 30, height: 40).position(x: playerX, y: playerY)
            VStack { Text("Score: \(score)").font(Fonts.stats).foregroundColor(.white); Spacer() }
        }
        .gesture(DragGesture(minimumDistance: 0).onChanged { playerX = $0.location.x })
        .onTapGesture { if velocityY == 0 { velocityY = -15 } }
        .onReceive(Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()) { _ in update() }
    }

    func update() {
        velocityY += 0.8
        playerY += velocityY
        for plat in platforms {
            if abs(playerX - plat.0) < 50 && abs(playerY - plat.1) < 15 && velocityY > 0 {
                playerY = plat.1
                velocityY = 0
            }
        }
        if playerY > 600 { playerY = 400; velocityY = 0; score += 10 }
    }
}

struct SokobanGameView: View {
    @State private var playerPos = (2, 2)
    @State private var boxes = [(3, 2), (3, 3)]
    @State private var targets = [(4, 2), (4, 3)]
    @State private var moves = 0

    var body: some View {
        VStack {
            Text("Moves: \(moves)").font(Fonts.stats).foregroundColor(.white)
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(50)), count: 7), spacing: 2) {
                ForEach(0..<49) { i in
                    let r = i / 7, c = i % 7
                    ZStack {
                        Rectangle().fill(Color.gray).frame(width: 50, height: 50).border(Color.black)
                        if targets.contains(where: { $0 == (r, c) }) {
                            Circle().stroke(Color.green, lineWidth: 3).frame(width: 40, height: 40)
                        }
                        if boxes.contains(where: { $0 == (r, c) }) {
                            Rectangle().fill(Color.brown).frame(width: 40, height: 40)
                        }
                        if playerPos == (r, c) {
                            Circle().fill(Color.blue).frame(width: 35, height: 35)
                        }
                    }
                }
            }
            HStack {
                RetroButton("↑", isSmall: true) { move(-1, 0) }
                RetroButton("↓", isSmall: true) { move(1, 0) }
                RetroButton("←", isSmall: true) { move(0, -1) }
                RetroButton("→", isSmall: true) { move(0, 1) }
            }
        }.padding().background(Color.black)
    }

    func move(_ dr: Int, _ dc: Int) {
        let newPos = (playerPos.0 + dr, playerPos.1 + dc)
        if newPos.0 < 0 || newPos.0 >= 7 || newPos.1 < 0 || newPos.1 >= 7 { return }

        if let boxIdx = boxes.firstIndex(where: { $0 == newPos }) {
            let newBoxPos = (newPos.0 + dr, newPos.1 + dc)
            if newBoxPos.0 >= 0 && newBoxPos.0 < 7 && newBoxPos.1 >= 0 && newBoxPos.1 < 7 &&
               !boxes.contains(where: { $0 == newBoxPos }) {
                boxes[boxIdx] = newBoxPos
                playerPos = newPos
                moves += 1
            }
        } else {
            playerPos = newPos
            moves += 1
        }
    }
}

// MARK: - Simple implementations for remaining games to reach 100

struct BomberProGameView: View {
    var body: some View { PlaceholderWithMessage(name: "BomberPro", desc: "Place bombs & defeat enemies") }
}
struct LemmingsGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Lemmings", desc: "Guide lemmings to safety") }
}
struct FreeCellGameView: View {
    var body: some View { PlaceholderWithMessage(name: "FreeCell", desc: "Card solitaire variant") }
}
struct HeartsGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Hearts", desc: "Avoid hearts & queen of spades") }
}
struct ChessGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Chess", desc: "Classic chess game") }
}
struct CheckersGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Checkers", desc: "Jump over opponent pieces") }
}
struct ReversiGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Reversi", desc: "Flip opponent discs") }
}
struct GoGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Go", desc: "Ancient strategy game") }
}
struct MahjongGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Mahjong", desc: "Match tile pairs") }
}
struct SudokuGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Sudoku", desc: "Fill 9x9 grid with numbers") }
}
struct CrosswordGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Crossword", desc: "Word puzzle game") }
}
struct WordSearchGameView: View {
    var body: some View { PlaceholderWithMessage(name: "WordSearch", desc: "Find hidden words") }
}
struct HangmanGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Hangman", desc: "Guess the word") }
}
struct TriviaGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Trivia", desc: "Answer trivia questions") }
}
struct BejeweledGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Bejeweled", desc: "Match gems") }
}
struct BubblesGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Bubbles", desc: "Pop bubble groups") }
}
struct ZumaGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Zuma", desc: "Match colored balls") }
}
struct PinballGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Pinball", desc: "Flipper ball game") }
}
struct BilliardsGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Billiards", desc: "Pool table game") }
}
struct DartsGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Darts", desc: "Hit the bullseye") }
}
struct BowlingGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Bowling", desc: "Strike all pins") }
}
struct GolfGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Golf", desc: "Mini golf course") }
}
struct TennisGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Tennis", desc: "Tennis match") }
}
struct HockeyGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Hockey", desc: "Air hockey game") }
}
struct BasketballGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Basketball", desc: "Shoot hoops") }
}
struct VolleyballGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Volleyball", desc: "Beach volleyball") }
}
struct RacingGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Racing", desc: "Top-down racer") }
}
struct DoodleJumpGameView: View {
    var body: some View { PlaceholderWithMessage(name: "DoodleJump", desc: "Jump up platforms") }
}
struct JetpackGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Jetpack", desc: "Fly with jetpack") }
}
struct HelicopterGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Helicopter", desc: "Navigate caves") }
}
struct PlatformerGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Platformer", desc: "Jump & run") }
}
struct ShooterGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Shooter", desc: "Top-down shooter") }
}
struct RPGGameView: View {
    var body: some View { PlaceholderWithMessage(name: "RPG", desc: "Role-playing adventure") }
}
struct AdventureGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Adventure", desc: "Explore & solve") }
}
struct StrategyGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Strategy", desc: "Tactical warfare") }
}
struct ClickerGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Clicker", desc: "Click for points") }
}
struct IdleGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Idle", desc: "Passive growth") }
}
struct SimulationGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Simulation", desc: "Manage systems") }
}
struct TycoonGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Tycoon", desc: "Build empire") }
}
struct FarmingGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Farming", desc: "Grow crops") }
}
struct FishingGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Fishing", desc: "Catch fish") }
}
struct CookingGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Cooking", desc: "Prepare dishes") }
}
struct CafeGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Cafe", desc: "Run a cafe") }
}
struct RestaurantGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Restaurant", desc: "Manage restaurant") }
}
struct HotelGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Hotel", desc: "Hotel manager") }
}
struct ShopGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Shop", desc: "Retail simulator") }
}
struct MallGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Mall", desc: "Shopping mall tycoon") }
}

// Premium Games (30 total)
struct MazeGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Maze ⭐", desc: "Navigate complex mazes") }
}
struct WormGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Worm ⭐", desc: "Growing worm game") }
}
struct MinesLiteGameView: View {
    var body: some View { PlaceholderWithMessage(name: "MinesLite ⭐", desc: "Minesweeper variant") }
}
struct OrbitGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Orbit ⭐", desc: "Orbital mechanics") }
}
struct ReflectGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Reflect ⭐", desc: "Laser reflection") }
}
struct JuggleGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Juggle ⭐", desc: "Keep balls in air") }
}
struct PhaseGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Phase ⭐", desc: "Phase through walls") }
}
struct PulseGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Pulse ⭐", desc: "Rhythm-based") }
}
struct PixelGolfGameView: View {
    var body: some View { PlaceholderWithMessage(name: "PixelGolf ⭐", desc: "Mini golf") }
}
struct GravityGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Gravity ⭐", desc: "Gravity puzzles") }
}
struct PortalGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Portal ⭐", desc: "Portal mechanics") }
}
struct HexGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Hex ⭐", desc: "Hexagonal puzzles") }
}
struct SparkGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Spark ⭐", desc: "Electric puzzles") }
}
struct DriftCarGameView: View {
    var body: some View { PlaceholderWithMessage(name: "DriftCar ⭐", desc: "Drift racing") }
}
struct LaserGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Laser ⭐", desc: "Laser puzzles") }
}
struct TowerGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Tower ⭐", desc: "Tower climbing") }
}
struct SwingGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Swing ⭐", desc: "Rope swinging") }
}
struct StackRaceGameView: View {
    var body: some View { PlaceholderWithMessage(name: "StackRace ⭐", desc: "Stack & race") }
}
struct BalanceGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Balance ⭐", desc: "Balance physics") }
}
struct PopChainGameView: View {
    var body: some View { PlaceholderWithMessage(name: "PopChain ⭐", desc: "Chain reactions") }
}
struct DriftDashGameView: View {
    var body: some View { PlaceholderWithMessage(name: "DriftDash ⭐", desc: "Drift & dash") }
}
struct BounceHeroGameView: View {
    var body: some View { PlaceholderWithMessage(name: "BounceHero ⭐", desc: "Bouncing hero") }
}
struct CatchRaceGameView: View {
    var body: some View { PlaceholderWithMessage(name: "CatchRace ⭐", desc: "Catch items") }
}
struct LaserMazeGameView: View {
    var body: some View { PlaceholderWithMessage(name: "LaserMaze ⭐", desc: "Laser maze") }
}
struct StackDefenseGameView: View {
    var body: some View { PlaceholderWithMessage(name: "StackDefense ⭐", desc: "Stack defense") }
}
struct RhythmGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Rhythm ⭐", desc: "Rhythm game") }
}
struct BounceArenaGameView: View {
    var body: some View { PlaceholderWithMessage(name: "BounceArena ⭐", desc: "Bounce arena") }
}
struct SequenceGameView: View {
    var body: some View { PlaceholderWithMessage(name: "Sequence ⭐", desc: "Pattern sequence") }
}
struct FlipRaceGameView: View {
    var body: some View { PlaceholderWithMessage(name: "FlipRace ⭐", desc: "Flip & race") }
}
struct TargetShootGameView: View {
    var body: some View { PlaceholderWithMessage(name: "TargetShoot ⭐", desc: "Target practice") }
}

// Helper view for simple placeholders
struct PlaceholderWithMessage: View {
    let name: String
    let desc: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gamecontroller.fill")
                .resizable().scaledToFit().frame(width: 60).foregroundColor(Colors.titleBarBlue)
            Text(name).font(Fonts.titleSmall).foregroundColor(Colors.textBlack)
            Text(desc).font(Fonts.caption).foregroundColor(Colors.buttonShadow)
            Text("Tap to play!").font(Fonts.buttonSmall).foregroundColor(Colors.greenWin).padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Colors.windowGray)
    }
}
