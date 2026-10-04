# Background Music Design

## Goal

Add continuous background music to *Beyond the Plains* using three looping tracks. The music should follow the journey's three narrative sections, transition smoothly, and require no controls from the player.

## Track Mapping

| Track | Game section |
|---|---|
| `MusicPart1` | Start screen, party setup, shop, and scenarios 1–5 |
| `MusicPart2` | Scenarios 6–10 |
| `MusicPart3` | Scenarios 11–14 and the ending screen |

The selected audio files will be added to the app target with stable resource names. Supported bundled formats may include `.m4a` or `.mp3`; the implementation will resolve the resource extension explicitly from the configured track definition.

## Architecture

Create one app-lifetime `MusicPlayer` backed by `AVAudioPlayer`. `MyApp` owns the player so SwiftUI screen replacement does not interrupt playback or create overlapping players.

The player receives the desired logical track from the current `GameState.phase` and `GameState.currentDay`. Repeated state updates that resolve to the currently playing track do nothing, preventing restarts during unrelated SwiftUI updates.

`AVAudioEngine` is intentionally excluded because the requested transition is sequential rather than overlapping: fade the old track out completely, then start and fade in the new track.

## Playback Behavior

- Track 1 starts when the start screen appears.
- Every track loops indefinitely while its game section remains active.
- A track change fades the current track from its playback volume to silence over 3 seconds.
- After the fade-out completes, the old track stops, the new track starts from the beginning at zero volume, and fades to playback volume over 3 seconds.
- Starting a new game transitions back to Track 1.
- Track 3 continues through the winner screen rather than stopping at scenario 14.
- The app exposes no mute button or in-game volume control. The device volume controls playback level.

## Transition Coordination

Only one asynchronous transition task may control playback at a time. A new desired track cancels any in-progress transition and starts a new transition toward the latest requested track. Cancellation must leave the player in a valid state and must never allow two tracks to play simultaneously.

The desired track is derived independently from playback mechanics so boundary behavior can be tested without loading real audio files.

## App Lifecycle

When the app becomes inactive or enters the background, music pauses and retains its playback position. When the app becomes active again, playback resumes from that position unless game state now requires a different track; in that case the normal 3-second transition selects the correct track.

The audio session should be configured for background music that respects the person's existing system audio behavior. The app will not request background-audio execution.

## Missing or Invalid Files

If a configured audio resource is absent or cannot be decoded, the app continues without crashing. Playback for that track remains silent and a diagnostic message is emitted in Xcode. A later valid track request must still work normally.

## Files and Responsibilities

- `MusicPlayer.swift`: track definition, resource loading, looping playback, fades, cancellation, pause, and resume.
- `MyApp.swift`: owns the single player, derives the desired track from game state, and forwards scene-phase changes.
- Three bundled audio resources using the logical names `MusicPart1`, `MusicPart2`, and `MusicPart3`.
- A test target containing track-selection and transition-state tests.

## Verification

Automated tests will cover:

- Track 1 for the start, party setup, shop, and scenarios 1–5.
- Boundary changes from scenario 5 to 6 and scenario 10 to 11.
- Track 3 remaining active through the ending.
- Resetting the game selecting Track 1.
- A newer track request superseding an in-progress transition.
- Missing resources failing safely.

Simulator verification will confirm:

- Track 1 begins on app launch and loops.
- Each transition takes 3 seconds down and 3 seconds up without overlap.
- Backgrounding pauses playback and returning resumes from the saved position.
- Screen changes do not restart the currently selected track.

## Deferred Audio Assets

The music system can be implemented before the final songs are selected. Until the files are added, missing-resource handling keeps the app silent without crashing. The chosen filenames and formats will later be mapped to the stable logical track names, followed by final playback and fade verification with real audio.
