import SwiftUI
import UIKit

// MARK: - Color Extension (Hex Support)
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

// MARK: - Font System
struct Fonts {
    static let title = Font.custom("PressStart2P-Regular", size: 24)
    static let titleSmall = Font.custom("PressStart2P-Regular", size: 18)
    static let button = Font.custom("PressStart2P-Regular", size: 16)
    static let buttonSmall = Font.custom("PressStart2P-Regular", size: 12)
    static let buttonTiny = Font.custom("PressStart2P-Regular", size: 8)

    static let stats = Font.custom("Jersey15-Regular", size: 16)
    static let statsSmall = Font.custom("Jersey15-Regular", size: 14)
    static let statsLarge = Font.custom("Jersey15-Regular", size: 20)

    static let body = Font.custom("DotoRounded-Black", size: 14)
    static let bodySmall = Font.custom("DotoRounded-Black", size: 12)
    static let caption = Font.custom("DotoRounded-Black", size: 10)

    // Fallback to system fonts if custom fonts not loaded
    static let systemFallback = Font.system(size: 14, weight: .bold, design: .monospaced)
}

// MARK: - Windows 95/98 Color Palette
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
    static let textBlack = Color.black
    static let textWhite = Color.white
    static let greenWin = Color(red: 0.0, green: 0.6, blue: 0.0)
    static let redLose = Color(red: 0.8, green: 0.0, blue: 0.0)

    // Desktop colors
    static let desktopTeal = Color(hex: "#008080")
    static let desktopTealDark = Color(hex: "#006666")
    static let iconHighlight = Color.blue.opacity(0.3)
}

// MARK: - Window State
enum WindowState {
    case normal
    case minimized
    case maximized
    case closed
}

// MARK: - Retro Button Component
struct RetroButton: View {
    let text: String
    let action: () -> Void
    let isSmall: Bool
    let isDisabled: Bool

    init(_ text: String, isSmall: Bool = false, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.text = text
        self.isSmall = isSmall
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: {
            if !isDisabled {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                action()
            }
        }) {
            Text(text)
                .font(isSmall ? Fonts.buttonSmall : Fonts.button)
                .foregroundColor(isDisabled ? Colors.buttonShadow : Colors.textBlack)
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
        .disabled(isDisabled)
    }
}

// MARK: - Window Frame Component
struct WindowFrame<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    var onClose: (() -> Void)?

    init(title: String, onClose: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.onClose = onClose
        self.content = content()
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

                // Close button
                if let closeAction = onClose {
                    Button(action: {
                        closeAction()
                    }) {
                        Text("×")
                            .font(Fonts.button)
                            .foregroundColor(Colors.textBlack)
                            .frame(width: 24, height: 24)
                            .background(Colors.buttonFace)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 4)
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Colors.titleBarActiveBlue, Colors.titleBarBlue]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )

            // Window content
            content
                .background(Colors.windowGray)
        }
        .overlay(
            Rectangle()
                .strokeBorder(Colors.windowBorder, lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}
