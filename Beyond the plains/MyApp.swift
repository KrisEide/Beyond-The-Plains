import SwiftUI

@main
struct MyApp: App {
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var gameState = GameState()
    @State private var musicPlayer = MusicPlayer()
    @State private var isMusicMuted = false

    var body: some Scene {
        WindowGroup {
            Group {
                switch gameState.phase {
                case .start:
                    StartView(isMusicMuted: $isMusicMuted)

                case .partySetup:
                    PartySetupView()

                case .shop:
                    ShopView()

                case .journey:
                    JourneyView()

                case .result:
                    Text("Journey Complete")
                }
            }
            .environmentObject(gameState)
            .onAppear {
                musicPlayer.update(
                    phase: gameState.phase,
                    day: gameState.currentDay
                )
            }
            .onChange(of: isMusicMuted) { _, isMuted in
                musicPlayer.setMuted(isMuted)
            }
            .onChange(of: gameState.phase) { _, newPhase in
                musicPlayer.update(
                    phase: newPhase,
                    day: gameState.currentDay
                )
            }
            .onChange(of: gameState.currentDay) { _, newDay in
                musicPlayer.update(
                    phase: gameState.phase,
                    day: newDay
                )
            }
            .onChange(of: scenePhase) { _, newScenePhase in
                switch newScenePhase {
                case .active:
                    musicPlayer.resume(
                        phase: gameState.phase,
                        day: gameState.currentDay
                    )
                case .background:
                    musicPlayer.pause()
                case .inactive:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
}
