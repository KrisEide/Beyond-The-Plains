import Testing
@testable import Beyond_the_plains

struct MusicTrackSelectionTests {
    @Test func songOneIsSelectedThroughScenarioFive() {
        #expect(MusicTrack.track(for: .journey, day: 5) == .song1)
    }

    @Test func songTwoIsSelectedAtScenarioSix() {
        #expect(MusicTrack.track(for: .journey, day: 6) == .song2)
    }

    @Test func songTwoIsSelectedThroughScenarioTen() {
        #expect(MusicTrack.track(for: .journey, day: 10) == .song2)
    }

    @Test func songThreeIsSelectedAtScenarioEleven() {
        #expect(MusicTrack.track(for: .journey, day: 11) == .song3)
    }

    @Test func restartingSelectsSongOne() {
        #expect(MusicTrack.track(for: .start, day: 14) == .song1)
    }

    @Test func anInterruptedTransitionOnlyCompletesTheNewestRequest() {
        var state = MusicTransitionState(currentTrack: .song1)

        let firstRequest = state.requestTransition(to: .song2)
        let secondRequest = state.requestTransition(to: .song3)

        #expect(state.completeTransition(id: firstRequest.id) == nil)
        #expect(state.completeTransition(id: secondRequest.id) == .song3)
    }
}
