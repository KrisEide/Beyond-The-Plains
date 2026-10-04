import AVFoundation
import UIKit

enum MusicTrack: Equatable {
    case song1
    case song2
    case song3

    var assetName: String {
        switch self {
        case .song1:
            return "BeyondThePlainsSong1"
        case .song2:
            return "BeyondThePlainsSong2"
        case .song3:
            return "BeyondThePlainsSong3"
        }
    }

    static func track(for phase: GamePhase, day: Int) -> MusicTrack {
        switch phase {
        case .start, .partySetup, .shop:
            return .song1
        case .journey:
            if day <= 5 {
                return .song1
            } else if day <= 10 {
                return .song2
            } else {
                return .song3
            }
        case .result:
            return .song3
        }
    }
}

struct MusicTransitionRequest: Equatable {
    let id: Int
    let track: MusicTrack
}

struct MusicTransitionState {
    private(set) var currentTrack: MusicTrack?
    private(set) var pendingTrack: MusicTrack?
    private var transitionID = 0

    init(currentTrack: MusicTrack? = nil) {
        self.currentTrack = currentTrack
    }

    mutating func requestTransition(to track: MusicTrack) -> MusicTransitionRequest {
        transitionID += 1
        pendingTrack = track
        return MusicTransitionRequest(id: transitionID, track: track)
    }

    mutating func completeTransition(id: Int) -> MusicTrack? {
        guard id == transitionID, let pendingTrack else {
            return nil
        }

        currentTrack = pendingTrack
        self.pendingTrack = nil
        return pendingTrack
    }

    mutating func setCurrentTrack(_ track: MusicTrack) {
        transitionID += 1
        currentTrack = track
        pendingTrack = nil
    }

    mutating func cancelPendingTransition() {
        transitionID += 1
        pendingTrack = nil
    }
}

@MainActor
final class MusicPlayer {
    private let fadeDuration: TimeInterval = 3
    private var player: AVAudioPlayer?
    private var transitionTask: Task<Void, Never>?
    private var transitionState = MusicTransitionState()
    private var requestedTrack: MusicTrack = .song1
    private var isAppActive = true

    init() {
        configureAudioSession()
    }

    func update(phase: GamePhase, day: Int) {
        requestedTrack = MusicTrack.track(for: phase, day: day)

        guard isAppActive else {
            return
        }

        transition(to: requestedTrack)
    }

    func pause() {
        isAppActive = false
        cancelTransitionTask()
        player?.pause()
    }

    func resume(phase: GamePhase, day: Int) {
        isAppActive = true
        requestedTrack = MusicTrack.track(for: phase, day: day)
        transition(to: requestedTrack)
    }

    private func transition(to track: MusicTrack) {
        cancelTransitionTask()

        if transitionState.currentTrack == track {
            transitionState.cancelPendingTransition()
            player?.play()
            player?.setVolume(1, fadeDuration: fadeDuration)
            return
        }

        guard let player else {
            start(track, fadingIn: false)
            return
        }

        let request = transitionState.requestTransition(to: track)
        player.setVolume(0, fadeDuration: fadeDuration)

        transitionTask = Task { @MainActor [weak self] in
            do {
                try await Task.sleep(for: .seconds(3))
            } catch {
                return
            }

            guard let self,
                  self.isAppActive,
                  let nextTrack = self.transitionState.completeTransition(id: request.id) else {
                return
            }

            self.player?.stop()
            self.start(nextTrack, fadingIn: true)
        }
    }

    private func start(_ track: MusicTrack, fadingIn: Bool) {
        guard let audioPlayer = makePlayer(for: track) else {
            return
        }

        audioPlayer.numberOfLoops = -1
        audioPlayer.volume = fadingIn ? 0 : 1
        audioPlayer.prepareToPlay()
        audioPlayer.play()

        player = audioPlayer
        transitionState.setCurrentTrack(track)

        if fadingIn {
            audioPlayer.setVolume(1, fadeDuration: fadeDuration)
        }
    }

    private func makePlayer(for track: MusicTrack) -> AVAudioPlayer? {
        if let asset = NSDataAsset(name: track.assetName) {
            return try? AVAudioPlayer(data: asset.data)
        }

        let supportedExtensions = ["mp3", "m4a", "wav", "aiff", "caf"]

        for fileExtension in supportedExtensions {
            if let url = Bundle.main.url(
                forResource: track.assetName,
                withExtension: fileExtension
            ) {
                return try? AVAudioPlayer(contentsOf: url)
            }
        }

        assertionFailure("Missing audio asset: \(track.assetName)")
        return nil
    }

    private func cancelTransitionTask() {
        transitionTask?.cancel()
        transitionTask = nil

        if let player {
            player.setVolume(player.volume, fadeDuration: 0)
        }
    }

    private func configureAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
    }

    deinit {
        transitionTask?.cancel()
    }
}
