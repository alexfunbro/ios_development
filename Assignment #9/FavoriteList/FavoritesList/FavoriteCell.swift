import UIKit

class FavoriteCell: UITableViewCell {
    
    @IBOutlet private weak var itemImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private var starImageView: [UIImageView]!
    
    func configure(with item: FavoriteItem) {
        itemImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        
        let stars = starImageView.sorted { $0.tag < $1.tag}
        for (index, star) in stars.enumerated() {
            star.image = UIImage(systemName: index < item.rating ? "star.fill" : "star")
        }
    }
}
