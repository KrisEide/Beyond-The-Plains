import SwiftUI

struct PartySetupView: View {
    
    @EnvironmentObject var gameState: GameState

    private var allTravelerNamesAreValid: Bool {
        !gameState.traveler1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !gameState.traveler2.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !gameState.traveler3.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    

    var body: some View {

        GeometryReader { geometry in

            let isLandscape = geometry.size.width > geometry.size.height

            ZStack {

                // Bakgrunn
                Image(
                    isLandscape
                    ? "CharacterSelectLanscape"
                    : "CharacterSelectPortrait"
                )
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()


                // Innhold
                VStack(spacing: isLandscape ? 1 : 18) {

                    

                    


                    Text("YOUR TRAVELERS")
                        .font(.system(
                            size: isLandscape ? 20 : 23,
                            weight: .bold,
                            design: .serif
                        ))
                        .padding(.top, isLandscape ? 2 : 8)


                    travelerField(
                        title: "Traveler 1",
                        text: $gameState.traveler1
                    )
                    .onChange(of: gameState.traveler1) { _, newValue in
                        if newValue.count > 10 {
                            gameState.traveler1 = String(newValue.prefix(10))
                        }
                    }
                    
                    genderPicker(
                        selection: $gameState.traveler1Gender
                    )
                    .frame(
                        maxWidth: isLandscape ? 210 : .infinity,
                        alignment: .leading
                    )

                    travelerField(
                        title: "Traveler 2",
                        text: $gameState.traveler2
                    )
                    .onChange(of: gameState.traveler2) { _, newValue in
                        if newValue.count > 10 {
                            gameState.traveler2 = String(newValue.prefix(10))
                        }
                    }
                    
                    genderPicker(
                        selection: $gameState.traveler2Gender
                    )
                    .frame(
                        maxWidth: isLandscape ? 210 : .infinity,
                        alignment: .leading
                    )
                    
                    travelerField(
                        title: "Traveler 3",
                        text: $gameState.traveler3
                    )
                    .onChange(of: gameState.traveler3) { _, newValue in
                        if newValue.count > 10 {
                            gameState.traveler3 = String(newValue.prefix(10))
                        }
                    }
                    
                    genderPicker(
                        selection: $gameState.traveler3Gender
                    )
                    .frame(
                        maxWidth: isLandscape ? 210 : .infinity,
                        alignment: .leading
                    )


                    Button {

                        var availableMen = [
                            "Portrait_man1",
                            "Portrait_man2",
                            "Portrait_man3",
                            "Portrait_man4",
                            "Portrait_man5",
                            "Portrait_man6",
                            "Portrait_man7"
                        ]

                        var availableWomen = [
                            "Portrait_woman1",
                            "Portrait_woman2",
                            "Portrait_woman3",
                            "Portrait_woman4",
                            "Portrait_woman5",
                            "Portrait_woman6",
                            "Portrait_woman7",
                            "Portrait_woman8",
                            "Portrait_woman9"
                        ]

                        availableMen.shuffle()
                        availableWomen.shuffle()

                        if gameState.traveler1Gender == "Man" {
                            gameState.traveler1Portrait = availableMen.removeFirst()
                        } else {
                            gameState.traveler1Portrait = availableWomen.removeFirst()
                        }

                        if gameState.traveler2Gender == "Man" {
                            gameState.traveler2Portrait = availableMen.removeFirst()
                        } else {
                            gameState.traveler2Portrait = availableWomen.removeFirst()
                        }

                        if gameState.traveler3Gender == "Man" {
                            gameState.traveler3Portrait = availableMen.removeFirst()
                        } else {
                            gameState.traveler3Portrait = availableWomen.removeFirst()
                        }

                        gameState.phase = .shop

                    } label: {

                        Text("Continue")
                            .font(.system(
                                size: 19,
                                weight: .bold,
                                design: .serif
                            ))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 36)
                            .padding(.vertical, 12)
                            .background(
                                Color(
                                    red: 0.18,
                                    green: 0.30,
                                    blue: 0.17
                                )
                            )
                            .clipShape(
                                RoundedRectangle(cornerRadius: 8)
                            )
                    }
                    .padding(.top, 4)
                    .disabled(!allTravelerNamesAreValid)
                    .opacity(allTravelerNamesAreValid ? 1 : 0.45)
                }
                .foregroundStyle(
                    Color(
                        red: 0.20,
                        green: 0.13,
                        blue: 0.08
                    )
                )
                .padding(isLandscape ? 18 : 24)
                .frame(
                    maxWidth: isLandscape ? 490 : 350
                )
                .background(
                    Color(
                        red: 0.94,
                        green: 0.87,
                        blue: 0.72
                    )
                    .opacity(0.92)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 14)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            Color(
                                red: 0.30,
                                green: 0.20,
                                blue: 0.12
                            ),
                            lineWidth: 4
                        )
                }
                
                
                
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height,
                alignment: .center
                
                )
            
            .toolbar(.hidden, for: .navigationBar)
        }
        
        
    }
    


    // MARK: - Traveler Field

    func travelerField(
        title: String,
        text: Binding<String>
    ) -> some View {

        VStack(alignment: .leading, spacing: 4) {

            Text(title)
                .font(.system(
                    size: 14,
                    weight: .bold,
                    design: .serif
                ))

            TextField("Enter name", text: text)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .frame(height: 36)
                .background(
                    Color.white.opacity(0.65)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 6)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            Color(
                                red: 0.40,
                                green: 0.28,
                                blue: 0.17
                            ),
                            lineWidth: 1
                        )
                }
        }
    }
    
    func genderPicker(
        selection: Binding<String>
    ) -> some View {

        HStack(spacing: 8) {

            Button {
                selection.wrappedValue = "Man"
            } label: {
                Text("Man")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(
                        selection.wrappedValue == "Man"
                        ? Color(red: 0.18, green: 0.30, blue: 0.17)
                        : Color.white.opacity(0.45)
                    )
                    .foregroundStyle(
                        selection.wrappedValue == "Man"
                        ? .white
                        : Color(red: 0.20, green: 0.13, blue: 0.08)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 6)
                    )
            }
            .buttonStyle(.plain)

            Button {
                selection.wrappedValue = "Woman"
            } label: {
                Text("Woman")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(
                        selection.wrappedValue == "Woman"
                        ? Color(red: 0.18, green: 0.30, blue: 0.17)
                        : Color.white.opacity(0.45)
                    )
                    .foregroundStyle(
                        selection.wrappedValue == "Woman"
                        ? .white
                        : Color(red: 0.20, green: 0.13, blue: 0.08)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 6)
                    )
            }
            .buttonStyle(.plain)
        }
        .font(.system(
            size: 14,
            weight: .bold,
            design: .serif
        ))
    }
}


#Preview {
    NavigationStack {
        PartySetupView()
    }
    .environmentObject(GameState())
}
