import SwiftUI

struct ShopRow: View {
    
    let name: String
    let price: Int
    let amount: Int
    let imageName: String
    
    let onMinus: () -> Void
    let onPlus: () -> Void
    
    init(
        name: String,
        imageName: String,
        price: Int,
        amount: Int,
        onMinus: @escaping () -> Void = {},
        onPlus: @escaping () -> Void = {}
    ) {
        self.name = name
        self.imageName = imageName
        self.price = price
        self.amount = amount
        self.onMinus = onMinus
        self.onPlus = onPlus
    }
    
    var body: some View {
        
        HStack(spacing: 12) {

            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 1) {

                Text(name)
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .lineLimit(1)
                    .minimumScaleFactor(0.60)
                    .allowsTightening(true)

                Text("$\(price)")
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .foregroundStyle(.brown)
            }
            .layoutPriority(1)
            
                    Spacer()

                    Button {
                        onMinus()
                    } label: {
                        Text("−")
                            .font(.title2.bold())
                            .frame(width: 38, height: 38)
                    }

                    Text("\(amount)")
                        .font(.headline)
                        .frame(width: 30)

                    Button {
                       onPlus()
                    } label: {
                        Text("+")
                            .font(.title2.bold())
                            .frame(width: 38, height: 38)
                    }
                }
                .foregroundStyle(
                    Color(red: 0.20, green: 0.13, blue: 0.08)
                )
                .padding(.vertical, 8)
        
            }
        }
