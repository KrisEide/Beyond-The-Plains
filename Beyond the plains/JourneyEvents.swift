import SwiftUI

enum JourneyItemRequirement {
    case tools
    case rope
    case blankets
    case fiddle
    case rifleAndAmmo
    
    
}

enum JourneyChoiceRequirement {
    case none
    case food(Int)
    case money(Int)
    case medicalSupplies(Int)
    case item(JourneyItemRequirement)
    case rifleAndAmmo(Int)
    case foodAndAmmo(food: Int, ammo: Int)
}

struct JourneyChoice {
    let number: Int
    let text: String
    let requirement: JourneyChoiceRequirement
    var extraWeeks: Int = 0
}

struct JourneyEvent {
    let title: String
    let description: String
    let choices: [JourneyChoice]
}

func journeyEvent(
    for day: Int,
    gameState: GameState
) -> JourneyEvent {
    if let laterEvent = journeyEventDays6to14(
        for: day,
        gameState: gameState
    ) {
        return laterEvent
    }
    switch day {

    case 1:
        return JourneyEvent(
            title: "THE ROAD AHEAD",
            description: "The trail splits ahead. A local guide offers to lead you around a damaged stretch of road for a price. You could also take a longer, safer route or try an old road that may be quicker.",
            choices: [
                JourneyChoice(
                    number: 1,
                    text: "Hire the guide — $60",
                    requirement: .money(60)
                ),

                JourneyChoice(
                    number: 2,
                    text: "Take the long way",
                    requirement: .none,
                    extraWeeks: 1
                ),

                JourneyChoice(
                    number: 3,
                    text: "Take the old road",
                    requirement: .none
                )
            ]
        )
        
    case 2:
        return JourneyEvent(
            title: "BROKEN AXLE",
            description: "The wagon drops hard into a deep rut. One of the axle supports cracks under the weight. It may hold for now, but the road ahead will only get rougher.",
            choices: [
                JourneyChoice(
                    number: 1,
                    text: "Repair it properly — Tools",
                    requirement: .item(.tools)
                ),
                JourneyChoice(
                    number: 2,
                    text: "Bind it together — Rope",
                    requirement: .item(.rope)
                ),
                JourneyChoice(
                    number: 3,
                    text: "Wait for help",
                    requirement: .none,
                    extraWeeks: 1
                ),
                JourneyChoice(
                    number: 4,
                    text: "Keep moving",
                    requirement: .none
                )
            ]
        )
        
    case 3:
        return JourneyEvent(
            title: "THE FERRY",
            description: "A wide river blocks the trail ahead. An old ferry can carry the wagon across, but the ferryman wants payment. Farther upstream, the water looks shallow enough to attempt a crossing.",
            choices: [
                JourneyChoice(
                    number: 1,
                    text: "Pay for passage — $70",
                    requirement: .money(70)
                ),
                JourneyChoice(
                    number: 2,
                    text: "Give him the Rope",
                    requirement: .item(.rope)
                ),
                JourneyChoice(
                    number: 3,
                    text: "Work for passage",
                    requirement: .none,
                    extraWeeks: 1
                ),
                JourneyChoice(
                    number: 4,
                    text: "Cross at the shallow water",
                    requirement: .none
                )
            ]
        )
        
    case 4:
        return JourneyEvent(
            title: "THE WOUNDED STRANGER",
            description: "You find a badly wounded man beside the trail. He says he was thrown from his horse and cannot travel alone. There is no horse in sight.",
            choices: [
                JourneyChoice(
                    number: 1,
                    text: "Treat his wounds",
                    requirement: .medicalSupplies(1)
                ),
                JourneyChoice(
                    number: 2,
                    text: "Take him with you",
                    requirement: .none
                ),
                JourneyChoice(
                    number: 3,
                    text: "Leave him behind",
                    requirement: .none
                ),
                JourneyChoice(
                    number: 4,
                    text: "Give him Warm Blankets",
                    requirement: .item(.blankets)
                )
            ]
        )
        // neste
        
    case 5:
        if gameState.strangerTravelingWithYou {

            return JourneyEvent(
                title: "RIDERS ON THE TRAIL",
                description: "Armed riders close in. The stranger admits he is a wanted outlaw. They offer $150 for him.",
                choices: [
                    JourneyChoice(
                        number: 1,
                        text: "Turn Him Over",
                        requirement: .none
                    ),
                    JourneyChoice(
                        number: 2,
                        text: "Tell Him to Leave",
                        requirement: .none
                    ),
                    JourneyChoice(
                        number: 3,
                        text: "Help Him Disappear",
                        requirement: .none,
                        extraWeeks: 2
                    ),
                    JourneyChoice(
                        number: 4,
                        text: "Stand With Him",
                        requirement: .rifleAndAmmo(2)
                    )
                ]
            )

        } else {

            return JourneyEvent(
                title: "BROKEN STAGECOACH",
                description: "A damaged stagecoach sits beside the trail. Its driver cannot continue, and cargo lies scattered around the wreck.",
                choices: [
                    JourneyChoice(
                        number: 1,
                        text: "Help Repair It — Tools",
                        requirement: .item(.tools)
                    ),
                    JourneyChoice(
                        number: 2,
                        text: "Carry Their Mail West",
                        requirement: .none
                    ),
                    JourneyChoice(
                        number: 3,
                        text: "Help Recover the Cargo",
                        requirement: .none,
                        extraWeeks: 1
                    ),
                    JourneyChoice(
                        number: 4,
                        text: "Move On",
                        requirement: .none
                    )
                ]
            )
        }

    default:
        return JourneyEvent(
            title: "",
            description: "",
            choices: []
        )
    }
}

func isJourneyChoiceAvailable(
    _ choice: JourneyChoice,
    gameState: GameState
) -> Bool {

    switch choice.requirement {

    case .none:
        return true

    case .food(let amount):
        return gameState.food >= amount

    case .money(let amount):
        return gameState.money >= amount

    case .medicalSupplies(let amount):
        return gameState.medicalSupplies >= amount

    case .item(let item):
        switch item {

        case .tools:
            return gameState.tools > 0

        case .rope:
            return gameState.rope > 0

        case .blankets:
            return gameState.blankets > 0

        case .fiddle:
            return gameState.hasFiddle

        case .rifleAndAmmo:
            return gameState.hasRifle &&
                gameState.ammunition > 0
        }

    case .rifleAndAmmo(let amount):
        return gameState.hasRifle &&
            gameState.ammunition >= amount

    case .foodAndAmmo(let food, let ammo):
        return gameState.food >= food &&
            gameState.ammunition >= ammo
    }
}

func resolveJourneyChoice(
    day: Int,
    choice: Int,
    gameState: GameState
) -> String {
    
    if let laterResult = resolveJourneyChoiceDays6to14(
        day: day,
        choice: choice,
        gameState: gameState
    ) {
        return laterResult
    }

    switch day {

    case 1:
        switch choice {

        case 1:
            gameState.money -= 60

            return """
            The guide leads your wagon along a narrow route around the damaged trail.

            You lose $60, but reach the other side without trouble.
            """

        case 2:
            

            return """
            You turn the wagon around and take the longer route.

            The detour adds another week to your journey.
            """

        case 3:
            let foodLost = Int.random(in: 0...3)

            let actualFoodLost = min(
                foodLost,
                gameState.food
            )

            gameState.food -= actualFoodLost

            if actualFoodLost == 0 {

                return """
                The old road is rough, but the wagon makes it through without losing anything.

                You lose 0 Food.
                """

            } else if actualFoodLost == 1 {

                return """
                The wagon hits several deep ruts along the old road. Some provisions are damaged along the way.

                You lose 1 Food.
                """

            } else {

                return """
                The old road is worse than expected. The wagon is thrown around badly and some of your provisions are lost.

                You lose \(actualFoodLost) Food.
                """
            }
            
            

        default:
            return ""
        }
        
    case 2:
        switch choice {

        case 1:
            gameState.tools = max(0, gameState.tools - 1)
            gameState.weakAxle = false
            gameState.damagedAxle = false

            return """
            You use the Tools to repair the broken axle properly.

            The repair holds firm, but the Tools are worn out and can no longer be used.
            """

        case 2:
            gameState.rope = max(0, gameState.rope - 1)
            gameState.weakAxle = true
            gameState.damagedAxle = false

            return """
            You bind the damaged axle tightly with Rope.

            It should hold for now, but the repair is only temporary.

            The Rope is used up.
            """

        case 3:
            gameState.weakAxle = false
            gameState.damagedAxle = false

            return """
            You make camp beside the road and wait.

            A week later, another wagon party comes along and helps you make a proper repair.
            """

        case 4:
            gameState.weakAxle = false
            gameState.damagedAxle = true

            return """
            You decide not to stop.

            The axle creaks badly as the wagon starts moving again, but for now it still holds.
            """

        default:
            return ""
        }
        
    case 3:
        switch choice {

        case 1:
            gameState.money -= 70

            return """
            You pay the ferryman $70.

            The wagon is carried safely across the river.
            """

        case 2:
            gameState.rope = max(0, gameState.rope - 1)

            return """
            The ferryman uses your Rope to reinforce the worn ferry cable.

            In return, he takes your wagon across without charge.

            The Rope is used up.
            """

        case 3:
            return """
            You spend several days helping at the ferry landing.

            A week passes before the ferryman finally takes your wagon across.
            """

        case 4:
            let roll = Int.random(in: 1...100)

            // DAMAGED AXLE
            if gameState.damagedAxle {

                // 30%: Safe
                if roll <= 30 {
                    return """
                    The current pulls hard against the wagon, but the oxen manage to keep their footing.

                    You reach the opposite bank safely.
                    """
                }

                // 50%: Bad
                else if roll <= 80 {
                    let foodLost = min(2, gameState.food)
                    let ammoLost = min(1, gameState.ammunition)

                    gameState.food -= foodLost
                    gameState.ammunition -= ammoLost

                    var majorItemText = ""

                    if gameState.blankets > 0 {
                        gameState.blankets -= 1
                        majorItemText = "\nYou lose your Warm Blankets."
                    } else if gameState.tools > 0 {
                        gameState.tools -= 1
                        majorItemText = "\nYou lose your Tools."
                    } else if gameState.medicalSupplies > 0 {
                        gameState.medicalSupplies -= 1
                        majorItemText = "\nYou lose 1 Medical Supply."
                    }

                    var result = """
                    The damaged axle twists violently when the wagon hits a hidden rock.

                    Part of your cargo is swept into the river.
                    """

                    if foodLost > 0 {
                        result += "\n\nYou lose \(foodLost) Food."
                    }

                    if ammoLost > 0 {
                        result += "\nYou lose \(ammoLost) Ammo."
                    }

                    result += majorItemText

                    return result
                }

                // 20%: CATASTROPHE
                else {
                    let foodLost = min(3, gameState.food)
                    let ammoLost = min(2, gameState.ammunition)

                    gameState.food -= foodLost
                    gameState.ammunition -= ammoLost

                    var majorItemText = ""

                    if gameState.blankets > 0 {
                        gameState.blankets -= 1
                        majorItemText = "\nYou lose your Warm Blankets."
                    } else if gameState.tools > 0 {
                        gameState.tools -= 1
                        majorItemText = "\nYou lose your Tools."
                    } else if gameState.medicalSupplies > 0 {
                        gameState.medicalSupplies -= 1
                        majorItemText = "\nYou lose 1 Medical Supply."
                    }

                    var result = """
                    Disaster strikes.

                    The damaged axle gives way in the middle of the crossing. The wagon lurches sideways and several supplies are torn loose and carried downstream.
                    """

                    if foodLost > 0 {
                        result += "\n\nYou lose \(foodLost) Food."
                    }

                    if ammoLost > 0 {
                        result += "\nYou lose \(ammoLost) Ammo."
                    }

                    result += majorItemText

                    return result
                }
            }

            // WEAK AXLE
            else if gameState.weakAxle {

                // 50%: Safe
                if roll <= 50 {
                    return """
                    The temporary axle repair creaks as the wagon crosses, but it holds.

                    You reach the opposite bank safely.
                    """
                }

                // 35%: Food + Ammo
                else if roll <= 85 {
                    let foodLost = min(2, gameState.food)
                    let ammoLost = min(1, gameState.ammunition)

                    gameState.food -= foodLost
                    gameState.ammunition -= ammoLost

                    var result = """
                    The wagon hits a rock beneath the water and tilts sharply.

                    Some supplies fall into the river.
                    """

                    if foodLost > 0 {
                        result += "\n\nYou lose \(foodLost) Food."
                    }

                    if ammoLost > 0 {
                        result += "\nYou lose \(ammoLost) Ammo."
                    }

                    return result
                }

                // 15%: Food + Ammo + major item
                else {
                    let foodLost = min(2, gameState.food)
                    let ammoLost = min(1, gameState.ammunition)

                    gameState.food -= foodLost
                    gameState.ammunition -= ammoLost

                    var majorItemText = ""

                    if gameState.blankets > 0 {
                        gameState.blankets -= 1
                        majorItemText = "\nYou lose your Warm Blankets."
                    } else if gameState.tools > 0 {
                        gameState.tools -= 1
                        majorItemText = "\nYou lose your Tools."
                    } else if gameState.medicalSupplies > 0 {
                        gameState.medicalSupplies -= 1
                        majorItemText = "\nYou lose 1 Medical Supply."
                    }

                    var result = """
                    The temporary axle repair slips badly during the crossing.

                    The wagon nearly tips and part of your cargo is swept away.
                    """

                    if foodLost > 0 {
                        result += "\n\nYou lose \(foodLost) Food."
                    }

                    if ammoLost > 0 {
                        result += "\nYou lose \(ammoLost) Ammo."
                    }

                    result += majorItemText

                    return result
                }
            }

            // PROPERLY REPAIRED AXLE
            else {

                // 50%: Safe
                if roll <= 50 {
                    return """
                    The crossing is difficult, but the repaired wagon holds together.

                    You reach the opposite bank safely.
                    """
                }

                // 30%: Lose 1 Food
                else if roll <= 80 {
                    let foodLost = min(1, gameState.food)
                    gameState.food -= foodLost

                    var result = """
                    The wagon jolts against a submerged rock.

                    A small bundle of provisions falls into the river.
                    """

                    if foodLost > 0 {
                        result += "\n\nYou lose \(foodLost) Food."
                    }

                    return result
                }

                // 20%: Lose 2 Food + up to 1 Ammo
                else {
                    let foodLost = min(2, gameState.food)
                    let ammoLost = min(1, gameState.ammunition)

                    gameState.food -= foodLost
                    gameState.ammunition -= ammoLost

                    var result = """
                    The current catches the wagon harder than expected.

                    Several supplies are washed away before you reach the bank.
                    """

                    if foodLost > 0 {
                        result += "\n\nYou lose \(foodLost) Food."
                    }

                    if ammoLost > 0 {
                        result += "\nYou lose \(ammoLost) Ammo."
                    }

                    return result
                }
            }

        default:
            return ""
        }
        
    case 4:
        switch choice {

        case 1:
            gameState.medicalSupplies -= 1
            gameState.helpedWoundedStranger = true

            return """
            You clean and dress the stranger's wounds.

            After some rest, he is strong enough to continue on his own.

            You use 1 Medical Supply.
            """

        case 2:
            gameState.strangerTravelingWithYou = true

            return """
            You make room for the wounded stranger in the wagon.

            He thanks you and joins your group for the road ahead.
            """

        case 3:
            return """
            You cannot risk the safety and supplies of your own group for a stranger.

            You leave him behind and continue west.
            """

        case 4:
            gameState.blankets = max(0, gameState.blankets - 1)
            gameState.helpedWoundedStranger = true

            return """
            You leave the stranger your Warm Blankets so he can survive the cold night.

            He promises that he will not forget your kindness.

            You use 1 Warm Blanket.
            """

        default:
            return ""
        }
        //neste
    case 5:
        if gameState.strangerTravelingWithYou {

            switch choice {
        case 1:
            gameState.money += 150
            gameState.strangerTravelingWithYou = false

            return """
            You wait for the riders and turn the outlaw over.

            They pay the promised reward.

            You gain $150.
            """

        case 2:
            gameState.strangerTravelingWithYou = false

            return "You tell the outlaw to leave before the riders arrive. He slips away from the trail, taking his trouble with him."

        case 3:
            gameState.strangerTravelingWithYou = false
            gameState.helpedOutlawEscape = true

            return """
            You leave the main trail and take a long route through rough country.

            Two weeks pass before the riders finally lose the trail.

            The outlaw thanks you and goes his own way.
            """

        case 4:
            guard gameState.hasRifle &&
                  gameState.ammunition >= 2 else {
                return "You do not have enough ammunition."
            }

            gameState.ammunition -= 2
            gameState.strangerTravelingWithYou = false

            let roll = Int.random(in: 1...100)

            // 40% — Group wins, everyone survives
            if roll <= 40 {
                gameState.helpedOutlawWinShootout = true

                return """
                Gunfire erupts along the trail.

                After a violent exchange, the remaining riders retreat.

                Everyone in your group survives.

                You use 2 Ammo.

                The outlaw thanks you before heading off on his own.
                """
            }

            // 25% — One traveler dies
            else if roll <= 65 {
                if let traveler =
                    gameState.livingTravelerIndices().randomElement() {

                    let name = gameState.travelerName(for: traveler)

                    gameState.setTravelerAlive(
                        traveler,
                        false
                    )

                    if gameState.sickTraveler == traveler {
                        gameState.sickTraveler = nil
                    }

                    gameState.helpedOutlawWinShootout = true

                    return """
                    The fight turns deadly.

                    \(name) is struck by a bullet and killed.

                    The surviving riders eventually retreat.

                    You use 2 Ammo.

                    The outlaw survives and leaves the group after the fighting ends.
                    """
                }

                return ""
            }

            // 20% — Outlaw dies
            else if roll <= 85 {
                return """
                The shootout breaks out before anyone can back down.

                The outlaw is hit during the fighting and dies from his wounds.

                Your travelers survive.

                You use 2 Ammo.
                """
            }

            // 15% — Complete victory + loot
            else {
                gameState.helpedOutlawWinShootout = true
                gameState.ammunition += 3

                gameState.tools += 1

                return """
                The shootout ends decisively.

                None of the pursuing riders remain to continue the chase.

                Your group survives.

                You use 2 Ammo, then recover 3 Ammo and a set of Tools from their gear.

                The outlaw thanks you and goes his own way.
                """
            }

            default:
                return ""
            }

        } else {

            switch choice {

            case 1:
                gameState.tools = max(0, gameState.tools - 1)
                gameState.money += 100

                return """
                You use your Tools to help repair the damaged stagecoach.

                The grateful driver pays you $100.

                Your Tools are used up.
                """

            case 2:
                gameState.carryingMail = true

                return """
                The driver gives you a sealed mail bag that must continue west.

                You agree to carry it with you.

                There is no payment yet.
                """

            case 3:
                let roll = Int.random(in: 1...100)

                if roll <= 50 {
                    gameState.money += 40

                    return """
                    You spend a week helping the driver recover cargo from the scattered wreckage.

                    In thanks, the driver lets you keep $40 found among the debris.
                    """

                } else if roll <= 80 {
                    gameState.ammunition += 1

                    return """
                    You spend a week helping the driver recover cargo from the scattered wreckage.

                    In thanks, the driver gives you an unopened pack of ammunition.

                    You gain 1 Ammo.
                    """

                } else {
                    gameState.medicalSupplies += 1

                    return """
                    You spend a week helping the driver recover cargo from the scattered wreckage.

                    In thanks, the driver gives you usable medicine from the cargo.

                    You gain 1 Medical Supply.
                    """
                }

            case 4:
                return """
                You decide not to get involved.

                You leave the damaged stagecoach behind and continue west.
                """

            default:
                return ""
            }
        }

        // Neste

    default:
        return ""
    }
}
