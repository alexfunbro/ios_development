import UIKit

/// Только заполняет данными. Никаких frame, constraints и anchors в коде.
final class ViewController: UIViewController {

    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var postsValueLabel: UILabel!
    @IBOutlet weak var followersValueLabel: UILabel!
    @IBOutlet weak var followingValueLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!

    /// Поставьте true для Long text test.
    private let useLongNameTest = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let name = useLongNameTest ? "Maximilian Alexander von Habsburg" : "Aigerim Bekova"

        initialsLabel.text = name.split(separator: " ").prefix(2).compactMap { $0.first }.map(String.init).joined()
        nameLabel.text = name
        subtitleLabel.text = "iOS Developer · Almaty"
        postsValueLabel.text = "128"
        followersValueLabel.text = "4.2K"
        followingValueLabel.text = "312"
        aboutLabel.text = "Building banking apps in Swift. I like clean architecture, coffee and long walks in the mountains around Almaty."
    }
}
