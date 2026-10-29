# Music Player — UIStackView & Auto Layout

Single-screen music player built with UIKit. It shows the track cover, title and artist, with Previous / Play-Pause / Next controls that play audio files bundled with the app.

## Screenshots

| iPhone SE (3rd gen) | iPhone 16 Pro Max |
|:---:|:---:|
| <img src="screenshots/iphone-se.png" width="250"> | <img src="screenshots/iphone-16-pro-max.png" width="250"> |

## Demo

Screen recording (play, pause, next, previous, wrap-around): [demo.mov](screenshots/demo.mov)

## Layout (Main.storyboard only)

- Root vertical `UIStackView` (spacing 24) contains:
  - cover `UIImageView` with a 1:1 aspect ratio constraint
  - vertical stack with title and artist labels (alignment center, spacing 8)
  - horizontal stack with three buttons (`backward.fill`, `play.fill` / `pause.fill`, `forward.fill`, distribution fill equally)
- The root stack is pinned to the Safe Area with 20 pt leading/trailing margins and is vertically centered.
- No layout code in Swift.

## Code

- `Track.swift` defines the `Track` struct (`title`, `artist`, `fileName`, `coverImageName`) and `TrackLibrary` with the list of 10 tracks.
- `ViewController.swift`:
  - loads audio with `Bundle.main.url(forResource:withExtension:)` and plays it with `AVAudioPlayer`
  - keeps the player as a property so it lives as long as the screen
  - stores `currentIndex` and `isPlaying` in one place and refreshes the whole UI from them with `updateUI()`
  - Next / Previous wrap around the list and keep the play state
  - plays the next track automatically through `AVAudioPlayerDelegate.audioPlayerDidFinishPlaying`
  - a missing file or a failing `try` prints an error instead of crashing

## Assets

10 audio files (`.m4a`, about 0.5 MB each) and 10 cover images live in `MusicPlayer/MusicAssets` and belong to the app target. The audio tracks are original, programmatically synthesized melodies made for this lab, so they are royalty-free.

## Run

Open `MusicPlayer.xcodeproj` in Xcode and run on any iPhone simulator. No extra setup is needed.
