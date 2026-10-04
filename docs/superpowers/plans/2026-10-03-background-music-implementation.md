# Background Music Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a three-section looping music system that works safely before the final audio files are added.

**Architecture:** A pure track selector maps `GamePhase` and journey day to a logical track. One app-lifetime, main-actor `MusicPlayer` coordinates an injected playback backend; the production backend wraps `AVAudioPlayer`, while tests use a fake. `MyApp` forwards track and scene-phase changes.

**Tech Stack:** Swift, SwiftUI, AVFoundation, Swift Concurrency, Swift Testing

**Spec:** `docs/superpowers/specs/2026-10-03-background-music-design.md`

## Global Constraints

- Track 1 covers start, party setup, shop, and journey days 1–5.
- Track 2 covers journey days 6–10.
- Track 3 covers journey days 11–14 and the ending.
- Each track loops indefinitely.
- Track changes use 3 seconds fade-out followed by 3 seconds fade-in, with no overlap.
- Backgrounding pauses and activation resumes from the same position.
- Missing audio resources remain silent and never crash the app.
- Do not add mute or volume UI.
- Do not create Git commits unless the user explicitly asks.

## Review Focus

- Journey days outside 1–14 must resolve deterministically without crashing; selector tests cover day 0 and day 15.
- Repeated requests for the active track must not restart playback; coordinator tests verify no extra backend calls.
- A newer request during a fade must supersede the older request; cancellation tests verify only the latest track starts.
- Resume must not start audio when no valid track was loaded; lifecycle tests cover the missing-resource state.
- An absent resource must not block a later valid track; loader/coordinator tests cover recovery.

---

### Task 1: Track Selection and Test Target

**Files:**
- Create target: `Beyond the plainsTests`
- Create: `Beyond the plains/MusicTrack.swift`
- Create: `Beyond the plainsTests/MusicTrackTests.swift`

**Interfaces:**
- Produces: `enum MusicTrack: String, Equatable, Sendable { case part1 = "MusicPart1"; case part2 = "MusicPart2"; case part3 = "MusicPart3" }`
- Produces: `static func desiredTrack(phase: GamePhase, currentDay: Int) -> MusicTrack`

- [ ] **Step 1: Create a Swift Testing unit-test target named `Beyond the plainsTests` hosted by the app target.**

- [ ] **Step 2: Write failing selector tests.**

Add `@Test` cases asserting Track 1 for `.start`, `.partySetup`, `.shop`, and journey days 1 and 5; Track 2 for days 6 and 10; Track 3 for days 11 and 14 plus `.result`; and deterministic clamping behavior for days 0 and 15.

- [ ] **Step 3: Run `MusicTrackTests` and verify RED.**

Expected: compilation/test failure because `MusicTrack` and `desiredTrack` do not exist.

- [ ] **Step 4: Implement `MusicTrack` and `desiredTrack(phase:currentDay:)`.**

Use phase first; only `.journey` consults `currentDay`. Clamp journey mapping so values below 6 select Track 1, values 6–10 select Track 2, and values above 10 select Track 3.

- [ ] **Step 5: Run `MusicTrackTests` and verify GREEN.**

Expected: every selector test passes.

### Task 2: Testable Playback Coordinator

**Files:**
- Create: `Beyond the plains/MusicPlaybackBackend.swift`
- Create: `Beyond the plains/MusicPlayer.swift`
- Create: `Beyond the plainsTests/MusicPlayerTests.swift`

**Interfaces:**
- Consumes: `MusicTrack`
- Produces: `@MainActor protocol MusicPlaybackBackend` with `currentTrack`, `load(_:) -> Bool`, `playLooping(volume:)`, `setVolume(_:duration:) async`, `stop()`, `pause()`, and `resume()`.
- Produces: `@MainActor final class MusicPlayer` with `init(backend: any MusicPlaybackBackend, fadeDuration: Duration = .seconds(3))`, `func transition(to:) async`, `func pause()`, and `func resume()`.

- [ ] **Step 1: Write a fake backend and failing coordinator tests.**

Test initial loading at zero volume followed by looping and fade-in; 3-second default duration; no-op for a repeated active-track request; fade-out before load/start of a different track; latest-request-wins cancellation; failed load remaining silent; later successful request recovering; pause/resume forwarding only when a track is loaded.

- [ ] **Step 2: Run `MusicPlayerTests` and verify RED.**

Expected: compilation/test failure because the backend protocol and coordinator do not exist.

- [ ] **Step 3: Implement the minimal backend protocol and `MusicPlayer`.**

Keep all playback state main-actor isolated. Use structured cancellation checks between fade-out, stop/load, play, and fade-in so a superseded transition cannot start an obsolete track.

- [ ] **Step 4: Run `MusicPlayerTests` and verify GREEN.**

Expected: all coordinator tests pass with no audio files present.

### Task 3: AVAudioPlayer Production Backend

**Files:**
- Create: `Beyond the plains/AVAudioPlayerBackend.swift`
- Create: `Beyond the plainsTests/AVAudioPlayerBackendTests.swift`

**Interfaces:**
- Consumes: `MusicPlaybackBackend`, `MusicTrack`
- Produces: `@MainActor final class AVAudioPlayerBackend: MusicPlaybackBackend`
- Produces: `init(bundle: Bundle = .main, resourceExtensions: [String] = ["m4a", "mp3", "wav", "aiff", "caf"])`

- [ ] **Step 1: Write failing resource-resolution tests using a test bundle fixture or injected URL resolver.**

Assert extension search order, missing-resource `false`, failed decode `false`, no retained stale player after failure, and recovery on a later valid URL.

- [ ] **Step 2: Run backend tests and verify RED.**

Expected: compilation/test failure because `AVAudioPlayerBackend` does not exist.

- [ ] **Step 3: Implement the AVFoundation backend.**

Configure `AVAudioSession` for ambient background music that does not request background execution. Set `numberOfLoops = -1`, use `setVolume(_:fadeDuration:)`, preserve `currentTime` through pause/resume, and log missing/invalid resources without trapping.

- [ ] **Step 4: Run backend tests and verify GREEN.**

Expected: all resource and recovery tests pass without the final songs.

### Task 4: App Integration and Lifecycle

**Files:**
- Modify: `Beyond the plains/MyApp.swift`
- Create: `Beyond the plainsTests/MusicIntegrationTests.swift`

**Interfaces:**
- Consumes: `MusicTrack.desiredTrack`, `MusicPlayer`, `AVAudioPlayerBackend`
- Produces: one app-lifetime music player driven by `gameState.phase`, `gameState.currentDay`, and SwiftUI `scenePhase`.

- [ ] **Step 1: Write failing integration-level state tests.**

Assert app-state inputs produce Track 1 at launch, Track 2 on day 6, Track 3 on day 11/result, and Track 1 after reset values. Assert inactive/background calls pause and active calls resume.

- [ ] **Step 2: Run integration tests and verify RED.**

Expected: failure because app integration does not drive the player.

- [ ] **Step 3: Integrate the player into `MyApp`.**

Own exactly one `MusicPlayer`; derive an equatable desired track from phase/day; use a cancellation-aware SwiftUI task keyed by that track; observe `scenePhase` to pause for inactive/background and resume for active. Do not alter existing screen routing.

- [ ] **Step 4: Run all tests and verify GREEN.**

Expected: the entire `Beyond the plainsTests` suite passes.

### Task 5: Build and Pre-Asset Verification

**Files:**
- Verify: all modified and created files

**Interfaces:**
- Consumes: completed music system
- Produces: a buildable app that is silent but stable until music files arrive

- [ ] **Step 1: Refresh Xcode diagnostics for all new Swift files and `MyApp.swift`.**

Expected: zero errors.

- [ ] **Step 2: Build the full app target with Xcode.**

Expected: successful build, including asset-independent AVFoundation code.

- [ ] **Step 3: Run the full test suite.**

Expected: zero test failures.

- [ ] **Step 4: Launch in the simulator without audio files.**

Expected: app navigation remains functional, missing Track 1 is logged once, and no crash or repeated load loop occurs.

- [ ] **Step 5: Record deferred verification.**

After the user supplies the three songs, add them to the app target under the logical resource names and verify audible looping, the 3-second sequential fades at days 6 and 11, and pause/resume from the same playback position.
