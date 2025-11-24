🖥️ COMPLETE RETRO DESKTOP OS THEME PACKAGE
📦 1. THEME.SWIFT - Complete Color & Component System
import SwiftUI
import UIKit

// Hex color support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Font system (you'll need these fonts in your project)
struct Fonts {
    static let title = Font.custom("Press Start 2P", size: 24)
    static let titleSmall = Font.custom("Press Start 2P", size: 18)
    static let button = Font.custom("Press Start 2P", size: 16)
    static let buttonSmall = Font.custom("Press Start 2P", size: 12)
    
    static let stats = Font.custom("Jersey15-Regular", size: 16, relativeTo: .body)
    static let statsSmall = Font.custom("Jersey15-Regular", size: 14, relativeTo: .body)
    static let statsLarge = Font.custom("Jersey15-Regular", size: 20, relativeTo: .body)
    
    static let body = Font.custom("Doto Rounded Black", size: 14, relativeTo: .body)
    static let bodySmall = Font.custom("Doto Rounded Black", size: 12, relativeTo: .caption)
    static let caption = Font.custom("Doto Rounded Black", size: 10, relativeTo: .caption)
}

// Windows 95/98 color palette
struct Colors {
    static let windowGray = Color(red: 0.75, green: 0.75, blue: 0.75)
    static let windowDark = Color(red: 0.5, green: 0.5, blue: 0.5)
    static let windowLight = Color(red: 0.9, green: 0.9, blue: 0.9)
    static let windowBorder = Color(red: 0.25, green: 0.25, blue: 0.25)
    static let titleBarBlue = Color(red: 0.0, green: 0.0, blue: 0.5)
    static let titleBarActiveBlue = Color(red: 0.0, green: 0.0, blue: 0.8)
    static let buttonFace = Color(red: 0.75, green: 0.75, blue: 0.75)
    static let buttonHighlight = Color.white
    static let buttonShadow = Color(red: 0.5, green: 0.5, blue: 0.5)
    static let buttonDarkShadow = Color.black
    static let water = Color(red: 0.2, green: 0.6, blue: 0.9)
    static let waterDark = Color(red: 0.1, green: 0.5, blue: 0.8)
    static let glass = Color.white.opacity(0.3)
    static let glassStroke = Color.black.opacity(0.6)
    static let textBlack = Color.black
    static let textWhite = Color.white
    static let greenWin = Color(red: 0.0, green: 0.6, blue: 0.0)
    static let redLose = Color(red: 0.8, green: 0.0, blue: 0.0)
}

// Classic Windows-style 3D button
struct RetroButton: View {
    let text: String
    let action: () -> Void
    let isSmall: Bool
    
    init(_ text: String, isSmall: Bool = false, action: @escaping () -> Void) {
        self.text = text
        self.isSmall = isSmall
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            Text(text)
                .font(isSmall ? Fonts.buttonSmall : Fonts.button)
                .foregroundColor(Colors.textBlack)
                .padding(.horizontal, isSmall ? 12 : 20)
                .padding(.vertical, isSmall ? 6 : 10)
                .background(
                    ZStack {
                        Rectangle()
                            .fill(Colors.buttonFace)
                        // Top highlight
                        VStack {
                            HStack {
                                Rectangle()
                                    .fill(Colors.buttonHighlight)
                                    .frame(height: 2)
                                Spacer()
                            }
                            Spacer()
                        }
                        // Bottom shadow
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Rectangle()
                                    .fill(Colors.buttonDarkShadow)
                                    .frame(height: 2)
                            }
                        }
                        // Left/right borders
                        HStack {
                            Rectangle()
                                .fill(Colors.buttonHighlight)
                                .frame(width: 2)
                            Spacer()
                            Rectangle()
                                .fill(Colors.buttonDarkShadow)
                                .frame(width: 2)
                        }
                    }
                )
        }
    }
}

// Window state management
enum WindowState {
    case normal
    case minimized
    case maximized
    case closed
}

// Classic Windows 95/98 window frame
struct WindowFrame<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    var windowState: Binding<WindowState>?
    var onMinimize: (() -> Void)?
    var onMaximize: (() -> Void)?
    var onClose: (() -> Void)?
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
        self.windowState = nil
        self.onMinimize = nil
        self.onMaximize = nil
        self.onClose = nil
    }
    
    init(title: String, windowState: Binding<WindowState>, onMinimize: @escaping () -> Void, onMaximize: @escaping () -> Void, onClose: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
        self.windowState = windowState
        self.onMinimize = onMinimize
        self.onMaximize = onMaximize
        self.onClose = onClose
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack(spacing: 0) {
                Text(title)
                    .font(Fonts.buttonSmall)
                    .foregroundColor(Colors.textWhite)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                Spacer()
                HStack(spacing: 4) {
                    // Minimize button
                    Button(action: {
                        onMinimize?()
                    }) {
                        Text((windowState?.wrappedValue == .minimized) ? "+" : "_")
                            .font(Fonts.buttonSmall)
                            .foregroundColor(Colors.textBlack)
                            .frame(width: 20, height: 20)
                            .background(Colors.buttonFace)
                    }
                    .disabled(onMinimize == nil)
                    .buttonStyle(PlainButtonStyle())
                    
                    // Maximize button
                    Button(action: {
                        onMaximize?()
                    }) {
                        Text("□")
                            .font(Fonts.buttonSmall)
                            .foregroundColor(Colors.textBlack)
                            .frame(width: 20, height: 20)
                            .background(Colors.buttonFace)
                    }
                    .disabled(onMaximize == nil)
                    .buttonStyle(PlainButtonStyle())
                    
                    // Close button
                    Button(action: {
                        onClose?()
                    }) {
                        Text("×")
                            .font(Fonts.buttonSmall)
                            .foregroundColor(Colors.textBlack)
                            .frame(width: 20, height: 20)
                            .background(Colors.buttonFace)
                    }
                    .disabled(onClose == nil)
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.trailing, 4)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Colors.titleBarActiveBlue, Colors.titleBarBlue]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(maxWidth: windowState?.wrappedValue == .minimized ? 280 : .infinity)
            
            // Window content
            if windowState?.wrappedValue != .minimized {
                content
                    .background(Colors.windowGray)
            }
        }
        .overlay(
            Rectangle()
                .strokeBorder(Colors.windowBorder, lineWidth: 2)
        )
    }
}



🎵 2. AUDIOMANAGER.SWIFT - Complete Audio System
import Foundation
import AVFoundation

class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = AudioManager()
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var clickSoundPlayer: AVAudioPlayer?
    private var fillSoundPlayer: AVAudioPlayer?
    private var lossSoundPlayer: AVAudioPlayer?
    private var victorySoundPlayer: AVAudioPlayer?
    private var overflowSoundPlayer: AVAudioPlayer?
    
    // Track library
    private let trackLibrary: [(index: Int, name: String)] = [
        (1, "Spilling for Joy"),
        (2, "Drip Drop"),
        (3, "Almost Spilled It"),
        (4, "Spillway"),
        (5, "Droplet Wonderland"),
        (6, "Drops of Sweat"),
        (7, "Trickling Traveler"),
        (8, "Playing in the Water"),
        (9, "Duel of the Spills"),
        (10, "Waterfall Way")
    ]
    
    private var playedTracks: Set<Int> = []
    private var lastPlayedTrackIndex: Int?
    
    @Published var musicEnabled = UserDefaults.standard.bool(forKey: "musicEnabled")
    @Published var sfxEnabled = UserDefaults.standard.bool(forKey: "sfxEnabled")
    @Published var currentTrackName: String = ""
    @Published var currentTrackIndex: Int = 0
    @Published var isPlaying: Bool = false
    @Published var showNowPlayingBanner: Bool = false
    
    private var isAdPlaying = false
    
    private override init() {
        super.init()
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            UserDefaults.standard.set(true, forKey: "musicEnabled")
            UserDefaults.standard.set(true, forKey: "sfxEnabled")
            musicEnabled = true
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
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func preloadSounds() {
        // Click sound
        if let url = Bundle.main.url(forResource: "click", withExtension: "mp3") {
            clickSoundPlayer = try? AVAudioPlayer(contentsOf: url)
            clickSoundPlayer?.prepareToPlay()
            clickSoundPlayer?.volume = 1.0
        }
        
        // Fill sound
        if let url = Bundle.main.url(forResource: "fill", withExtension: "mp3") {
            fillSoundPlayer = try? AVAudioPlayer(contentsOf: url)
            fillSoundPlayer?.prepareToPlay()
            fillSoundPlayer?.volume = 0.95
        }
        
        // Loss sound
        if let url = Bundle.main.url(forResource: "loss", withExtension: "mp3") {
            lossSoundPlayer = try? AVAudioPlayer(contentsOf: url)
            lossSoundPlayer?.prepareToPlay()
        }
        
        // Victory sound
        if let url = Bundle.main.url(forResource: "victory", withExtension: "mp3") {
            victorySoundPlayer = try? AVAudioPlayer(contentsOf: url)
            victorySoundPlayer?.prepareToPlay()
        }
        
        // Overflow sound
        if let url = Bundle.main.url(forResource: "overflow", withExtension: "mp3") {
            overflowSoundPlayer = try? AVAudioPlayer(contentsOf: url)
            overflowSoundPlayer?.prepareToPlay()
            overflowSoundPlayer?.volume = 0.95
        }
    }
    
    // MARK: - Background Music
    
    func startBackgroundMusic() {
        if musicEnabled {
            playRandomTrack()
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
    }
    
    private func playRandomTrack() {
        if playedTracks.count >= trackLibrary.count {
            playedTracks.removeAll()
        }
        
        var trackIndex: Int
        repeat {
            trackIndex = Int.random(in: 0..<trackLibrary.count)
        } while playedTracks.contains(trackIndex) || (lastPlayedTrackIndex == trackIndex && trackLibrary.count > 1)
        
        playTrack(at: trackIndex)
    }
    
    private func playTrack(at index: Int) {
        guard index >= 0 && index < trackLibrary.count else { return }
        
        let track = trackLibrary[index]
        let trackNumber = track.index
        let trackName = track.name
        
        if let url = Bundle.main.url(forResource: "audio\(trackNumber)", withExtension: "mp3") {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundMusicPlayer?.delegate = self
                backgroundMusicPlayer?.volume = 0.3
                backgroundMusicPlayer?.play()
                
                currentTrackIndex = index
                currentTrackName = trackName
                isPlaying = true
                lastPlayedTrackIndex = index
                playedTracks.insert(index)
                
                showNowPlayingBanner = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.showNowPlayingBanner = false
                }
            } catch {
                print("Failed to play track: \(error)")
            }
        }
    }
    
    // MARK: - Player Controls
    
    func nextTrack() {
        let nextIndex = (currentTrackIndex + 1) % trackLibrary.count
        playTrack(at: nextIndex)
    }
    
    func previousTrack() {
        let prevIndex = (currentTrackIndex - 1 + trackLibrary.count) % trackLibrary.count
        playTrack(at: prevIndex)
    }
    
    func togglePlayPause() {
        guard let player = backgroundMusicPlayer else { return }
        
        if player.isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player == backgroundMusicPlayer {
            playRandomTrack()
        }
    }
    
    // MARK: - Sound Effects
    
    func playClickSound() {
        guard sfxEnabled && !isAdPlaying else { return }
        clickSoundPlayer?.currentTime = 0
        clickSoundPlayer?.play()
    }
    
    func startFillSound() {
        guard sfxEnabled && !isAdPlaying else { return }
        fillSoundPlayer?.currentTime = 0
        fillSoundPlayer?.play()
    }
    
    func stopFillSound() {
        fillSoundPlayer?.stop()
    }
    
    func playOverflowSound() {
        guard sfxEnabled && !isAdPlaying else { return }
        overflowSoundPlayer?.currentTime = 0
        overflowSoundPlayer?.play()
    }
    
    func playVictorySound(completion: @escaping () -> Void) {
        if sfxEnabled && !isAdPlaying {
            victorySoundPlayer?.currentTime = 0
            victorySoundPlayer?.play()
            
            if let duration = victorySoundPlayer?.duration {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    completion()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    completion()
                }
            }
        } else {
            completion()
        }
    }
    
    func playLossSound(completion: @escaping () -> Void) {
        if sfxEnabled && !isAdPlaying {
            lossSoundPlayer?.currentTime = 0
            lossSoundPlayer?.play()
            
            if let duration = lossSoundPlayer?.duration {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    completion()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    completion()
                }
            }
        } else {
            completion()
        }
    }
}



🚀 3. LAUNCHVIEW.SWIFT - Boot Screen
import SwiftUI
import AVFoundation

struct LaunchView: View {
    @State private var phase = 0
    @State private var loadingText = "Loading Spill.exe"
    @State private var dotCount = 0
    @State private var audioPlayer: AVAudioPlayer?
    @State private var goToDesktop = false
    @State private var dotTimer: Timer?
    @State private var flickerOpacity: Double = 1.0
    @State private var fadeInOpacity: Double = 0.0
    @State private var borderOpacity: Double = 0.0
    
    var body: some View {
        Group {
            if goToDesktop {
                // Transition to your main view here
                Text("Desktop Loaded!")
                    .foregroundColor(.white)
            } else {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    VStack {
                        HStack {
                            Text(displayText)
                                .font(.custom("Press Start 2P", size: 8))
                                .foregroundColor(Color(hex: "#32FA7C"))
                                .shadow(color: Color(hex: "#32FA7C").opacity(0.8), radius: 8, x: 0, y: 0)
                                .shadow(color: Color(hex: "#32FA7C").opacity(0.4), radius: 16, x: 0, y: 0)
                                .opacity(phase == 2 ? 0 : (phase == 1 ? flickerOpacity * fadeInOpacity : fadeInOpacity))
                                .animation(.easeOut(duration: 0.3), value: phase)
                            Spacer()
                        }
                        .padding(.leading, 16)
                        .padding(.top, 16)
                        Spacer()
                    }
                    
                    // Green terminal-style border
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color(hex: "#32FA7C").opacity(0.9), lineWidth: 2)
                        .shadow(color: Color(hex: "#32FA7C").opacity(0.5), radius: 4, x: 0, y: 0)
                        .opacity(borderOpacity)
                        .animation(.easeOut(duration: 0.3), value: borderOpacity)
                        .ignoresSafeArea()
                }
            }
        }
        .onAppear(perform: startSequence)
        .onDisappear {
            dotTimer?.invalidate()
            audioPlayer?.stop()
        }
    }
    
    private var displayText: String {
        switch phase {
        case 0:
            return "Booting up..."
        case 1:
            return loadingText + String(repeating: ".", count: dotCount)
        default:
            return ""
        }
    }
    
    private func startSequence() {
        // Phase 0: "Booting up..." (1 second)
        withAnimation(.easeIn(duration: 0.3)) {
            fadeInOpacity = 1.0
            borderOpacity = 1.0
        }
        
        playBootSound()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            phase = 1
            startLoadingAndBootSound()
        }
    }
    
    private func playBootSound() {
        if let soundURL = Bundle.main.url(forResource: "bootup", withExtension: "mp3") {
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                self.audioPlayer?.volume = 1.0
                self.audioPlayer?.play()
            } catch {
                print("Failed to play boot sound")
            }
        }
    }
    
    private func startLoadingAndBootSound() {
        // Phase 1: "Loading..." with animated dots
        dotTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            dotCount = (dotCount + 1) % 4
        }
        
        // Flickering effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.linear(duration: 0.1)) { flickerOpacity = 0.3 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.linear(duration: 0.1)) { flickerOpacity = 1.0 }
        }
        
        // After 1.6 seconds, transition to desktop
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            dotTimer?.invalidate()
            phase = 2
            transitionToDesktop()
        }
    }
    
    private func transitionToDesktop() {
        // Fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.1)) {
                borderOpacity = 0.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.none) {
                goToDesktop = true
            }
        }
    }
}



🖥️ 4. DESKTOPVIEW.SWIFT - Desktop with Icons
import SwiftUI

enum DesktopApp {
    case spill
    case pong
}

struct DesktopView: View {
    @State private var selectedApp: DesktopApp? = nil
    @State private var lastTapTime: Date?
    @State private var lastTappedApp: DesktopApp? = nil
    let onOpenSpill: () -> Void
    let onOpenPong: () -> Void
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 16) {
                // App icon with double-tap to open
                VStack(spacing: 4) {
                    Image(systemName: "app.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .padding(selectedApp == .spill ? 0 : 4)
                        .background(
                            selectedApp == .spill ?
                                Color.blue.opacity(0.3) :
                                Color.clear
                        )
                        .border(selectedApp == .spill ? Color.black : Color.clear, width: 1)
                    
                    Text("Spill.exe")
                        .font(.custom("Press Start 2P", size: 8))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(selectedApp == .spill ? Color.blue : Color.clear)
                }
                .frame(width: 80)
                .contentShape(Rectangle())
                .onTapGesture {
                    handleTap(app: .spill)
                }
                
                // Pong icon
                VStack(spacing: 4) {
                    ZStack {
                        if selectedApp == .pong {
                            Rectangle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 72, height: 72)
                        }
                        
                        // Simple Pong icon
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.black)
                                .frame(width: 64, height: 64)
                            
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 4, height: 20)
                                .offset(x: -24)
                            
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 4, height: 20)
                                .offset(x: 24)
                            
                            Circle()
                                .fill(Color.white)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .frame(width: 72, height: 72)
                    .border(selectedApp == .pong ? Color.black : Color.clear, width: 1)
                    
                    Text("Pong.exe")
                        .font(.custom("Press Start 2P", size: 8))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(selectedApp == .pong ? Color.blue : Color.clear)
                }
                .frame(width: 80)
                .contentShape(Rectangle())
                .onTapGesture {
                    handleTap(app: .pong)
                }
                
                Spacer()
            }
            .padding(16)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                selectedApp = nil
            }
        }
    }
    
    private func handleTap(app: DesktopApp) {
        let now = Date()
        
        if let lastTap = lastTapTime,
           let lastApp = lastTappedApp,
           lastApp == app,
           now.timeIntervalSince(lastTap) < 0.5 {
            // Double tap - open app
            selectedApp = nil
            withAnimation(.easeOut(duration: 0.3)) {
                switch app {
                case .spill:
                    onOpenSpill()
                case .pong:
                    onOpenPong()
                }
            }
        } else {
            // Single tap - select
            withAnimation(.easeInOut(duration: 0.1)) {
                selectedApp = app
            }
        }
        
        lastTapTime = now
        lastTappedApp = app
    }
}



🎵 5. RETROAUDIOPLAYER.SWIFT - Music Player UI
import SwiftUI

struct RetroAudioPlayer: View {
    @ObservedObject var audioManager = AudioManager.shared
    
    var body: some View {
        if audioManager.musicEnabled {
            VStack(spacing: 6) {
                // Track title
                VStack(spacing: 2) {
                    Text("♪ NOW PLAYING ♪")
                        .font(.custom("Press Start 2P", size: 7))
                        .foregroundColor(Colors.buttonShadow)
                        .tracking(1)
                    
                    Text(audioManager.currentTrackName)
                        .font(.custom("Press Start 2P", size: 9))
                        .foregroundColor(Colors.titleBarBlue)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal, 8)
                }
                .padding(.top, 6)
                
                // Equalizer visualization
                EqualizerView(isPlaying: audioManager.isPlaying)
                    .frame(height: 24)
                    .padding(.horizontal, 16)
                
                // Control buttons
                HStack(spacing: 12) {
                    PlayerButton(icon: "backward.fill") {
                        AudioManager.shared.previousTrack()
                    }
                    
                    PlayerButton(icon: audioManager.isPlaying ? "pause.fill" : "play.fill", isPrimary: true) {
                        AudioManager.shared.togglePlayPause()
                    }
                    
                    PlayerButton(icon: "forward.fill") {
                        AudioManager.shared.nextTrack()
                    }
                }
                .padding(.bottom, 6)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Colors.windowDark)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Colors.titleBarBlue, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 16)
        }
    }
}

struct PlayerButton: View {
    let icon: String
    var isPrimary: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: isPrimary ? 16 : 13, weight: .bold))
                .foregroundColor(isPrimary ? Colors.titleBarBlue : Colors.textBlack)
                .frame(width: isPrimary ? 40 : 32, height: isPrimary ? 40 : 32)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Colors.windowLight)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(isPrimary ? Colors.titleBarBlue : Colors.buttonShadow, lineWidth: isPrimary ? 2 : 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EqualizerView: View {
    let isPlaying: Bool
    @State private var barHeights: [CGFloat] = Array(repeating: 0.3, count: 8)
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<8, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Colors.titleBarBlue, Colors.titleBarBlue.opacity(0.6)]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 6)
                    .frame(height: barHeights[index] * 24)
                    .animation(.easeInOut(duration: 0.15), value: barHeights[index])
            }
        }
        .frame(maxWidth: .infinity)
        .onReceive(timer) { _ in
            if isPlaying {
                for i in 0..<barHeights.count {
                    barHeights[i] = CGFloat.random(in: 0.3...1.0)
                }
            } else {
                for i in 0..<barHeights.count {
                    barHeights[i] = 0.3
                }
            }
        }
    }
}



📋 USAGE EXAMPLE
// Example of how to use these components
struct ContentView: View {
    @State private var windowState: WindowState = .normal
    
    var body: some View {
        ZStack {
            // Desktop background
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#008080"), Color(hex: "#006666")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Window with content
            WindowFrame(
                title: "My App.exe",
                windowState: $windowState,
                onMinimize: { windowState = .minimized },
                onMaximize: { windowState = .maximized },
                onClose: { windowState = .closed }
            ) {
                VStack(spacing: 20) {
                    Text("Hello, Retro World!")
                        .font(Fonts.title)
                    
                    RetroButton("Click Me!") {
                        print("Button clicked!")
                    }
                    
                    RetroAudioPlayer()
                }
                .padding()
            }
            .padding(40)
        }
    }
}



📦 REQUIRED ASSETS
Fonts (Download these):
Press Start 2P - https://fonts.google.com/specimen/Press+Start+2P
Jersey15 - https://fonts.google.com/specimen/Jersey+15
Doto Rounded - Search for "Doto font" or use alternative rounded pixel font
Sound Effects (Create or find):
bootup.mp3 - Boot sound
click.mp3 - UI click
victory.mp3 - Success sound
loss.mp3 - Fail sound
boop.mp3 - Collision sound

This complete package gives you everything to recreate a retro Windows 95/98-style desktop OS interface with bootup sequence, window management, buttons, audio system, and desktop icons!



