import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!

    // Состояние в одном месте
    private let tracks = TrackLibrary.tracks
    private var currentIndex = 0
    private var isPlaying = false

    // Свойство класса, чтобы плеер жил столько же, сколько экран
    private var player: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTrack(at: currentIndex)
        updateUI()
    }

    // MARK: - Actions
    @IBAction func playPauseTapped(_ sender: UIButton) {
        guard let player = player else {
            print("Player is nil: track file missing or broken")
            return
        }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
        updateUI()
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        switchTrack(to: (currentIndex + 1) % tracks.count)
    }

    @IBAction func previousTapped(_ sender: UIButton) {
        switchTrack(to: (currentIndex - 1 + tracks.count) % tracks.count)
    }

    // MARK: - Logic
    private func switchTrack(to index: Int) {
        currentIndex = index
        loadTrack(at: index)
        if isPlaying {
            player?.play()
        }
        updateUI()
    }

    private func loadTrack(at index: Int) {
        let track = tracks[index]
        player?.stop()
        player = nil

        guard let url = Bundle.main.url(forResource: track.fileName, withExtension: "m4a") else {
            print("File not found in bundle: \(track.fileName).m4a")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
        } catch {
            print("Cannot play \(track.fileName): \(error.localizedDescription)")
        }
    }

    private func updateUI() {
        let track = tracks[currentIndex]
        coverImageView.image = UIImage(named: track.coverImageName)
        titleLabel.text = track.title
        artistLabel.text = track.artist
        let iconName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: iconName), for: .normal)
    }
}

// MARK: - AVAudioPlayerDelegate
extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        switchTrack(to: (currentIndex + 1) % tracks.count)
    }
}
