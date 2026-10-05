import SwiftUI

struct WinnerView: View {
    let ending: JourneyEnding
    let onPlayAgain: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height

            ZStack {
                Image(
                    isLandscape
                        ? "Winner3peopleLandscape"
                        : "Winner3peoplePortrait"
                )
                .resizable()
                .scaledToFill()
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                .clipped()

                LinearGradient(
                    colors: [
                        .clear,
                        Color.black.opacity(0.18),
                        Color.black.opacity(0.82)
                    ],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(spacing: 14) {
                    Spacer()

                    WinnerMessage(ending: ending)

                    Button("Play Again", action: onPlayAgain)
                        .frame(maxWidth: 340)
                        .choiceButtonStyle()
                }
                .padding(.horizontal, 24)
                .padding(
                    .bottom,
                    max(70, geometry.safeAreaInsets.bottom + 36)
                )
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
        }
        .ignoresSafeArea()
    }
}

private struct WinnerMessage: View {
    let ending: JourneyEnding

    var body: some View {
        VStack(spacing: 10) {
            Text(ending.title)
                .font(.system(size: 30, weight: .bold, design: .serif))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(ending.message)
                .font(.system(size: 15, weight: .medium, design: .serif))
                .lineSpacing(3)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.8), radius: 3, y: 2)
    }
}


#Preview {
    WinnerView(
        ending: .completedWithWagon,
        onPlayAgain: {}
    )
}
