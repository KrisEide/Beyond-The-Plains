
import SwiftUI
import Combine

enum SicknessOutcome {
    case recovered(name: String)
    case remainedSick(name: String)
    case died(name: String)
}

enum SicknessAttemptOutcome: Equatable {
    case becameSick(Int)
    case preventedByBlanket
}

enum GamePhase: Equatable {
    case start
    case shop
    case journey
    case result
    case partySetup
}

enum JourneyEnding {
    case completedWithWagon
    case completedOnFoot
    case clockSuccess
    case gameOver

    var title: LocalizedStringResource {
        switch self {
        case .completedWithWagon, .completedOnFoot:
            return "JOURNEY COMPLETE"
        case .clockSuccess:
            return "AGAINST ALL ODDS"
        case .gameOver:
            return "THE TRAIL ENDS HERE"
        }
    }

    var message: LocalizedStringResource {
        switch self {
        case .completedWithWagon:
            return "The surviving travelers reach the valley with the wagon. The western trail is finally behind you."
        case .completedOnFoot:
            return "The wagon is gone, but the surviving travelers make the final miles on foot. You reached the end of the trail."
        case .clockSuccess:
            return "You reach the valley with the wagon — and somehow the Grandfather Clock survived the entire journey west."
        case .gameOver:
            return "No one in the party survived the journey."
        }
    }
}

class GameState: ObservableObject {
    
    @Published var phase: GamePhase = .start
    @Published var currentDay = 1
    
    @Published var weakAxle = false
    @Published var damagedAxle = false

    @Published var money = 1000
    
    @Published var pendingJourneyEnding: JourneyEnding? = nil
    @Published var journeyEnding: JourneyEnding? = nil
    
    let foodPrice = 25
    let ammunitionPrice = 20
    let medicalSuppliesPrice = 100
    let riflePrice = 200
    
    let toolsPrice = 100
    let blanketsPrice = 80
    let ropePrice = 60
    let fiddlePrice = 150
    let grandfatherClockPrice = 200
    
    
    
    
    
    
    
    @Published var food = 0
    @Published var ammunition = 0
    @Published var medicalSupplies = 0
    @Published var hasRifle = false
    @Published var tools = 0
    @Published var blankets = 0
    @Published var rope = 0
    @Published var hasFiddle = false
    @Published var hasGrandfatherClock = false
    
    @Published var traveler1 = ""
    @Published var traveler2 = ""
    @Published var traveler3 = ""
    
    @Published var traveler1Alive = true
    @Published var traveler2Alive = true
    @Published var traveler3Alive = true
    
    @Published var sickTraveler: Int? = nil
    @Published var hasHadSickness = false
    
    @Published var weeksPassed = 0
    @Published var pendingExtraWeeks = 0
    
    @Published var traveler1Gender = "Man"
    @Published var traveler2Gender = "Man"
    @Published var traveler3Gender = "Woman"

    @Published var traveler1Portrait = ""
    @Published var traveler2Portrait = ""
    @Published var traveler3Portrait = ""
    
    @Published var helpedWoundedStranger = false
    @Published var strangerTravelingWithYou = false
    @Published var helpedOutlawEscape = false
    @Published var helpedOutlawWinShootout = false
    @Published var scenario5UsesRidersBackground = false
    
    @Published var carryingMail = false
    @Published var fallenTraveler: Int? = nil
    
    

    let winterStartAtWeek = 14
    
    var weeksUntilWinter: Int {
        max(0, winterStartAtWeek - weeksPassed)
    }

    var isWinter: Bool {
        weeksPassed >= winterStartAtWeek
    }

    var winterDangerIncrease: Int {
        guard isWinter else { return 0 }

        return (weeksPassed - winterStartAtWeek) * 10
    }

    var sicknessDeathChance: Int {
        min(60, 25 + winterDangerIncrease)
    }
    
    var travelFoodCost: Int {
        isWinter ? 2 : 1
    }
    
    func payTravelFood() -> String? {
        let cost = travelFoodCost

        if food >= cost {
            food -= cost
            return nil
        }

        food = 0

        guard let traveler = livingTravelerIndices().randomElement() else {
            return nil
        }

        let name = travelerName(for: traveler)

        setTravelerAlive(traveler, false)

        if sickTraveler == traveler {
            sickTraveler = nil
        }

        return name
    }
    
    func advanceTravelTime() {
        weeksPassed += 1 + pendingExtraWeeks
        pendingExtraWeeks = 0
    }
    
    
    // Food
    func buyFood() {
        guard money >= foodPrice else { return }

        food += 1
        money -= foodPrice
    }

    func removeFood() {
        guard food > 0 else { return }

        food -= 1
        money += foodPrice
    }
    
    // Ammo
    func buyAmmunition() {
        guard money >= ammunitionPrice else { return }

        ammunition += 1
        money -= ammunitionPrice
    }

    func removeAmmunition() {
        guard ammunition > 0 else { return }

        ammunition -= 1
        money += ammunitionPrice
    }
    
    // Medic Supplies
    func buyMedicalSupplies() {
        guard money >= medicalSuppliesPrice else { return }

        medicalSupplies += 1
        money -= medicalSuppliesPrice
    }

    func removeMedicalSupplies() {
        guard medicalSupplies > 0 else { return }

        medicalSupplies -= 1
        money += medicalSuppliesPrice
    }
    
    // Rifle
    func buyRifle() {
        guard !hasRifle else { return }
        guard money >= riflePrice else { return }

        hasRifle = true
        money -= riflePrice
    }

    func removeRifle() {
        guard hasRifle else { return }

        hasRifle = false
        money += riflePrice
    }
    
    // Tools
    func buyTools() {
        guard money >= toolsPrice else { return }

        tools += 1
        money -= toolsPrice
    }

    func removeTools() {
        guard tools > 0 else { return }

        tools -= 1
        money += toolsPrice
    }

   // Warm Blankets
    func buyBlankets() {
        guard money >= blanketsPrice else { return }

        blankets += 1
        money -= blanketsPrice
    }

    func removeBlankets() {
        guard blankets > 0 else { return }

        blankets -= 1
        money += blanketsPrice
    }

    // Rope
    func buyRope() {
        guard money >= ropePrice else { return }

        rope += 1
        money -= ropePrice
    }

    func removeRope() {
        guard rope > 0 else { return }

        rope -= 1
        money += ropePrice
    }

    // Fiddle
    func buyFiddle() {
        guard !hasFiddle else { return }
        guard money >= fiddlePrice else { return }

        hasFiddle = true
        money -= fiddlePrice
    }

    func removeFiddle() {
        guard hasFiddle else { return }

        hasFiddle = false
        money += fiddlePrice
    }

    // Grandfather Clock
    func buyGrandfatherClock() {
        guard !hasGrandfatherClock else { return }
        guard money >= grandfatherClockPrice else { return }

        hasGrandfatherClock = true
        money -= grandfatherClockPrice
    }

    func removeGrandfatherClock() {
        guard hasGrandfatherClock else { return }

        hasGrandfatherClock = false
        money += grandfatherClockPrice
    }
    
    func livingTravelerIndices() -> [Int] {

        var livingTravelers: [Int] = []

        if traveler1Alive {
            livingTravelers.append(1)
        }

        if traveler2Alive {
            livingTravelers.append(2)
        }

        if traveler3Alive {
            livingTravelers.append(3)
        }

        return livingTravelers
    }
    
    func travelerName(for index: Int) -> String {

        switch index {

        case 1:
            return traveler1

        case 2:
            return traveler2

        case 3:
            return traveler3

        default:
            return ""
        }
    }
    
    func isTravelerAlive(_ index: Int) -> Bool {

        switch index {

        case 1:
            return traveler1Alive

        case 2:
            return traveler2Alive

        case 3:
            return traveler3Alive

        default:
            return false
        }
    }
    
    func setTravelerAlive(_ index: Int, _ alive: Bool) {

        switch index {

        case 1:
            traveler1Alive = alive

        case 2:
            traveler2Alive = alive

        case 3:
            traveler3Alive = alive

        default:
            break
        }
    }
    
    @discardableResult
    func makeTravelerSick(_ index: Int) -> Bool {

        guard sickTraveler == nil else {
            return false
        }

        guard isTravelerAlive(index) else {
            return false
        }

        sickTraveler = index
        hasHadSickness = true

        return true
    }
    
    func treatSickTraveler() -> String? {

        guard let index = sickTraveler else {
            return nil
        }

        guard medicalSupplies > 0 else {
            return nil
        }

        medicalSupplies -= 1
        sickTraveler = nil

        let name = travelerName(for: index)

        return "\(name) receives medicine and begins to recover."
    }
    
    func resolveSickness() -> SicknessOutcome? {

        guard let index = sickTraveler else {
            return nil
        }

        let name = travelerName(for: index)
        let roll = Int.random(in: 1...100)

        if roll <= 20 {

            sickTraveler = nil
            return .recovered(name: name)

        } else if roll <= 100 - sicknessDeathChance {

            return .remainedSick(name: name)

        } else {

            setTravelerAlive(index, false)
            sickTraveler = nil

            return .died(name: name)
        }
    }
    
    func sicknessChance(for day: Int) -> Int {
        let baseChance: Int

        switch day {
        
        case 3:
            baseChance = 20
        case 5:
            baseChance = 25
        case 8:
            baseChance = 25
        default:
            baseChance = 5
        }

        if isWinter {
            return min(
                60,
                baseChance + 15 + winterDangerIncrease
            )
        }

        return baseChance
    }
    
    func tryRandomSickness(on day: Int) -> SicknessAttemptOutcome? {

        guard sickTraveler == nil else {
            return nil
        }

        let livingTravelers = livingTravelerIndices()

        guard !livingTravelers.isEmpty else {
            return nil
        }

        let shouldBecomeSick: Bool

        if day == 8 && !hasHadSickness {

            shouldBecomeSick = true

        } else {

            let roll = Int.random(in: 1...100)

            shouldBecomeSick =
                roll <= sicknessChance(for: day)
        }

        guard shouldBecomeSick else {
            return nil
        }

        if isWinter && blankets > 0 {
            blankets -= 1
            return .preventedByBlanket
        }

        guard let randomTraveler =
            livingTravelers.randomElement() else {
            return nil
        }

        makeTravelerSick(randomTraveler)

        return .becameSick(randomTraveler)
    }
    
    var livingTravelerCount: Int {
        livingTravelerIndices().count
    }

    func prepareFallenTraveler() {
        if let fallenTraveler,
           isTravelerAlive(fallenTraveler) {
            return
        }

        fallenTraveler = livingTravelerIndices().randomElement()
    }

    func loseWagonAndSupplies() {
        food = 0
        ammunition = 0
        medicalSupplies = 0

        hasRifle = false
        tools = 0
        blankets = 0
        rope = 0
        hasFiddle = false
        hasGrandfatherClock = false
    }

    func resetGame() {
        currentDay = 1

        weakAxle = false
        damagedAxle = false

        money = 1000

        pendingJourneyEnding = nil
        journeyEnding = nil

        food = 0
        ammunition = 0
        medicalSupplies = 0
        hasRifle = false
        tools = 0
        blankets = 0
        rope = 0
        hasFiddle = false
        hasGrandfatherClock = false

        traveler1 = ""
        traveler2 = ""
        traveler3 = ""

        traveler1Alive = true
        traveler2Alive = true
        traveler3Alive = true

        sickTraveler = nil
        hasHadSickness = false

        weeksPassed = 0
        pendingExtraWeeks = 0

        traveler1Gender = "Man"
        traveler2Gender = "Man"
        traveler3Gender = "Woman"

        traveler1Portrait = ""
        traveler2Portrait = ""
        traveler3Portrait = ""

        helpedWoundedStranger = false
        strangerTravelingWithYou = false
        helpedOutlawEscape = false
        helpedOutlawWinShootout = false
        scenario5UsesRidersBackground = false

        carryingMail = false
        fallenTraveler = nil

        phase = .start
    }
}
