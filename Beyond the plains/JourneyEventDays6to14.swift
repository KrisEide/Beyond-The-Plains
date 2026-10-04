import Foundation

enum SupplyLossCategory: CaseIterable {
    case medical
    case ammo
    case blankets
    case food
}

func journeyEventDays6to14(
    for day: Int,
    gameState: GameState
) -> JourneyEvent? {
    switch day {
    case 6:
        return JourneyEvent(
            title: "THE NARROW PASS",
            description: "The trail narrows between steep rock walls. Deep ruts and loose stone leave little room for the wagon to pass safely.",
            choices: [
                JourneyChoice(number: 1, text: "Reinforce the Wagon — Tools", requirement: .item(.tools)),
                JourneyChoice(number: 2, text: "Secure the Load — Rope", requirement: .item(.rope)),
                JourneyChoice(number: 3, text: "Take the Lower Trail", requirement: .none, extraWeeks: 1),
                JourneyChoice(number: 4, text: "Push Through", requirement: .none)
            ]
        )

    case 7:
        return JourneyEvent(
            title: "WAGON CAMP",
            description: "A group of travelers with several wagons has stopped beside the trail. Several cargo crates were damaged on the rough road, and the exhausted travelers are preparing to camp for the night.",
            choices: [
                JourneyChoice(number: 1, text: "Repair the Cargo Crates — Tools", requirement: .item(.tools)),
                JourneyChoice(number: 2, text: "Stand Guard for the Night", requirement: .rifleAndAmmo(1)),
                JourneyChoice(number: 3, text: "Play Around the Campfire — Fiddle", requirement: .item(.fiddle)),
                JourneyChoice(number: 4, text: "Move On", requirement: .none)
            ]
        )

    case 8:
        let thirdChoiceText = gameState.carryingMail
            ? "Deliver the Mail — $100"
            : "Look for Work"

        return JourneyEvent(
            title: "TRADING POST",
            description: "A small trading post stands beside the trail. Supplies are expensive this far west, but this may be your last good chance to prepare for the country ahead.",
            choices: [
                JourneyChoice(number: 1, text: "Enter Shop", requirement: .money(30)),
                JourneyChoice(number: 2, text: "Work a week for pay", requirement: .none, extraWeeks: 1),
                JourneyChoice(number: 3, text: thirdChoiceText, requirement: .none)
            ]
        )

    case 9:
        return JourneyEvent(
            title: "SOAKED AND SHIVERING",
            description: "Cold rain has followed you since morning. By evening your clothes are soaked and the temperature is dropping fast.",
            choices: [
                JourneyChoice(number: 1, text: "Use the Warm Blankets", requirement: .item(.blankets)),
                JourneyChoice(number: 2, text: "Build a Shelter — Tools", requirement: .item(.tools)),
                JourneyChoice(number: 3, text: "Wait Out the Weather", requirement: .none, extraWeeks: 1),
                JourneyChoice(number: 4, text: "Keep Moving", requirement: .none)
            ]
        )

    case 10:
        if gameState.helpedOutlawWinShootout {
            return JourneyEvent(
                title: "RIDERS AHEAD",
                description: "Armed men block the trail. Before they can close in, familiar riders appear on the ridge. The outlaw remembers what you did for him.",
                choices: [
                    JourneyChoice(number: 1, text: "Ride On", requirement: .none)
                ]
            )
        }

        let detourText: String
        let detourWeeks: Int

        if gameState.helpedWoundedStranger {
            detourText = "Follow the Stranger's Hidden Trail"
            detourWeeks = 0
        } else {
            detourWeeks = gameState.helpedOutlawEscape ? 1 : 2
            detourText = "Take the Badlands Detour — +\(detourWeeks) \(detourWeeks == 1 ? "Week" : "Weeks")"
        }

        return JourneyEvent(
            title: "BANDITS ON THE TRAIL",
            description: "Several armed bandits block the trail and demand payment before they will let the wagon pass.",
            choices: [
                JourneyChoice(number: 1, text: "Pay Them — $100", requirement: .money(100)),
                JourneyChoice(number: 2, text: "Give Supplies", requirement: .foodAndAmmo(food: 2, ammo: 1)),
                JourneyChoice(number: 3, text: "Fight!", requirement: .rifleAndAmmo(2)),
                JourneyChoice(
                    number: 4,
                    text: detourText,
                    requirement: .none,
                    extraWeeks: detourWeeks
                )
            ]
        )

    case 11:
        let fallenTraveler = gameState.fallenTraveler
            ?? gameState.livingTravelerIndices().first
        let fallenTravelerName = fallenTraveler.map {
            gameState.travelerName(for: $0)
        } ?? "A traveler"

        if gameState.livingTravelerCount == 1 {
            return JourneyEvent(
                title: "A TRAVELER FALLS",
                description: "On a narrow mountain trail, \(fallenTravelerName) slips down a steep slope and lands on a rocky ledge. The wagon remains above, but the only way back is a dangerous climb.",
                choices: [
                    JourneyChoice(number: 1, text: "Climb Using the Rope", requirement: .item(.rope)),
                    JourneyChoice(number: 2, text: "Wait for Help", requirement: .none, extraWeeks: 1),
                    JourneyChoice(number: 3, text: "Climb Without Equipment", requirement: .none)
                ]
            )
        }

        return JourneyEvent(
            title: "A TRAVELER FALLS",
            description: "On a narrow mountain trail, \(fallenTravelerName) slips down a steep slope and lands on a rocky ledge. The others must decide how far they will go to bring \(fallenTravelerName) back.",
            choices: [
                JourneyChoice(number: 1, text: "Lower the Rope", requirement: .item(.rope)),
                JourneyChoice(number: 2, text: "Find a Safer Way Down", requirement: .none, extraWeeks: 1),
                JourneyChoice(number: 3, text: "Climb Down Without Equipment", requirement: .none),
                JourneyChoice(number: 4, text: "Leave Them Behind", requirement: .none)
            ]
        )

    case 12:
        return JourneyEvent(
            title: "THIEVES IN THE NIGHT",
            description: "You wake to movement beside the wagon. Someone is already pulling at the supplies in the darkness.",
            choices: [
                JourneyChoice(number: 1, text: "Fire a Warning Shot", requirement: .rifleAndAmmo(1)),
                JourneyChoice(number: 2, text: "Protect the Group", requirement: .none),
                JourneyChoice(number: 3, text: "Chase Them Into the Dark", requirement: .none)
            ]
        )

    case 13:
        return JourneyEvent(
            title: "WHITEOUT",
            description: "A wall of snow rolls over the mountains. Within minutes the trail disappears beneath the storm.",
            choices: [
                JourneyChoice(number: 1, text: "Use the Warm Blankets", requirement: .item(.blankets)),
                JourneyChoice(number: 2, text: "Burn the Fiddle", requirement: .item(.fiddle)),
                JourneyChoice(number: 3, text: "Retreat Below the Treeline", requirement: .none, extraWeeks: 2),
                JourneyChoice(number: 4, text: "Push Through the Whiteout", requirement: .none)
            ]
        )

    case 14:
        return JourneyEvent(
            title: "THE FINAL DESCENT",
            description: "Beyond the ridge lies the valley you have been trying to reach. One steep descent remains, and a runaway wagon could end the journey here.",
            choices: [
                JourneyChoice(number: 1, text: "Secure the Wagon — Rope", requirement: .item(.rope)),
                JourneyChoice(number: 2, text: "Reinforce the Wagon — Tools", requirement: .item(.tools)),
                JourneyChoice(number: 3, text: "Leave the Wagon Behind", requirement: .none),
                JourneyChoice(number: 4, text: "Descend Without Preparation", requirement: .none)
            ]
        )

    default:
        return nil
    }
}

func resolveJourneyChoiceDays6to14(
    day: Int,
    choice: Int,
    gameState: GameState
) -> String? {
    switch day {
    case 6:
        switch choice {
        case 1:
            gameState.tools = max(0, gameState.tools - 1)
            gameState.weakAxle = false
            gameState.damagedAxle = false
            return "You reinforce the damaged wagon before entering the pass. The repair holds firm, but the Tools are used up."
        case 2:
            gameState.rope = max(0, gameState.rope - 1)
            return "You bind the cargo tightly before entering the pass. Nothing is lost, but the Rope is used up."
        case 3:
            return "You turn away from the narrow pass and follow the lower trail. The route is safer, but it costs another week."
        case 4:
            return resolveDay6PushThrough(gameState: gameState, roll: Int.random(in: 1...100))
        default:
            return ""
        }

    case 7:
        switch choice {
        case 1:
            gameState.tools = max(0, gameState.tools - 1)
            gameState.money += 130
            return "You spend the day repairing the broken cargo crates and securing their supplies. The work wears out your Tools, but the grateful travelers pay you $130."
        case 2:
            gameState.ammunition = max(0, gameState.ammunition - 1)
            gameState.money += 80
            return "You stand guard through the night. One warning shot keeps trouble away. You use 1 Ammo and earn $80."
        case 3:
            gameState.food += 2
            return "Music carries across the camp after dark. Grateful for the good spirits, the travelers share their supper and give you provisions for the road. You gain 2 Food."
        case 4:
            return "You keep your supplies and continue west without stopping."
        default:
            return ""
        }

    case 8:
        switch choice {
        case 1:
            return "You head inside the trading post."
        case 2:
            gameState.money += 80
            return "You spend a week hauling freight, repairing fences, and working around the post. You earn $80."
        case 3:
            if gameState.carryingMail {
                gameState.carryingMail = false
                gameState.money += 100
                return "You deliver the sealed mail bag at the trading post. The postmaster pays you $100 for carrying it safely west."
            }
            return resolveDay8LookForWork(gameState: gameState, roll: Int.random(in: 1...100))
        default:
            return ""
        }

    case 9:
        switch choice {
        case 1:
            gameState.blankets = max(0, gameState.blankets - 1)
            return "You use the Warm Blankets and wait through the worst of the cold rain. Everyone stays warm enough. You use 1 Warm Blanket."
        case 2:
            gameState.tools = max(0, gameState.tools - 1)
            return "You use the Tools to build a strong shelter beside the trail. The Tools are worn out, but the group stays dry."
        case 3:
            return "You make camp and wait for the weather to break. A week passes before the trail is safe again."
        case 4:
            return resolveDay9KeepMoving(gameState: gameState, roll: Int.random(in: 1...100))
        default:
            return ""
        }

    case 10:
        if gameState.helpedOutlawWinShootout {
            guard choice == 1 else { return "" }
            gameState.ammunition += 1
            return "The outlaw and his riders drive the bandits from the trail. Before leaving, he tosses you a spare Ammo pack. You gain 1 Ammo."
        }

        switch choice {
        case 1:
            gameState.money = max(0, gameState.money - 100)
            return "You pay the bandits $100. They count the money and let the wagon pass."
        case 2:
            gameState.food = max(0, gameState.food - 2)
            gameState.ammunition = max(0, gameState.ammunition - 1)
            return "You hand over 2 Food and 1 Ammo. The bandits take the supplies and clear the road."
        case 3:
            return resolveDay10Fight(gameState: gameState, roll: Int.random(in: 1...100))
        case 4:
            if gameState.helpedWoundedStranger {
                gameState.helpedWoundedStranger = false
                return "The wounded stranger appears on horseback near the trail. Remembering your kindness, he leads the wagon through a hidden pass around the bandits. By nightfall, you are safely back on the western trail."
            }
            if gameState.helpedOutlawEscape {
                return "The outlaw's warning helps you find the safer route around the ambush. The detour costs one week."
            }
            return "You turn into the badlands and spend two weeks finding a way around the bandits."
        default:
            return ""
        }

    case 11:
        return resolveDay11TravelerFall(
            choice: choice,
            gameState: gameState,
            roll: Int.random(in: 1...100)
        )

    case 12:
        switch choice {
        case 1:
            gameState.ammunition = max(0, gameState.ammunition - 1)
            return "A shot cracks through the darkness. The thieves abandon the wagon and disappear into the night. You use 1 Ammo."
        case 2:
            let hasSuppliesToSteal =
                gameState.medicalSupplies > 0 ||
                gameState.ammunition > 0 ||
                gameState.blankets > 0 ||
                gameState.food > 0

            guard hasSuppliesToSteal else {
                return "You stay together and protect the travelers. The thieves search the wagon, but find nothing useful to steal. They disappear into the darkness empty-handed."
            }

            return "You stay together and protect the travelers instead of risking a fight. The thieves escape with part of your supplies. " + loseRandomEligibleSupply(gameState: gameState)
        case 3:
            return resolveDay12Chase(gameState: gameState, roll: Int.random(in: 1...100))
        default:
            return ""
        }

    case 13:
        switch choice {
        case 1:
            gameState.blankets = max(0, gameState.blankets - 1)
            return "You wrap the group in the Warm Blankets and shelter behind the wagon. The blankets are ruined by the storm, but everyone survives the night."
        case 2:
            gameState.hasFiddle = false
            return "You break apart the Fiddle and use its dry wood as kindling. The instrument is lost, but the fire keeps the group warm through the storm."
        case 3:
            return "You retreat below the treeline and wait for the storm to pass. Two weeks are lost before you can climb back to the trail."
        case 4:
            return resolveDay13Whiteout(gameState: gameState, roll: Int.random(in: 1...100))
        default:
            return ""
        }

    case 14:
        switch choice {
        case 1:
            gameState.rope = max(0, gameState.rope - 1)
            gameState.pendingJourneyEnding = gameState.hasGrandfatherClock ? .clockSuccess : .completedWithWagon
            return "You secure the wagon with the Rope and guide it carefully down the slope. The valley finally opens ahead. You made it."
        case 2:
            gameState.tools = max(0, gameState.tools - 1)
            gameState.pendingJourneyEnding = gameState.hasGrandfatherClock ? .clockSuccess : .completedWithWagon
            return "You reinforce the wagon before the descent. The repair holds all the way into the valley. You made it."
        case 3:
            gameState.loseWagonAndSupplies()
            gameState.pendingJourneyEnding = .completedOnFoot
            return "You leave the wagon and everything too heavy to carry. The surviving travelers make the final descent on foot. You made it."
        case 4:
            return resolveDay14Descent(gameState: gameState, roll: Int.random(in: 1...100))
        default:
            return ""
        }

    default:
        return nil
    }
}

func resolveDay6PushThrough(
    gameState: GameState,
    roll: Int,
    forcedTraveler: Int? = nil
) -> String {
    if gameState.damagedAxle {
        if roll <= 40 {
            return "The damaged wagon groans through the pass, but somehow holds together."
        }
        if roll <= 80 {
            return "The wagon strikes the rock wall and part of the load breaks loose. " + loseRandomEligibleSupply(gameState: gameState)
        }
        if let name = killRandomLivingTraveler(gameState: gameState, forcedTraveler: forcedTraveler) {
            return "The damaged wagon lurches violently in the narrow pass. \(name) is thrown against the rocks and killed."
        }
        return "The wagon nearly overturns, but there is no one left to lose."
    }

    if gameState.weakAxle {
        if roll <= 55 {
            return "The temporary axle repair creaks through the pass, but it holds."
        }
        return "The weak wagon jolts hard against the rocks. " + loseRandomEligibleSupply(gameState: gameState)
    }

    if roll <= 80 {
        return "The wagon squeezes through the narrow pass without serious trouble."
    }

    return "The wagon clips the rock wall and part of the load is damaged. " + loseRandomEligibleSupply(gameState: gameState)
}

func resolveDay8LookForWork(
    gameState: GameState,
    roll: Int
) -> String {
    switch roll {
    case 1...45:
        return "You ask around the trading post, but no one has work to offer."
    case 46...60:
        gameState.money += 30
        return "A trader pays you for helping move a heavy crate. You gain $30."
    case 61...70:
        gameState.food += 1
        return "You help prepare meals at the trading post and receive provisions as payment. You gain 1 Food."
    case 71...80:
        gameState.ammunition += 1
        return "An old hunter pays you with a small Ammo pack after you help clean and carry his gear. You gain 1 Ammo."
    case 81...85:
        gameState.medicalSupplies += 1
        return "You assist a traveling doctor for the day and receive a spare medical kit. You gain 1 Medical Supply."
    default:
        gameState.pendingExtraWeeks += 1
        return "You accept a difficult job, but the dishonest employer disappears without paying you. A week is wasted."
    }
}

func resolveDay9KeepMoving(
    gameState: GameState,
    roll: Int,
    forcedTraveler: Int? = nil
) -> String {
    if let sick = gameState.sickTraveler {
        let deathChance = gameState.isWinter ? 45 : 30
        if roll <= deathChance {
            let name = gameState.travelerName(for: sick)
            gameState.setTravelerAlive(sick, false)
            gameState.sickTraveler = nil
            return "The cold rain becomes too much for \(name). \(name) dies from exposure."
        }
        return "The group pushes through the rain. The sick traveler survives, but the night is miserable."
    }

    let sicknessChance = gameState.isWinter ? 60 : 45
    if roll <= sicknessChance,
       let name = tryEventSickness(gameState: gameState, forcedTraveler: forcedTraveler) {
        return "The group keeps moving in soaked clothes. By nightfall, \(name) has fallen sick."
    }

    return "You keep moving through the cold rain and reach drier ground without anyone falling ill."
}

func resolveDay10Fight(
    gameState: GameState,
    roll: Int,
    forcedTraveler: Int? = nil
) -> String {
    gameState.ammunition = max(0, gameState.ammunition - 2)

    if roll <= 60 {
        return "Gunfire erupts along the trail. The bandits break first and flee. You use 2 Ammo."
    }

    if roll <= 85 {
        let extraAmmo = min(Int.random(in: 1...2), gameState.ammunition)
        gameState.ammunition -= extraAmmo
        if extraAmmo == 0 {
            return "The fight drags on before the bandits retreat. You use 2 Ammo."
        }

        return "The fight drags on before the bandits retreat. You use 2 Ammo, plus \(extraAmmo) more during the fighting."
    }

    if let name = killRandomLivingTraveler(gameState: gameState, forcedTraveler: forcedTraveler) {
        return "The fight turns deadly. \(name) is shot and killed before the bandits retreat. You use 2 Ammo."
    }

    return "The shooting finally stops."
}

func resolveDay12Chase(
    gameState: GameState,
    roll: Int,
    forcedTraveler: Int? = nil
) -> String {
    if roll <= 55 {
        return "You charge into the darkness. The thieves panic and abandon what they were carrying."
    }

    if roll <= 85 {
        return "The thieves escape into the dark with part of your supplies. " + loseRandomEligibleSupply(gameState: gameState)
    }

    if let name = killRandomLivingTraveler(gameState: gameState, forcedTraveler: forcedTraveler) {
        return "The chase turns into a violent struggle in the dark. \(name) is killed before the thieves disappear."
    }

    return "The thieves vanish into the darkness."
}

func resolveDay13Whiteout(
    gameState: GameState,
    roll: Int,
    forcedTraveler: Int? = nil
) -> String {
    let safeCutoff = gameState.isWinter ? 35 : 55
    let sicknessCutoff = gameState.isWinter ? 75 : 90

    if roll <= safeCutoff {
        return "You force the wagon through the whiteout. Hours later the trail appears again beneath the snow."
    }

    if roll <= sicknessCutoff {
        if let name = tryEventSickness(gameState: gameState, forcedTraveler: forcedTraveler) {
            return "The group pushes through the freezing storm. By the time you find shelter, \(name) has fallen sick."
        }
        return "The storm drains what little strength the group has left, but no second traveler can fall sick."
    }

    if let name = killRandomLivingTraveler(gameState: gameState, forcedTraveler: forcedTraveler) {
        return "Visibility disappears completely in the storm. \(name) is lost in the whiteout and does not survive."
    }

    return "The storm swallows the trail."
}

func resolveDay11TravelerFall(
    choice: Int,
    gameState: GameState,
    roll: Int,
    forcedCasualty: Int? = nil
) -> String {
    guard let fallenTraveler = gameState.fallenTraveler
        ?? gameState.livingTravelerIndices().first else {
        return "There is no one left to rescue."
    }

    let fallenTravelerName = gameState.travelerName(for: fallenTraveler)
    let livingTravelers = gameState.livingTravelerIndices()
    let isAlone = livingTravelers.count == 1

    switch choice {
    case 1:
        gameState.rope = max(0, gameState.rope - 1)

        if isAlone {
            return "\(fallenTravelerName) anchors the Rope against the rocks and climbs back to the wagon. You use 1 Rope."
        }

        return "The others lower the Rope and pull \(fallenTravelerName) safely back to the trail. You use 1 Rope."

    case 2:
        if isAlone && roll > 75 {
            gameState.setTravelerAlive(fallenTraveler, false)

            if gameState.sickTraveler == fallenTraveler {
                gameState.sickTraveler = nil
            }

            return "\(fallenTravelerName) waits on the ledge, but no other travelers come along. The cold becomes unbearable, and \(fallenTravelerName) does not survive."
        }

        let becameSick = gameState.makeTravelerSick(fallenTraveler)

        if isAlone {
            return "A passing wagon finally hears \(fallenTravelerName)'s calls and brings a Rope. After a week on the exposed ledge, \(fallenTravelerName) is rescued\(becameSick ? " but has fallen sick" : "")."
        }

        return "The group spends a week finding a safer route down to the ledge. \(fallenTravelerName) is brought back alive\(becameSick ? " but has fallen sick from the cold" : "")."

    case 3:
        if roll <= 60 {
            if isAlone {
                return "\(fallenTravelerName) finds enough handholds to climb back to the trail without equipment."
            }

            return "One traveler climbs down without equipment and guides \(fallenTravelerName) back to the trail. Both return safely."
        }

        if isAlone {
            gameState.setTravelerAlive(fallenTraveler, false)

            if gameState.sickTraveler == fallenTraveler {
                gameState.sickTraveler = nil
            }

            return "\(fallenTravelerName) loses their grip during the climb and falls. No one survives the journey."
        }

        let rescuer = livingTravelers
            .filter { $0 != fallenTraveler }
            .randomElement()
        let possibleCasualties = [fallenTraveler, rescuer].compactMap { $0 }
        let casualty: Int

        if let forcedCasualty,
           possibleCasualties.contains(forcedCasualty) {
            casualty = forcedCasualty
        } else {
            casualty = possibleCasualties.randomElement() ?? fallenTraveler
        }

        let casualtyName = gameState.travelerName(for: casualty)
        gameState.setTravelerAlive(casualty, false)

        if gameState.sickTraveler == casualty {
            gameState.sickTraveler = nil
        }

        if casualty == fallenTraveler {
            return "The rescue attempt goes wrong. \(fallenTravelerName) loses their grip and falls before the others can reach them."
        }

        return "The rescuer reaches \(fallenTravelerName) and helps them onto safe ground, but \(casualtyName) slips during the climb and falls."

    case 4:
        guard !isAlone else { return "" }

        gameState.setTravelerAlive(fallenTraveler, false)

        if gameState.sickTraveler == fallenTraveler {
            gameState.sickTraveler = nil
        }

        return "The group cannot risk another life on the slope. They leave \(fallenTravelerName) behind and continue west."

    default:
        return ""
    }
}

func resolveDay14Descent(
    gameState: GameState,
    roll: Int,
    forcedTraveler: Int? = nil
) -> String {
    let baseFullCutoff: Int
    let wagonLossCutoff: Int

    if gameState.damagedAxle {
        baseFullCutoff = 35
        wagonLossCutoff = 75
    } else if gameState.weakAxle {
        baseFullCutoff = 55
        wagonLossCutoff = 85
    } else {
        baseFullCutoff = 75
        wagonLossCutoff = 95
    }

    let fullCutoff = gameState.hasGrandfatherClock
        ? max(0, baseFullCutoff - 10)
        : baseFullCutoff

    if roll <= fullCutoff {
        gameState.pendingJourneyEnding = gameState.hasGrandfatherClock
            ? .clockSuccess
            : .completedWithWagon
        return "The wagon holds together all the way down. The valley opens ahead and the journey is finally over."
    }

    if roll <= wagonLossCutoff {
        gameState.loseWagonAndSupplies()
        gameState.pendingJourneyEnding = .completedOnFoot
        return "The wagon breaks loose on the descent and is lost, but the travelers escape before it goes over the slope. You finish the journey on foot."
    }

    if let name = killRandomLivingTraveler(gameState: gameState, forcedTraveler: forcedTraveler) {
        if gameState.livingTravelerIndices().isEmpty {
            gameState.pendingJourneyEnding = .gameOver
            return "The wagon runs out of control on the final descent. \(name) is killed. No one survives the journey."
        }

        gameState.pendingJourneyEnding = gameState.hasGrandfatherClock
            ? .clockSuccess
            : .completedWithWagon
        return "The wagon nearly overturns on the final descent. \(name) is killed, but the remaining travelers reach the valley with the wagon."
    }

    gameState.pendingJourneyEnding = .gameOver
    return "The final descent ends the journey."
}

func killRandomLivingTraveler(
    gameState: GameState,
    forcedTraveler: Int? = nil
) -> String? {
    let living = gameState.livingTravelerIndices()
    guard !living.isEmpty else { return nil }

    let traveler: Int
    if let forcedTraveler, living.contains(forcedTraveler) {
        traveler = forcedTraveler
    } else if let randomTraveler = living.randomElement() {
        traveler = randomTraveler
    } else {
        return nil
    }

    let name = gameState.travelerName(for: traveler)
    gameState.setTravelerAlive(traveler, false)

    if gameState.sickTraveler == traveler {
        gameState.sickTraveler = nil
    }

    return name
}

func tryEventSickness(
    gameState: GameState,
    forcedTraveler: Int? = nil
) -> String? {
    guard gameState.sickTraveler == nil else { return nil }

    let living = gameState.livingTravelerIndices()
    guard !living.isEmpty else { return nil }

    let traveler: Int
    if let forcedTraveler, living.contains(forcedTraveler) {
        traveler = forcedTraveler
    } else if let randomTraveler = living.randomElement() {
        traveler = randomTraveler
    } else {
        return nil
    }

    guard gameState.makeTravelerSick(traveler) else { return nil }
    return gameState.travelerName(for: traveler)
}

func loseRandomEligibleSupply(
    gameState: GameState,
    forcedCategory: SupplyLossCategory? = nil
) -> String {
    var available: [SupplyLossCategory] = []

    if gameState.medicalSupplies > 0 { available.append(.medical) }
    if gameState.ammunition > 0 { available.append(.ammo) }
    if gameState.blankets > 0 { available.append(.blankets) }
    if gameState.food > 0 { available.append(.food) }

    guard !available.isEmpty else {
        return "There is nothing useful left to lose."
    }

    let selected: SupplyLossCategory
    if let forcedCategory, available.contains(forcedCategory) {
        selected = forcedCategory
    } else if let randomCategory = available.randomElement() {
        selected = randomCategory
    } else {
        return "There is nothing useful left to lose."
    }

    switch selected {
    case .medical:
        gameState.medicalSupplies = max(0, gameState.medicalSupplies - 1)
        return "You lose 1 Medical Supply."

    case .ammo:
        gameState.ammunition = max(0, gameState.ammunition - 1)
        return "You lose 1 Ammo."

    case .blankets:
        gameState.blankets = max(0, gameState.blankets - 1)
        return "You lose the Warm Blankets."

    case .food:
        let lost = min(2, gameState.food)
        gameState.food -= lost
        return "You lose \(lost) Food."
    }
}
