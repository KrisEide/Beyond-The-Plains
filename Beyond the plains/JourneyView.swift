import SwiftUI

struct JourneyView: View {
    
    @EnvironmentObject var gameState: GameState
    
    @State private var showInventory = false
    @State private var showResult = false
    @State private var resultText = ""
    
    @State private var huntingAvailable = true
    @State private var hasHuntedHere = false
    @State private var showHuntResult = false
    @State private var huntFoodGained = 0
    
    @State private var showEventUI = false
    @State private var isViewingBackground = false
    
    @State private var showTreatResult = false
    @State private var treatResultText = ""
    
    @State private var showTravelTransition = false
    @State private var isTravelTransitionRunning = false
    @State private var showTravelInfo = false
    @State private var travelBlackOpacity = 0.0
    @State private var travelTransitionText = ""
    @State private var travelInfoOpacity = 0.0
    @State private var weeksPassedDuringTransition = 1
    
    @State private var showTradingPost = false
    @State private var showTradingPostDecision = false
    
    
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let isLandscape =
            geometry.size.width > geometry.size.height

            let landscapeAvailableColumnWidth =
            geometry.size.width - 71
            let landscapeHUDWidth = min(
                370,
                landscapeAvailableColumnWidth - 280
            )
            let landscapeEventWidth = min(
                380,
                landscapeAvailableColumnWidth - landscapeHUDWidth
            )
            
            ZStack {
                
                // MARK: - Fullscreen Event Background
                
                Image(
                    journeyBackgroundImageName(
                        isLandscape: isLandscape
                    )
                )
                .resizable()
                .scaledToFill()
                .clipped()
                .ignoresSafeArea()
                
                
                // Litt mørkere øverst så HUD er lesbar
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.55),
                        Color.black.opacity(0.10),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .center
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .opacity(isViewingBackground ? 0 : 1)
                
                
                // MARK: - Main UI
                
                if isLandscape {
                    // HUD øverst
                    VStack {
                        HStack {
                            topHUD
                                .frame(width: landscapeHUDWidth)
                                .padding(.top, 25)
                                .padding(.leading, 35)
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    .opacity(showEventUI && !isViewingBackground ? 1 : 0)
                    .allowsHitTesting(showEventUI && !isViewingBackground)
                    
                    
                    // Eventboks til høyre
                    eventPanel(isLandscape: true)
                        .frame(width: landscapeEventWidth)
                        .offset(y: 15)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .trailing
                        )
                        .padding(.trailing, 20)
                        .opacity(showEventUI && !isViewingBackground ? 1 : 0)
                        .allowsHitTesting(showEventUI && !isViewingBackground)
                    
                } else {
                    VStack {
                        topHUD
                            .padding(.horizontal, 18)
                            .padding(.top, 8)
                        
                        Spacer()
                        
                        eventPanel(isLandscape: false)
                            .padding(.horizontal, 28)
                            .padding(
                                .bottom,
                                journeyEvent(
                                    for: gameState.currentDay,
                                    gameState: gameState
                                ).choices.count == 4
                                ? 70
                                : 24
                            )
                    }
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .opacity(showEventUI && !isViewingBackground ? 1 : 0)
                    .allowsHitTesting(showEventUI && !isViewingBackground)
                }
                
                
                if showHuntResult {
                    
                    Color.black.opacity(0.45)
                        .ignoresSafeArea()
                    
                    huntResultPanel
                }
                
                if showTreatResult {
                    
                    Color.black.opacity(0.45)
                        .ignoresSafeArea()
                    
                    treatmentResultPanel
                }
                
                if showTravelTransition {
                    
                    Color.black
                        .opacity(travelBlackOpacity)
                        .ignoresSafeArea()
                    
                    travelTransitionPanel
                        .opacity(travelInfoOpacity)
                }
                
                // MARK: - Inventory Overlay
                
                if showInventory {
                    
                    Color.black.opacity(0.55)
                        .ignoresSafeArea()
                    
                    inventoryPanel
                }
                if let ending = gameState.journeyEnding {
                    switch ending {
                    case .gameOver:
                        Color.black.opacity(0.72)
                            .ignoresSafeArea()

                        journeyEndingPanel(ending)

                    case .completedWithWagon,
                         .completedOnFoot,
                         .clockSuccess:
                        WinnerView(
                            ending: ending,
                            onPlayAgain: gameState.resetGame
                        )
                    }
                }
            }
            
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .task(id: gameState.currentDay) {
                
                // Under en reiseovergang styrer
                // runTravelTransition() UI-faden selv.
                if showTravelTransition {
                    return
                }
                
                showEventUI = false
                
                try? await Task.sleep(
                    nanoseconds: 3_000_000_000
                )
                
                if !Task.isCancelled {
                    withAnimation(.easeIn(duration: 2.0)) {
                        showEventUI = true
                    }
                }
            }
            .task(id: isViewingBackground) {
                guard isViewingBackground else { return }
                
                do {
                    try await Task.sleep(
                        nanoseconds: 5_000_000_000
                    )
                } catch {
                    return
                }
                
                withAnimation(.easeIn(duration: 1.0)) {
                    isViewingBackground = false
                }
            }
            
            .fullScreenCover(
                isPresented: $showTradingPost
            ) {
                TradingPostView {
                    showTradingPost = false
                    showTradingPostDecision = false
                    
                    Task {
                        await runTravelTransition()
                    }
                }
                .environmentObject(gameState)
            }
        }
    }
            
            func journeyEndingPanel(
                _ ending: JourneyEnding
            ) -> some View {

                VStack(spacing: 16) {
                    Text(ending.title)
                        .font(.system(
                            size: 27,
                            weight: .bold,
                            design: .serif
                        ))

                    Rectangle()
                        .fill(Color(red: 0.45, green: 0.31, blue: 0.18))
                        .frame(height: 1)

                    Text(ending.message)
                        .font(.system(
                            size: 17,
                            weight: .medium,
                            design: .serif
                        ))
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)

                    Button {
                        gameState.resetGame()
                    } label: {
                        Text("Play Again")
                            .frame(maxWidth: .infinity)
                            .choiceButtonStyle()
                    }
                }
                .foregroundStyle(
                    Color(red: 0.20, green: 0.13, blue: 0.08)
                )
                .padding(24)
                .frame(maxWidth: 370)
                .background(
                    Color(red: 0.94, green: 0.87, blue: 0.72)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            Color(red: 0.30, green: 0.20, blue: 0.12),
                            lineWidth: 4
                        )
                }
                .padding(.horizontal, 20)
            }
    
    // MARK: - TOP HUD
    
    var topHUD: some View {
        
        VStack(spacing: 14) {
            
            HStack(spacing: 14) {
                
                progressDots
                
                Button {
                    showInventory = true
                } label: {
                    Image("Inventory")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 42, height: 42)
                        .frame(width: 50, height: 50)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Button {
                    withAnimation(.easeOut(duration: 0.25)) {
                        isViewingBackground = true
                    }
                } label: {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 23, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(
                            Color.black.opacity(0.38),
                            in: Circle()
                        )
                        .overlay {
                            Circle()
                                .stroke(
                                    Color.white.opacity(0.65),
                                    lineWidth: 1.5
                                )
                        }
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("View background")
                .accessibilityHint("Hides the menus for five seconds")
                
                Spacer()
            }
            
            HStack {

                HStack(spacing: 8) {

                    Image(systemName: "snowflake")
                        .font(.system(size: 16, weight: .bold))

                    if gameState.isWinter {

                        Text("WINTER")

                    } else if gameState.weeksUntilWinter == 1 {

                        Text("1 week until winter")

                    } else {

                        Text("\(gameState.weeksUntilWinter) weeks until winter")
                    }
                }
                .font(.system(
                    size: 15,
                    weight: .bold,
                    design: .serif
                ))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Color(red: 0.12, green: 0.22, blue: 0.28)
                        .opacity(0.88)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 8)
                )

                Spacer()
            }
            .offset(y: -7)
            
            
            VStack(spacing: 14) {

                HStack(spacing: 0) {

                    travelerPortrait(
                        imageName: gameState.traveler1Portrait,
                        name: gameState.traveler1,
                        alive: gameState.traveler1Alive,
                        sick: gameState.sickTraveler == 1
                    )
                    .frame(maxWidth: .infinity)

                    travelerPortrait(
                        imageName: gameState.traveler2Portrait,
                        name: gameState.traveler2,
                        alive: gameState.traveler2Alive,
                        sick: gameState.sickTraveler == 2
                    )
                    .frame(maxWidth: .infinity)

                    travelerPortrait(
                        imageName: gameState.traveler3Portrait,
                        name: gameState.traveler3,
                        alive: gameState.traveler3Alive,
                        sick: gameState.sickTraveler == 3
                    )
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)

                HStack(spacing: 0) {

                    HStack(spacing: 7) {
                        Image("Food")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)

                        Text("\(gameState.food)")
                    }
                    .frame(maxWidth: .infinity)

                    Rectangle()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: 1, height: 30)

                    HStack(spacing: 7) {
                        Image("Ammo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)

                        Text("\(gameState.ammunition)")
                    }
                    .frame(maxWidth: .infinity)

                    Rectangle()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: 1, height: 30)

                    HStack(spacing: 7) {
                        Image("MedicSupplies")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)

                        Text("\(gameState.medicalSupplies)")
                    }
                    .frame(maxWidth: .infinity)

                    Rectangle()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: 1, height: 30)

                    HStack(spacing: 7) {
                        Image("Money")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)

                        Text("$\(gameState.money)")
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                }
                .font(.system(
                    size: 18,
                    weight: .bold,
                    design: .serif
                ))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    Color(red: 0.12, green: 0.22, blue: 0.28)
                        .opacity(0.88)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                HStack(spacing: 10) {

                    if huntingAvailable &&
                        gameState.hasRifle &&
                        gameState.ammunition > 0 &&
                        !hasHuntedHere {

                        huntAction
                    }

                    if gameState.sickTraveler != nil &&
                        gameState.medicalSupplies > 0 {

                        treatAction
                    }

                    Spacer()
                }
            }
            
            
            
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        
        
    }
    
    
    
    
    
    func travelerPortrait(
        imageName: String,
        name: String,
        alive: Bool,
        sick: Bool
    ) -> some View {

        ZStack {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 110, height: 110)
                .grayscale(alive ? 0 : 1)
                .opacity(alive ? 1 : 0.80)

            Text(name)
                .font(.system(
                    size: 12,
                    weight: .bold,
                    design: .serif
                ))
                .foregroundStyle(
                    Color(red: 0.20, green: 0.13, blue: 0.08)
                )
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: 67)
                .offset(y: 36)
            
            if sick && alive {
                Image(systemName: "cross.case.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.orange)
                    .offset(x: 32, y: -30)
            }
            
            if !alive {
                ZStack {
                    Rectangle()
                        .fill(Color.red.opacity(0.8))
                        .frame(width: 85, height: 3)
                        .rotationEffect(.degrees(45))

                    Rectangle()
                        .fill(Color.red.opacity(0.8))
                        .frame(width: 85, height: 3)
                        .rotationEffect(.degrees(-45))
                }
            }
        }
        .frame(width: 90, height: 90)
    }
    
    
    // MARK: - PROGRESS
    
    var progressDots: some View {
        
        HStack(spacing: 6) {
            
            ForEach(1...14, id: \.self) { number in
                
                Circle()
                    .fill(
                        number <= gameState.currentDay
                        ? Color.white
                        : Color.white.opacity(0.35)
                    )
                    .frame(width: 10, height: 10)
            }
        }
    }
    
    
    // MARK: - TRAVELER
    
    func travelerStatus(
        name: String,
        alive: Bool,
        sick: Bool
    ) -> some View {
        
        HStack(spacing: 4) {
            
            Text(name.isEmpty ? "Traveler" : name)
            
            if !alive {
                
                Image(systemName: "xmark.circle.fill")
                
            } else if sick {
                
                Image(systemName: "cross.case.fill")
                    .foregroundStyle(.orange)
                
            } else {
                
                Image(systemName: "checkmark.circle.fill")
            }
        }
        .font(.system(
            size: 17,
            weight: .bold,
            design: .serif
        ))
        .opacity(alive ? 1 : 0.45)
    }
    
    
    // MARK: - EVENT PANEL
    
    func eventPanel(isLandscape: Bool) -> some View {

        let event = journeyEvent(
            for: gameState.currentDay,
            gameState: gameState
        )

        return VStack(
            alignment: .leading,
            spacing: isLandscape ? 8 : 6
        ) {
            
            if showResult {
                
                Text("THE RESULT")
                    .font(.system(
                        size: 21,
                        weight: .bold,
                        design: .serif
                    ))
                
                Text(resultText)
                    .font(.system(
                        size: 16,
                        design: .serif
                    ))
                resultActionButtons
                
                
            } else {
                
                Text(event.title)
                    .font(.system(
                        size: isLandscape ? 20 : 24,
                        weight: .bold,
                        design: .serif
                    ))
                
                Rectangle()
                    .fill(
                        Color(red: 0.45, green: 0.31, blue: 0.18)
                    )
                    .frame(height: 1)
                
                Text(
                    event.description
                )
                .font(.system(
                    size: isLandscape ? 15 : 18,
                    weight: .medium,
                    design: .serif
                ))
                .lineSpacing(isLandscape ? 1 : 3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 4)
                
                
                ForEach(
                    event.choices,
                    id: \.number
                ) { choice in

                    let available =
                        isJourneyChoiceAvailable(
                            choice,
                            gameState: gameState
                        )

                    Button {
                        handleJourneyChoice(choice)
                    } label: {
                        eventChoice(
                            number: choice.number,
                            text: choice.text,
                            isLandscape: isLandscape
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!available)
                    .opacity(available ? 1 : 0.45)
                }
                .buttonStyle(.plain)
                
                
                
            }
        }
        .foregroundStyle(
            Color(
                red: 0.20,
                green: 0.13,
                blue: 0.08
            )
        )
        .padding(isLandscape ? 14 : 14)
        .background(
            Color(
                red: 0.94,
                green: 0.87,
                blue: 0.72
            )
            .opacity(0.94)
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
    
    @ViewBuilder
    var resultActionButtons: some View {
        // Day 8 after Work / Look for Work
        if gameState.currentDay == 8 &&
            showTradingPostDecision {

            Button {
                showTradingPost = true
            } label: {
                Text("Enter Shop")
                    .frame(maxWidth: .infinity)
                    .choiceButtonStyle()
            }
            .disabled(gameState.money < 30)
            .opacity(gameState.money < 30 ? 0.45 : 1)

            Button {
                showTradingPostDecision = false

                Task {
                    await runTravelTransition()
                }
            } label: {
                Text("Continue Journey")
                    .frame(maxWidth: .infinity)
                    .choiceButtonStyle()
            }
            .disabled(isTravelTransitionRunning)

        // Day 14 ends here. NO normal travel transition.
        } else if gameState.currentDay == 14 {

            Button {
                showResult = false

                if gameState.livingTravelerIndices().isEmpty {
                    gameState.journeyEnding = .gameOver
                } else {
                    gameState.journeyEnding =
                        gameState.pendingJourneyEnding ??
                        .completedWithWagon
                }
            } label: {
                Text("Finish Journey")
                    .frame(maxWidth: .infinity)
                    .choiceButtonStyle()
            }

        // All normal Days 1–13
        } else {

            Button {
                Task {
                    await runTravelTransition()
                }
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .choiceButtonStyle()
            }
            .disabled(isTravelTransitionRunning)
        }
    }
    
    func handleJourneyChoice(_ choice: JourneyChoice) {
        // Day 8 choice 1 goes straight into the store.
        if gameState.currentDay == 8 &&
            choice.number == 1 {
            
            gameState.pendingExtraWeeks = 0
            showTradingPostDecision = false
            showTradingPost = true
            return
        }
        
        gameState.pendingExtraWeeks = choice.extraWeeks
        
        resultText = resolveJourneyChoice(
            day: gameState.currentDay,
            choice: choice.number,
            gameState: gameState
        )
        
        showTradingPostDecision =
        gameState.currentDay == 8 &&
        (choice.number == 2 || choice.number == 3)
        
        showResult = true
        
    }
    
    // MARK: - INVENTORY
    
    var inventoryPanel: some View {
        
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            
            HStack {
                
                Text("INVENTORY")
                    .font(.system(
                        size: 23,
                        weight: .bold,
                        design: .serif
                    ))
                
                Spacer()
                
                Button {
                    showInventory = false
                } label: {
                    
                    Image(systemName: "xmark")
                        .font(.headline.bold())
                }
            }
            
            
            Divider()
            
            
            Text("Food: \(gameState.food)")
            Text("Ammo Packs: \(gameState.ammunition)")
            Text("Medical Supplies: \(gameState.medicalSupplies)")
            Text("Money: $\(gameState.money)")
            
            
            Divider()
            
            
            inventoryItem(
                name: "Rifle",
                owned: gameState.hasRifle
            )
            
            inventoryQuantityItem(
                name: "Tools",
                amount: gameState.tools
            )
            
            inventoryQuantityItem(
                name: "Warm Blankets",
                amount: gameState.blankets
            )
            
            inventoryQuantityItem(
                name: "Rope",
                amount: gameState.rope
            )
            
            inventoryItem(
                name: "Fiddle",
                owned: gameState.hasFiddle
            )
            
            inventoryItem(
                name: "Grandfather Clock",
                owned: gameState.hasGrandfatherClock
            )
        }
        .font(.system(
            size: 16,
            design: .serif
        ))
        .foregroundStyle(
            Color(
                red: 0.20,
                green: 0.13,
                blue: 0.08
            )
        )
        .padding(22)
        .frame(maxWidth: 350)
        .background(
            Color(
                red: 0.94,
                green: 0.87,
                blue: 0.72
            )
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
    
    var huntAction: some View {
        Button {

            huntFoodGained = Int.random(in: 2...4)
            gameState.ammunition -= 1
            gameState.food += huntFoodGained
            gameState.weeksPassed += 1
            
            hasHuntedHere = true
            showHuntResult = true
            
        } label: {
            HStack(spacing: 8) {
                Image("Rifle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .padding(5)
                    .background(
                        Color(red: 0.94, green: 0.87, blue: 0.72)
                    )
                    .clipShape(Circle())
                
                Text("Hunt")
                    .font(.system(size: 18, weight: .bold, design: .serif))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Color(red: 0.18, green: 0.30, blue: 0.17)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        Color(red: 0.30, green: 0.20, blue: 0.12),
                        lineWidth: 1.5
                    )
            }
        }
    }
    
    var treatAction: some View {
        
        Button {
            
            if let message = gameState.treatSickTraveler() {
                
                treatResultText = message
                showTreatResult = true
            }
            
        } label: {
            
            HStack(spacing: 8) {
                
                Image("MedicSupplies")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .padding(5)
                    .background(
                        Color(red: 0.94, green: 0.87, blue: 0.72)
                    )
                    .clipShape(Circle())
                
                Text("Treat")
                    .font(.system(
                        size: 18,
                        weight: .bold,
                        design: .serif
                    ))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Color(red: 0.18, green: 0.30, blue: 0.17)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 10)
            )
        }
        .buttonStyle(.plain)
    }
    
    var huntResultPanel: some View {
        
        VStack(spacing: 14) {
            
            Text("A GOOD HUNT")
                .font(.system(
                    size: 23,
                    weight: .bold,
                    design: .serif
                ))
            
            Rectangle()
                .fill(
                    Color(
                        red: 0.45,
                        green: 0.31,
                        blue: 0.18
                    )
                )
                .frame(height: 1)
            
            Text(
                "You follow fresh deer tracks into the woods and return to the wagon with enough meat for several days."
            )
            .font(.system(
                size: 17,
                weight: .medium,
                design: .serif
            ))
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            
            HStack(spacing: 12) {
                
                HStack(spacing: 6) {
                    
                    Image("Ammo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    
                    Text("-1 Ammo")
                }
                
                HStack(spacing: 6) {
                    
                    Image("Food")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    
                    Text("+\(huntFoodGained) Food")
                }

                HStack(spacing: 6) {

                    Image(systemName: "calendar")
                        .font(.system(size: 22, weight: .bold))
                        .frame(width: 30, height: 30)

                    Text("+1 Week")
                }
            }
            .font(.system(
                size: 15,
                weight: .bold,
                design: .serif
            ))
            
            Button {
                showHuntResult = false
            } label: {
                
                Text("Continue")
                    .font(.system(
                        size: 17,
                        weight: .bold,
                        design: .serif
                    ))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 10)
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
            .buttonStyle(.plain)
        }
        .foregroundStyle(
            Color(
                red: 0.20,
                green: 0.13,
                blue: 0.08
            )
        )
        .padding(20)
        .frame(maxWidth: 360)
        .background(
            Color(
                red: 0.94,
                green: 0.87,
                blue: 0.72
            )
            .opacity(0.97)
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
        .padding(.horizontal, 20)
    }
    
    var treatmentResultPanel: some View {
        
        VStack(spacing: 14) {
            
            Text("TREATED")
                .font(.system(
                    size: 23,
                    weight: .bold,
                    design: .serif
                ))
            
            Rectangle()
                .fill(
                    Color(red: 0.45, green: 0.31, blue: 0.18)
                )
                .frame(height: 1)
            
            Text(treatResultText)
                .font(.system(
                    size: 17,
                    weight: .medium,
                    design: .serif
                ))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
            
            HStack(spacing: 6) {
                
                Image("MedicSupplies")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                
                Text("-1 Medical Supply")
            }
            .font(.system(
                size: 15,
                weight: .bold,
                design: .serif
            ))
            
            Button {
                
                showTreatResult = false
                
            } label: {
                
                Text("Continue")
                    .font(.system(
                        size: 17,
                        weight: .bold,
                        design: .serif
                    ))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 10)
                    .background(
                        Color(red: 0.18, green: 0.30, blue: 0.17)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 8)
                    )
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(
            Color(red: 0.20, green: 0.13, blue: 0.08)
        )
        .padding(20)
        .frame(maxWidth: 360)
        .background(
            Color(red: 0.94, green: 0.87, blue: 0.72)
                .opacity(0.97)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 14)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    Color(red: 0.30, green: 0.20, blue: 0.12),
                    lineWidth: 4
                )
        }
        .padding(.horizontal, 20)
    }
    
        @MainActor
        func runTravelTransition() async {

            guard !isTravelTransitionRunning else { return }

            isTravelTransitionRunning = true

            defer {
                isTravelTransitionRunning = false

                if Task.isCancelled {
                    showTravelTransition = false
                    showEventUI = true
                    travelBlackOpacity = 0
                    travelInfoOpacity = 0
                }
            }

            showTravelTransition = true
            travelInfoOpacity = 0
            travelBlackOpacity = 0

            // 1. Fade slowly to black
            withAnimation(.easeInOut(duration: 2.0)) {
                travelBlackOpacity = 1
            }

            do {
                try await Task.sleep(
                    nanoseconds: 2_000_000_000
                )
            } catch {
                return
            }

            // Screen is black
            showEventUI = false

            // Time advances internally: normal + pending extra weeks
            weeksPassedDuringTransition = 1 + gameState.pendingExtraWeeks
            gameState.advanceTravelTime()

            let foodBeforeTravel = gameState.food
            let starvedTraveler = gameState.payTravelFood()
            let foodUsed = foodBeforeTravel - gameState.food

            var messages: [String] = []

            if foodUsed > 0 {
                messages.append("-\(foodUsed) Food")
            } else {
                messages.append("No Food remaining.")
            }

            let sickTravelerBeforeTravel = gameState.sickTraveler
            var sicknessResolved = false

            if let outcome = gameState.resolveSickness() {
                switch outcome {
                case .recovered(let name):
                    messages.append("\(name) recovered.")
                    sicknessResolved = true

                case .remainedSick:
                    if let index = sickTravelerBeforeTravel {
                        let name = gameState.travelerName(for: index)
                        messages.append("\(name) is still sick.")
                    }

                case .died(let name):
                    messages.append("\(name) did not survive the illness.")
                    sicknessResolved = true
                }
            }

            if let name = starvedTraveler {
                messages.append("\(name) died from starvation.")
            }

            showResult = false

            let everyoneIsDead =
                gameState.livingTravelerIndices().isEmpty

            // Only advance to another encounter if somebody survived.
            if !everyoneIsDead &&
                gameState.currentDay < 14 {

                gameState.currentDay += 1
                hasHuntedHere = false

                if gameState.currentDay == 5 {
                    gameState.scenario5UsesRidersBackground =
                        gameState.strangerTravelingWithYou
                }

                if gameState.currentDay == 11 {
                    gameState.prepareFallenTraveler()
                }
            }

            if !everyoneIsDead &&
                gameState.sickTraveler == nil &&
                !sicknessResolved &&
                starvedTraveler == nil {

                if let index = gameState.tryRandomSickness(
                    on: gameState.currentDay
                ) {
                    let name = gameState.travelerName(for: index)
                    messages.append("\(name) has fallen sick.")
                }
            }

            travelTransitionText =
                messages.joined(separator: "\n")

            // Transition panel fades in
            withAnimation(.easeInOut(duration: 1.5)) {
                travelInfoOpacity = 1
            }

            do {
                try await Task.sleep(
                    nanoseconds: 4_000_000_000
                )
            } catch {
                return
            }

            // Transition panel fades out
            withAnimation(.easeInOut(duration: 1.5)) {
                travelInfoOpacity = 0
            }

            do {
                try await Task.sleep(
                    nanoseconds: 1_500_000_000
                )
            } catch {
                return
            }

            // Small pause on black
            do {
                try await Task.sleep(
                    nanoseconds: 1_200_000_000
                )
            } catch {
                return
            }

            // Reveal the background
            withAnimation(.easeInOut(duration: 2.5)) {
                travelBlackOpacity = 0
            }

            do {
                try await Task.sleep(
                    nanoseconds: 2_500_000_000
                )
            } catch {
                return
            }

            // If the party died, do not reveal another event.
            if everyoneIsDead {
                gameState.journeyEnding = .gameOver
                showTravelTransition = false
                return
            }

            // Background alone for a moment
            do {
                try await Task.sleep(
                    nanoseconds: 2_500_000_000
                )
            } catch {
                return
            }

            // Event UI comes last
            withAnimation(.easeIn(duration: 2.0)) {
                showEventUI = true
            }

            do {
                try await Task.sleep(
                    nanoseconds: 2_000_000_000
                )
            } catch {
                return
            }

            showTravelTransition = false
        }
    
    var travelTransitionPanel: some View {
        VStack(spacing: 14) {

            Text(
                weeksPassedDuringTransition == 1
                ? "1 WEEK PASSES"
                : "\(weeksPassedDuringTransition) WEEKS PASS"
            )
                .font(.system(
                    size: 23,
                    weight: .bold,
                    design: .serif
                ))

            Rectangle()
                .fill(
                    Color(
                        red: 0.45,
                        green: 0.31,
                        blue: 0.18
                    )
                )
                .frame(height: 1)

            Text(travelTransitionText)
                .font(.system(
                    size: 17,
                    weight: .medium,
                    design: .serif
                ))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
        }
        .foregroundStyle(
            Color(
                red: 0.20,
                green: 0.13,
                blue: 0.08
            )
        )
        .padding(20)
        .frame(maxWidth: 360)
        .background(
            Color(
                red: 0.94,
                green: 0.87,
                blue: 0.72
            )
            .opacity(0.97)
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
        .padding(.horizontal, 20)
    }
    
    func inventoryItem(
        name: String,
        owned: Bool
    ) -> some View {
        
        HStack {
            
            Text(name)
            
            Spacer()
            
            if owned {
                Image(systemName: "checkmark")
            }
        }
        .opacity(owned ? 1 : 0.40)
    }

    func inventoryQuantityItem(
        name: String,
        amount: Int
    ) -> some View {

        HStack {
            Text(name)

            Spacer()

            Text("\(amount)")
        }
        .opacity(amount > 0 ? 1 : 0.40)
    }
    
    func journeyBackgroundImageName(
        isLandscape: Bool
    ) -> String {

        switch gameState.currentDay {

        case 1:
            return isLandscape ? "Month1Landscape" : "Month1Portrait"

        case 2:
            return isLandscape ? "Month2Landscape" : "Month2Portrait"

        case 3:
            return isLandscape ? "Month3Landscape" : "Month3Portrait"

        case 4:
            return isLandscape ? "Month4Landscape" : "Month4Portrait"

        case 5:
            if gameState.scenario5UsesRidersBackground {
                return isLandscape
                    ? "Month5RidersLandscape"
                    : "Month5RidersPortrait"
            }

            return isLandscape
                ? "Month5StagecoachLandscape"
                : "Month5StagecoachPortrait"

        case 6:
            return isLandscape ? "Month6Landscape" : "Month6Portrait"

        case 7:
            return isLandscape ? "Month7Landscape" : "Month7Portrait"

        case 8:
            return isLandscape ? "Month8Landscape" : "Month8Portrait"

        case 9:
            return isLandscape ? "Month9Landscape" : "Month9Portrait"

        case 10:
            return isLandscape ? "Month10Landscape" : "Month10Portrait"

        case 11:
            return isLandscape ? "Month11Landscape" : "Month11Portrait"

        case 12:
            return isLandscape ? "Month12Landscape" : "Month12Portrait"

        case 13:
            return isLandscape ? "Month13Landscape" : "Month13Portrait"

        case 14:
            return isLandscape ? "Month14Landscape" : "Month14Portrait"

        default:
            return isLandscape ? "Month1Landscape" : "Month1Portrait"
        }
    }
    
    func eventChoice(
        number: Int,
        text: String,
        isLandscape: Bool
    ) -> some View {
        
        HStack(spacing: isLandscape ? 10 : 14) {
            
            Text("\(number)")
                .font(.system(
                    size: isLandscape ? 13 : 15,
                    weight: .bold,
                    design: .serif
                ))
                .frame(
                    width: isLandscape ? 24 : 28,
                    height: isLandscape ? 24 : 28
                )
                .background(
                    Color(
                        red: 0.30,
                        green: 0.20,
                        blue: 0.12
                    )
                )
                .foregroundStyle(.white)
                .clipShape(Circle())
            
            Text(text)
                .font(.system(
                    size: isLandscape ? 15 : 17,
                    weight: .bold,
                    design: .serif
                ))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(
                    size: isLandscape ? 11 : 13,
                    weight: .bold
                ))
                .opacity(0.6)
        }
        .foregroundStyle(
            Color(
                red: 0.20,
                green: 0.13,
                blue: 0.08
            )
        )
        .padding(.horizontal, isLandscape ? 10 : 12)
        .frame(height: isLandscape ? 40 : 48)
        .background(
            Color.white.opacity(0.28)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 7)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 7)
                .stroke(
                    Color(
                        red: 0.40,
                        green: 0.28,
                        blue: 0.17
                    )
                    .opacity(0.65),
                    lineWidth: 1
                )
        }
    }
}
    
    // MARK: - Choice Button Style
    
    extension View {
        
        func choiceButtonStyle() -> some View {
            
            self
                .font(.system(
                    size: 16,
                    weight: .bold,
                    design: .serif
                ))
                .foregroundStyle(.white)
                .padding(.vertical, 11)
                .padding(.horizontal, 12)
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
    }
    
    
    #Preview {
        
        let gameState = GameState()
        
        gameState.hasRifle = true
        gameState.ammunition = 3
        gameState.money = 200
        gameState.food = 10
        
        gameState.traveler1Portrait = "Portrait_man1"
        gameState.traveler2Portrait = "Portrait_man4"
        gameState.traveler3Portrait = "Portrait_woman3"
        
       // gameState.traveler2Alive = false
        
        //gameState.sickTraveler = 2
        gameState.medicalSupplies = 2
        
        gameState.currentDay = 11
        gameState.sickTraveler = 2
        
        return JourneyView()
            .environmentObject(gameState)
    }
