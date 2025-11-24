import Foundation

// MARK: - Game Meta Data
struct GameMeta: Identifiable, Hashable {
    let id: String
    let title: String
    let isPremium: Bool
}

// MARK: - Game Catalog
struct GameCatalog {
    // Premium game IDs (30 total)
    static let premiumIDs: Set<String> = [
        "maze", "worm", "mineslite", "memory", "orbit",
        "reflect", "juggle", "phase", "pulse", "pixelgolf",
        "gravity", "portal", "hex", "spark", "driftcar",
        "laser", "tower", "swing", "stackrace", "balance",
        "popchain", "driftdash", "bouncehero", "catchrace", "lasermaze",
        "stackdefense", "rhythm", "bouncearena", "sequence", "fliprace"
    ]

    // All 100 games
    static let allGames: [GameMeta] = [
        // Free games (70 total)
        GameMeta(id: "pong", title: "Pong.exe", isPremium: false),
        GameMeta(id: "snake", title: "Snake.exe", isPremium: false),
        GameMeta(id: "breakout", title: "Breakout.exe", isPremium: false),
        GameMeta(id: "tetris", title: "Tetris.exe", isPremium: false),
        GameMeta(id: "pacman", title: "PacMan.exe", isPremium: false),
        GameMeta(id: "invaders", title: "Invaders.exe", isPremium: false),
        GameMeta(id: "asteroids", title: "Asteroids.exe", isPremium: false),
        GameMeta(id: "frogger", title: "Frogger.exe", isPremium: false),
        GameMeta(id: "digdug", title: "DigDug.exe", isPremium: false),
        GameMeta(id: "galaga", title: "Galaga.exe", isPremium: false),
        GameMeta(id: "missile", title: "Missile.exe", isPremium: false),
        GameMeta(id: "defender", title: "Defender.exe", isPremium: false),
        GameMeta(id: "centipede", title: "Centipede.exe", isPremium: false),
        GameMeta(id: "qbert", title: "QBert.exe", isPremium: false),
        GameMeta(id: "donkeykong", title: "DonkeyKong.exe", isPremium: false),
        GameMeta(id: "mariolike", title: "JumpMan.exe", isPremium: false),
        GameMeta(id: "sokoban", title: "Sokoban.exe", isPremium: false),
        GameMeta(id: "bomberman", title: "BomberPro.exe", isPremium: false),
        GameMeta(id: "lemmings", title: "Lemmings.exe", isPremium: false),
        GameMeta(id: "minesweeper", title: "Minesweeper.exe", isPremium: false),
        GameMeta(id: "solitaire", title: "Solitaire.exe", isPremium: false),
        GameMeta(id: "freecell", title: "FreeCell.exe", isPremium: false),
        GameMeta(id: "hearts", title: "Hearts.exe", isPremium: false),
        GameMeta(id: "chess", title: "Chess.exe", isPremium: false),
        GameMeta(id: "checkers", title: "Checkers.exe", isPremium: false),
        GameMeta(id: "reversi", title: "Reversi.exe", isPremium: false),
        GameMeta(id: "go", title: "Go.exe", isPremium: false),
        GameMeta(id: "mahjong", title: "Mahjong.exe", isPremium: false),
        GameMeta(id: "sudoku", title: "Sudoku.exe", isPremium: false),
        GameMeta(id: "crossword", title: "Crossword.exe", isPremium: false),
        GameMeta(id: "wordsearch", title: "WordSearch.exe", isPremium: false),
        GameMeta(id: "hangman", title: "Hangman.exe", isPremium: false),
        GameMeta(id: "trivia", title: "Trivia.exe", isPremium: false),
        GameMeta(id: "match3", title: "Match3.exe", isPremium: false),
        GameMeta(id: "bejeweled", title: "Bejeweled.exe", isPremium: false),
        GameMeta(id: "bubbles", title: "Bubbles.exe", isPremium: false),
        GameMeta(id: "zuma", title: "Zuma.exe", isPremium: false),
        GameMeta(id: "pinball", title: "Pinball.exe", isPremium: false),
        GameMeta(id: "billiards", title: "Billiards.exe", isPremium: false),
        GameMeta(id: "darts", title: "Darts.exe", isPremium: false),
        GameMeta(id: "bowling", title: "Bowling.exe", isPremium: false),
        GameMeta(id: "golf", title: "Golf.exe", isPremium: false),
        GameMeta(id: "tennis", title: "Tennis.exe", isPremium: false),
        GameMeta(id: "hockey", title: "Hockey.exe", isPremium: false),
        GameMeta(id: "basketball", title: "Basketball.exe", isPremium: false),
        GameMeta(id: "volleyball", title: "Volleyball.exe", isPremium: false),
        GameMeta(id: "racing", title: "Racing.exe", isPremium: false),
        GameMeta(id: "flappy", title: "FlappyBird.exe", isPremium: false),
        GameMeta(id: "doodle", title: "DoodleJump.exe", isPremium: false),
        GameMeta(id: "jetpack", title: "Jetpack.exe", isPremium: false),
        GameMeta(id: "helicopter", title: "Helicopter.exe", isPremium: false),
        GameMeta(id: "runner", title: "Runner.exe", isPremium: false),
        GameMeta(id: "platformer", title: "Platformer.exe", isPremium: false),
        GameMeta(id: "shooter", title: "Shooter.exe", isPremium: false),
        GameMeta(id: "rpg", title: "RPG.exe", isPremium: false),
        GameMeta(id: "adventure", title: "Adventure.exe", isPremium: false),
        GameMeta(id: "strategy", title: "Strategy.exe", isPremium: false),
        GameMeta(id: "tower defense", title: "TowerDefense.exe", isPremium: false),
        GameMeta(id: "clicker", title: "Clicker.exe", isPremium: false),
        GameMeta(id: "idle", title: "Idle.exe", isPremium: false),
        GameMeta(id: "simulation", title: "Simulation.exe", isPremium: false),
        GameMeta(id: "tycoon", title: "Tycoon.exe", isPremium: false),
        GameMeta(id: "farming", title: "Farming.exe", isPremium: false),
        GameMeta(id: "fishing", title: "Fishing.exe", isPremium: false),
        GameMeta(id: "cooking", title: "Cooking.exe", isPremium: false),
        GameMeta(id: "cafe", title: "Cafe.exe", isPremium: false),
        GameMeta(id: "restaurant", title: "Restaurant.exe", isPremium: false),
        GameMeta(id: "hotel", title: "Hotel.exe", isPremium: false),
        GameMeta(id: "shop", title: "Shop.exe", isPremium: false),
        GameMeta(id: "mall", title: "Mall.exe", isPremium: false),

        // Premium games (30 total)
        GameMeta(id: "maze", title: "Maze.exe", isPremium: true),
        GameMeta(id: "worm", title: "Worm.exe", isPremium: true),
        GameMeta(id: "mineslite", title: "MinesLite.exe", isPremium: true),
        GameMeta(id: "memory", title: "Memory.exe", isPremium: true),
        GameMeta(id: "orbit", title: "Orbit.exe", isPremium: true),
        GameMeta(id: "reflect", title: "Reflect.exe", isPremium: true),
        GameMeta(id: "juggle", title: "Juggle.exe", isPremium: true),
        GameMeta(id: "phase", title: "Phase.exe", isPremium: true),
        GameMeta(id: "pulse", title: "Pulse.exe", isPremium: true),
        GameMeta(id: "pixelgolf", title: "PixelGolf.exe", isPremium: true),
        GameMeta(id: "gravity", title: "Gravity.exe", isPremium: true),
        GameMeta(id: "portal", title: "Portal.exe", isPremium: true),
        GameMeta(id: "hex", title: "Hex.exe", isPremium: true),
        GameMeta(id: "spark", title: "Spark.exe", isPremium: true),
        GameMeta(id: "driftcar", title: "DriftCar.exe", isPremium: true),
        GameMeta(id: "laser", title: "Laser.exe", isPremium: true),
        GameMeta(id: "tower", title: "Tower.exe", isPremium: true),
        GameMeta(id: "swing", title: "Swing.exe", isPremium: true),
        GameMeta(id: "stackrace", title: "StackRace.exe", isPremium: true),
        GameMeta(id: "balance", title: "Balance.exe", isPremium: true),
        GameMeta(id: "popchain", title: "PopChain.exe", isPremium: true),
        GameMeta(id: "driftdash", title: "DriftDash.exe", isPremium: true),
        GameMeta(id: "bouncehero", title: "BounceHero.exe", isPremium: true),
        GameMeta(id: "catchrace", title: "CatchRace.exe", isPremium: true),
        GameMeta(id: "lasermaze", title: "LaserMaze.exe", isPremium: true),
        GameMeta(id: "stackdefense", title: "StackDefense.exe", isPremium: true),
        GameMeta(id: "rhythm", title: "Rhythm.exe", isPremium: true),
        GameMeta(id: "bouncearena", title: "BounceArena.exe", isPremium: true),
        GameMeta(id: "sequence", title: "Sequence.exe", isPremium: true),
        GameMeta(id: "fliprace", title: "FlipRace.exe", isPremium: true)
    ]

    // Helper: Get game by ID
    static func game(byID id: String) -> GameMeta? {
        allGames.first { $0.id == id }
    }
}
