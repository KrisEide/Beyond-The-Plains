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
                .padding(.bottom, max(24, geometry.safeAreaInsets.bottom))
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
                .font(.system(.largeTitle, design: .serif, weight: .bold))

            Text(ending.message)
                .font(.system(.body, design: .serif, weight: .medium))
                .lineSpacing(4)
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
