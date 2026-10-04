import SwiftUI

struct LandscapeShopRow: View {

    let name: String
    let imageName: String
    let price: Int
    let amount: Int

    let onMinus: () -> Void
    let onPlus: () -> Void

    var body: some View {

        HStack(spacing: 8) {

            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: 0) {

                Text(name)
                    .font(.system(
                        size: 14,
                        weight: .bold,
                        design: .serif
                    ))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text("$\(price)")
                    .font(.system(
                        size: 12,
                        weight: .medium,
                        design: .serif
                    ))
                    .foregroundStyle(.brown)
            }

            Spacer()

            Button {
                onMinus()
            } label: {
                Text("−")
                    .font(.headline.bold())
                    .frame(width: 28, height: 28)
            }

            Text("\(amount)")
                .font(.system(size: 15, weight: .bold))
                .frame(width: 22)

            Button {
                onPlus()
            } label: {
                Text("+")
                    .font(.headline.bold())
                    .frame(width: 28, height: 28)
            }
        }
        .foregroundStyle(
            Color(red: 0.20, green: 0.13, blue: 0.08)
        )
        .padding(.vertical, 2)
    }
}
