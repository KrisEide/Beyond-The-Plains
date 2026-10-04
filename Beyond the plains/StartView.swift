import SwiftUI

struct StartView: View {
    
    @EnvironmentObject var gameState: GameState
    @Binding var isMusicMuted: Bool
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let isLandscape = geometry.size.width > geometry.size.height
            
            ZStack {
                
                Image(isLandscape ? "StartScreenLandscape2" : "StartScreenPortrait2")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    
                    Image("GameLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: isLandscape ? 260 : 300)
                        .offset(x: -12)
                    
                    Button {
                        gameState.phase = .partySetup
                    } label: {
                        
                        
                        Text("Start Game")
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundStyle(
                                Color(red: 0.20, green: 0.13, blue: 0.08)
                            )
                            .padding(.horizontal, 38)
                            .padding(.vertical, 14)
                            .background(
                                Color(red: 0.91, green: 0.81, blue: 0.64)
                                
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        Color(red: 0.30, green: 0.20, blue: 0.12),
                                        lineWidth: 2
                                            
                                    )
                            }
                            .offset(x: -12, y: 20)
                    }
                    
                }
                
                .offset(y: isLandscape ? -60 : -200)

                Button {
                    isMusicMuted.toggle()
                } label: {
                    Image(systemName: isMusicMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(red: 0.20, green: 0.13, blue: 0.08))
                        .frame(width: 44, height: 44)
                        .background(Color(red: 0.91, green: 0.81, blue: 0.64).opacity(0.9))
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(Color(red: 0.30, green: 0.20, blue: 0.12), lineWidth: 2)
                        }
                }
                .buttonStyle(.plain)
                .padding(.top, 12)
                .padding(.trailing, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: -32)
                .accessibilityLabel(isMusicMuted ? "Turn Music On" : "Mute Music")
            }
        }
    }
}
    

#Preview {
    NavigationStack {
        StartView(isMusicMuted: .constant(false))
    }
    .environmentObject(GameState())
}
