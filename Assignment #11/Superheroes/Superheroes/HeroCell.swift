import UIKit

class HeroCell: UITableViewCell {
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) {
            self.transform = highlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
        }
    }
}
