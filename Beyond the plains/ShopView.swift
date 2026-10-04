import SwiftUI

struct ShopView: View {

    @EnvironmentObject var gameState: GameState

    var body: some View {

        GeometryReader { geometry in

            let isLandscape =
                geometry.size.width > geometry.size.height

            ZStack {

                // MARK: - Background

                Image(
                    isLandscape
                    ? "ShopBackgroundLandscape"
                    : "ShopBackgroundPortrait"
                )
                .resizable()
                .scaledToFill()
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                .clipped()




                // MARK: - Shop

                VStack(spacing: isLandscape ? 8 : 6) {

                    if isLandscape {

                        // MARK: Landscape

                        HStack {

                            Text("GENERAL STORE")
                                .font(
                                    .system(
                                        size: 26,
                                        weight: .bold,
                                        design: .serif
                                    )
                                )

                            Spacer()

                            Text("$\(gameState.money)")
                                .font(
                                    .system(
                                        size: 24,
                                        weight: .bold,
                                        design: .serif
                                    )
                                )
                        }

                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 20),
                                GridItem(.flexible(), spacing: 20),
                                
                            ],
                            spacing: 2
                        ) {

                            LandscapeShopRow(
                                name: "Food",
                                imageName: "Food",
                                price: gameState.foodPrice,
                                amount: gameState.food,
                                onMinus: {
                                    gameState.removeFood()
                                },
                                onPlus: {
                                    gameState.buyFood()
                                }
                            )

                            LandscapeShopRow(
                                name: "Rifle",
                                imageName: "Rifle",
                                price: gameState.riflePrice,
                                amount: gameState.hasRifle ? 1 : 0,
                                onMinus: {
                                    gameState.removeRifle()
                                },
                                onPlus: {
                                    gameState.buyRifle()
                                }
                            )

                            LandscapeShopRow(
                                name: "Ammo Pack",
                                imageName: "Ammo",
                                price: gameState.ammunitionPrice,
                                amount: gameState.ammunition,
                                onMinus: {
                                    gameState.removeAmmunition()
                                },
                                onPlus: {
                                    gameState.buyAmmunition()
                                }
                            )

                            LandscapeShopRow(
                                name: "Medical Supplies",
                                imageName: "MedicSupplies",
                                price: gameState.medicalSuppliesPrice,
                                amount: gameState.medicalSupplies,
                                onMinus: {
                                    gameState.removeMedicalSupplies()
                                },
                                onPlus: {
                                    gameState.buyMedicalSupplies()
                                }
                            )

                            LandscapeShopRow(
                                name: "Tools",
                                imageName: "Tools",
                                price: gameState.toolsPrice,
                                amount: gameState.tools,
                                onMinus: {
                                    gameState.removeTools()
                                },
                                onPlus: {
                                    gameState.buyTools()
                                }
                            )

                            LandscapeShopRow(
                                name: "Warm Blankets",
                                imageName: "Blanket",
                                price: gameState.blanketsPrice,
                                amount: gameState.blankets,
                                onMinus: {
                                    gameState.removeBlankets()
                                },
                                onPlus: {
                                    gameState.buyBlankets()
                                }
                            )

                            LandscapeShopRow(
                                name: "Rope",
                                imageName: "Rope",
                                price: gameState.ropePrice,
                                amount: gameState.rope,
                                onMinus: {
                                    gameState.removeRope()
                                },
                                onPlus: {
                                    gameState.buyRope()
                                }
                            )

                            LandscapeShopRow(
                                name: "Fiddle",
                                imageName: "Fiddle",
                                price: gameState.fiddlePrice,
                                amount: gameState.hasFiddle ? 1 : 0,
                                onMinus: {
                                    gameState.removeFiddle()
                                },
                                onPlus: {
                                    gameState.buyFiddle()
                                }
                            )

                            LandscapeShopRow(
                                name: "Grandfather Clock",
                                imageName: "GrandfatherClock",
                                price: gameState.grandfatherClockPrice,
                                amount: gameState.hasGrandfatherClock ? 1 : 0,
                                onMinus: {
                                    gameState.removeGrandfatherClock()
                                },
                                onPlus: {
                                    gameState.buyGrandfatherClock()
                                }
                            )
                        }

                    } else {

                        // MARK: Portrait
                        // Dette er samme portrait-layout som du hadde før.

                        Text("GENERAL STORE")
                            .font(
                                .system(
                                    size: 34,
                                    weight: .bold,
                                    design: .serif
                                )
                            )

                        Text("$\(gameState.money)")
                            .font(
                                .system(
                                    size: 26,
                                    weight: .bold,
                                    design: .serif
                                )
                            )

                        ScrollView {

                            VStack(spacing: 0) {

                                ShopRow(
                                    name: "Food",
                                    imageName: "Food",
                                    price: gameState.foodPrice,
                                    amount: gameState.food,
                                    onMinus: {
                                        gameState.removeFood()
                                    },
                                    onPlus: {
                                        gameState.buyFood()
                                    }
                                )

                                Divider()

                                ShopRow(
                                    name: "Rifle",
                                    imageName: "Rifle",
                                    price: gameState.riflePrice,
                                    amount: gameState.hasRifle ? 1 : 0,
                                    onMinus: {
                                        gameState.removeRifle()
                                    },
                                    onPlus: {
                                        gameState.buyRifle()
                                    }
                                )

                                Divider()

                                ShopRow(
                                    name: "Ammo Pack",
                                    imageName: "Ammo",
                                    price: gameState.ammunitionPrice,
                                    amount: gameState.ammunition,
                                    onMinus: {
                                        gameState.removeAmmunition()
                                    },
                                    onPlus: {
                                        gameState.buyAmmunition()
                                    }
                                )

                                Divider()

                                ShopRow(
                                    name: "Medical Supplies",
                                    imageName: "MedicSupplies",
                                    price: gameState.medicalSuppliesPrice,
                                    amount: gameState.medicalSupplies,
                                    onMinus: {
                                        gameState.removeMedicalSupplies()
                                    },
                                    onPlus: {
                                        gameState.buyMedicalSupplies()
                                    }
                                )

                                Divider()

                                ShopRow(
                                    name: "Tools",
                                    imageName: "Tools",
                                    price: gameState.toolsPrice,
                                    amount: gameState.tools,
                                    onMinus: {
                                        gameState.removeTools()
                                    },
                                    onPlus: {
                                        gameState.buyTools()
                                    }
                                )

                                Divider()

                                ShopRow(
                                    name: "Warm Blankets",
                                    imageName: "Blanket",
                                    price: gameState.blanketsPrice,
                                    amount: gameState.blankets,
                                    onMinus: {
                                        gameState.removeBlankets()
                                    },
                                    onPlus: {
                                        gameState.buyBlankets()
                                    }
                                )

                                Divider()

                                ShopRow(
                                    name: "Rope",
                                    imageName: "Rope",
                                    price: gameState.ropePrice,
                                    amount: gameState.rope,
                                    onMinus: {
                                        gameState.removeRope()
                                    },
                                    onPlus: {
                                        gameState.buyRope()
                                    }
                                )

                                Divider()

                                ShopRow(
                                    name: "Fiddle",
                                    imageName: "Fiddle",
                                    price: gameState.fiddlePrice,
                                    amount: gameState.hasFiddle ? 1 : 0,
                                    onMinus: {
                                        gameState.removeFiddle()
                                    },
                                    onPlus: {
                                        gameState.buyFiddle()
                                    }
                                )

                                Divider()

                                ShopRow(
                                    name: "Grandfather Clock",
                                    imageName: "GrandfatherClock",
                                    price: gameState.grandfatherClockPrice,
                                    amount: gameState.hasGrandfatherClock ? 1 : 0,
                                    onMinus: {
                                        gameState.removeGrandfatherClock()
                                    },
                                    onPlus: {
                                        gameState.buyGrandfatherClock()
                                    }
                                )
                            }
                        }
                    }

                    // ÉN Start Journey-knapp for begge layouts

                    Button {
                        gameState.phase = .journey
                    } label: {

                        Text("Start Journey")
                            .font(
                                .system(
                                    size: isLandscape ? 18 : 20,
                                    weight: .bold,
                                    design: .serif
                                )
                            )
                            .foregroundStyle(.white)
                            .padding(.horizontal, 34)
                            .padding(.vertical, isLandscape ? 9 : 13)
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
                .foregroundStyle(
                    Color(red: 0.20, green: 0.13, blue: 0.08)
                )
                .padding(isLandscape ? 14 : 20)
                .background(
                    Color(
                        red: 0.94,
                        green: 0.87,
                        blue: 0.72
                    )
                    .opacity(0.90)
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
                .padding(.horizontal, isLandscape ? 90 : 20)
                .padding(.vertical, isLandscape ? 10 : 60)
                
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
    }
}


#Preview {
    ShopView()
        .environmentObject(GameState())
}
