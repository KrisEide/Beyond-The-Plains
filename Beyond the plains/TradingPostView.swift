import SwiftUI

struct TradingPostView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss

    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color(red: 0.33, green: 0.22, blue: 0.13)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    Text("TRADING POST")
                        .font(.system(size: 32, weight: .bold, design: .serif))

                    Text("Supplies are expensive this far west.")
                        .font(.system(size: 16, design: .serif))

                    Text("$\(gameState.money)")
                        .font(.system(size: 27, weight: .bold, design: .serif))
                        .padding(.bottom, 4)

                    Divider()

                    shopRow(
                        name: "Food",
                        imageName: "Food",
                        price: 35
                    ) {
                        guard gameState.money >= 35 else { return }
                        gameState.money -= 35
                        gameState.food += 1
                    }

                    shopRow(
                        name: "Ammo Pack",
                        imageName: "Ammo",
                        price: 30
                    ) {
                        guard gameState.money >= 30 else { return }
                        gameState.money -= 30
                        gameState.ammunition += 1
                    }

                    shopRow(
                        name: "Medical Supplies",
                        imageName: "MedicSupplies",
                        price: 130
                    ) {
                        guard gameState.money >= 130 else { return }
                        gameState.money -= 130
                        gameState.medicalSupplies += 1
                    }

                    shopRow(
                        name: "Tools",
                        imageName: "Tools",
                        price: 140
                    ) {
                        guard gameState.money >= 140 else { return }
                        gameState.money -= 140
                        gameState.tools += 1
                    }

                    shopRow(
                        name: "Warm Blankets",
                        imageName: "Blanket",
                        price: 110
                    ) {
                        guard gameState.money >= 110 else { return }
                        gameState.money -= 110
                        gameState.blankets += 1
                    }

                    shopRow(
                        name: "Rope",
                        imageName: "Rope",
                        price: 85
                    ) {
                        guard gameState.money >= 85 else { return }
                        gameState.money -= 85
                        gameState.rope += 1
                    }

                    Divider()
                        .padding(.vertical, 4)

                    Button {
                        dismiss()
                        onContinue()
                    } label: {
                        Text("Continue Journey")
                            .font(.system(size: 18, weight: .bold, design: .serif))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(
                                Color(red: 0.18, green: 0.30, blue: 0.17)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 5)
                }
                .foregroundStyle(Color(red: 0.20, green: 0.13, blue: 0.08))
                .padding(22)
                .background(
                    Color(red: 0.94, green: 0.87, blue: 0.72)
                        .opacity(0.98)
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
                .padding(.vertical, 28)
            }
        }
        .interactiveDismissDisabled()
    }

    @ViewBuilder
    private func shopRow(
        name: String,
        imageName: String,
        price: Int,
        owned: Bool = false,
        singleItem: Bool = false,
        onBuy: @escaping () -> Void
    ) -> some View {
        let canBuy =
            gameState.money >= price &&
            (!singleItem || !owned)

        HStack(spacing: 12) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(.system(size: 17, weight: .bold, design: .serif))

                if singleItem && owned {
                    Text("Owned")
                        .font(.system(size: 14, design: .serif))
                } else {
                    Text("$\(price)")
                        .font(.system(size: 14, design: .serif))
                }
            }

            Spacer()

            Button("Buy") {
                onBuy()
            }
            .font(.system(size: 16, weight: .bold, design: .serif))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 9)
            .background(
                Color(red: 0.18, green: 0.30, blue: 0.17)
            )
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .disabled(!canBuy)
            .opacity(canBuy ? 1 : 0.40)
        }
        .padding(.vertical, 4)
    }
}

