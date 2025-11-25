import SwiftUI

struct BootView: View {
    @State private var loadingText = "Loading ArcadeOS"
    @State private var dotCount = 0
    @State private var goToDesktop = false
    @State private var fadeInOpacity: Double = 0.0
    @State private var borderOpacity: Double = 0.0

    var body: some View {
        Group {
            if goToDesktop {
                DesktopView()
                    .transition(.opacity)
            } else {
                ZStack {
                    Color.black.ignoresSafeArea()

                    VStack {
                        HStack {
                            Text(displayText)
                                .font(Fonts.buttonTiny)
                                .foregroundColor(Color(hex: "#32FA7C"))
                                .shadow(color: Color(hex: "#32FA7C").opacity(0.8), radius: 8)
                                .shadow(color: Color(hex: "#32FA7C").opacity(0.4), radius: 16)
                                .opacity(fadeInOpacity)
                            Spacer()
                        }
                        .padding(.leading, 16)
                        .padding(.top, 16)
                        Spacer()
                    }

                    // Green terminal-style border
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color(hex: "#32FA7C").opacity(0.9), lineWidth: 2)
                        .shadow(color: Color(hex: "#32FA7C").opacity(0.5), radius: 4)
                        .opacity(borderOpacity)
                        .ignoresSafeArea()
                }
            }
        }
        .onAppear(perform: startSequence)
    }

    private var displayText: String {
        return loadingText + String(repeating: ".", count: dotCount)
    }

    private func startSequence() {
        // Play boot sound
        AudioManager.shared.playBootupSound()

        // Fade in
        withAnimation(.easeIn(duration: 0.3)) {
            fadeInOpacity = 1.0
            borderOpacity = 1.0
        }

        // Start dot animation
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
            dotCount = (dotCount + 1) % 4
        }

        // Transition to desktop after 2.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                fadeInOpacity = 0.0
                borderOpacity = 0.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    goToDesktop = true
                }
            }
        }
    }
}
