import SwiftUI

struct StartView: View {
    
    @EnvironmentObject var gameState: GameState
    
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
            }
        }
    }
}
    

#Preview {
    NavigationStack {
        StartView()
    }
    .environmentObject(GameState())
}
