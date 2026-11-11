import UIKit

class DetailViewController: UIViewController {

    var item: FavoriteItem?

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private var starImageViews: [UIImageView]!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let item else { return }

        navigationItem.title = item.title
        imageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        descriptionLabel.text = item.description

        let stars = starImageViews.sorted { $0.tag < $1.tag }
        for (index, star) in stars.enumerated() {
            star.image = UIImage(systemName: index < item.rating ? "star.fill" : "star")
        }
    }
}
