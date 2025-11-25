import Foundation
import AVFoundation

class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()

    private var bootupPlayer: AVAudioPlayer?
    private var clickPlayer: AVAudioPlayer?
    private var boopPlayer: AVAudioPlayer?

    @Published var sfxEnabled = UserDefaults.standard.bool(forKey: "sfxEnabled")

    private override init() {
        super.init()
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            UserDefaults.standard.set(true, forKey: "sfxEnabled")
            sfxEnabled = true
        }
        setupAudioSession()
        preloadSounds()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("⚠️ Failed to setup audio session: \(error)")
        }
    }

    private func preloadSounds() {
        // Bootup sound
        if let url = Bundle.main.url(forResource: "bootup", withExtension: "mp3") {
            bootupPlayer = try? AVAudioPlayer(contentsOf: url)
            bootupPlayer?.prepareToPlay()
            bootupPlayer?.volume = 0.8
        } else {
            print("⚠️ bootup.mp3 not found in bundle")
        }

        // Click sound (select/open)
        if let url = Bundle.main.url(forResource: "click", withExtension: "mp3") {
            clickPlayer = try? AVAudioPlayer(contentsOf: url)
            clickPlayer?.prepareToPlay()
            clickPlayer?.volume = 1.0
        } else {
            print("⚠️ click.mp3 not found in bundle")
        }

        // Boop sound (close/paywall)
        if let url = Bundle.main.url(forResource: "boop", withExtension: "mp3") {
            boopPlayer = try? AVAudioPlayer(contentsOf: url)
            boopPlayer?.prepareToPlay()
            boopPlayer?.volume = 0.9
        } else {
            print("⚠️ boop.mp3 not found in bundle")
        }
    }

    // MARK: - Sound Effects

    func playBootupSound() {
        guard sfxEnabled else { return }
        bootupPlayer?.currentTime = 0
        bootupPlayer?.play()
    }

    func playClickSound() {
        guard sfxEnabled else { return }
        clickPlayer?.currentTime = 0
        clickPlayer?.play()
    }

    func playBoopSound() {
        guard sfxEnabled else { return }
        boopPlayer?.currentTime = 0
        boopPlayer?.play()
    }

    // MARK: - Settings

    func toggleSFX() {
        sfxEnabled.toggle()
        UserDefaults.standard.set(sfxEnabled, forKey: "sfxEnabled")
    }
}
