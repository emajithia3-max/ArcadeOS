import SwiftUI

struct WindowManager: View {
    let game: GameMeta
    let onClose: () -> Void

    var body: some View {
        WindowFrame(title: game.title, onClose: onClose) {
            gameContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Colors.windowGray)
        }
        .frame(maxWidth: 500, maxHeight: 600)
    }

    @ViewBuilder
    private var gameContent: some View {
        switch game.id {
        // Classic Arcade Games
        case "pong": PongGameView()
        case "snake": SnakeGameView()
        case "breakout": BreakoutGameView()
        case "tetris": TetrisGameView()
        case "pacman": PacManGameView()
        case "invaders": InvadersGameView()
        case "asteroids": AsteroidsGameView()
        case "frogger": FroggerGameView()
        case "digdug": DigDugGameView()
        case "galaga": GalagaGameView()
        case "missile": MissileCommandGameView()
        case "defender": DefenderGameView()
        case "centipede": CentipedeGameView()
        case "qbert": QBertGameView()
        case "donkeykong": DonkeyKongGameView()
        case "mariolike": JumpManGameView()
        case "sokoban": SokobanGameView()
        case "bomberman": BomberProGameView()
        case "lemmings": LemmingsGameView()
        case "minesweeper": MinesweeperGameView()

        // Card & Board Games
        case "solitaire": SolitaireGameView()
        case "freecell": FreeCellGameView()
        case "hearts": HeartsGameView()
        case "chess": ChessGameView()
        case "checkers": CheckersGameView()
        case "reversi": ReversiGameView()
        case "go": GoGameView()
        case "mahjong": MahjongGameView()
        case "sudoku": SudokuGameView()
        case "crossword": CrosswordGameView()
        case "wordsearch": WordSearchGameView()
        case "hangman": HangmanGameView()
        case "trivia": TriviaGameView()

        // Puzzle & Match Games
        case "match3": Match3GameView()
        case "bejeweled": BejeweledGameView()
        case "bubbles": BubblesGameView()
        case "zuma": ZumaGameView()

        // Sports Games
        case "pinball": PinballGameView()
        case "billiards": BilliardsGameView()
        case "darts": DartsGameView()
        case "bowling": BowlingGameView()
        case "golf": GolfGameView()
        case "tennis": TennisGameView()
        case "hockey": HockeyGameView()
        case "basketball": BasketballGameView()
        case "volleyball": VolleyballGameView()
        case "racing": RacingGameView()

        // Mobile-Style Games
        case "flappy": FlappyBirdGameView()
        case "doodle": DoodleJumpGameView()
        case "jetpack": JetpackGameView()
        case "helicopter": HelicopterGameView()
        case "runner": RunnerGameView()
        case "platformer": PlatformerGameView()
        case "shooter": ShooterGameView()

        // Strategy & RPG
        case "rpg": RPGGameView()
        case "adventure": AdventureGameView()
        case "strategy": StrategyGameView()
        case "tower defense": TowerDefenseGameView()

        // Idle & Sim Games
        case "clicker": ClickerGameView()
        case "idle": IdleGameView()
        case "simulation": SimulationGameView()
        case "tycoon": TycoonGameView()
        case "farming": FarmingGameView()
        case "fishing": FishingGameView()
        case "cooking": CookingGameView()
        case "cafe": CafeGameView()
        case "restaurant": RestaurantGameView()
        case "hotel": HotelGameView()
        case "shop": ShopGameView()
        case "mall": MallGameView()

        // Premium Games
        case "maze": MazeGameView()
        case "worm": WormGameView()
        case "mineslite": MinesLiteGameView()
        case "memory": MemoryGameView()
        case "orbit": OrbitGameView()
        case "reflect": ReflectGameView()
        case "juggle": JuggleGameView()
        case "phase": PhaseGameView()
        case "pulse": PulseGameView()
        case "pixelgolf": PixelGolfGameView()
        case "gravity": GravityGameView()
        case "portal": PortalGameView()
        case "hex": HexGameView()
        case "spark": SparkGameView()
        case "driftcar": DriftCarGameView()
        case "laser": LaserGameView()
        case "tower": TowerGameView()
        case "swing": SwingGameView()
        case "stackrace": StackRaceGameView()
        case "balance": BalanceGameView()
        case "popchain": PopChainGameView()
        case "driftdash": DriftDashGameView()
        case "bouncehero": BounceHeroGameView()
        case "catchrace": CatchRaceGameView()
        case "lasermaze": LaserMazeGameView()
        case "stackdefense": StackDefenseGameView()
        case "rhythm": RhythmGameView()
        case "bouncearena": BounceArenaGameView()
        case "sequence": SequenceGameView()
        case "fliprace": FlipRaceGameView()

        // Casual Games
        case "simon": SimonSaysGameView()
        case "whackmole": WhackAMoleGameView()
        case "2048": Game2048View()
        case "colormatch": ColorMatchGameView()
        case "slider": SlidingPuzzleGameView()
        case "tictactoe": TicTacToeGameView()
        case "reaction": ReactionGameView()

        default:
            PlaceholderGameView(game: game)
        }
    }
}
