//
//  ViewController.swift
//  FavoritesRoulette
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var spinButton: UIButton!

    private let favorites = Favorite.all
    private var currentIndex: Int?

    @IBAction func spinTapped(_ sender: UIButton) {
        // Every index except the one on screen now, so the same favorite never repeats twice in a row.
        let candidates = favorites.indices.filter { $0 != currentIndex }
        guard let newIndex = candidates.randomElement() else { return }

        currentIndex = newIndex
        show(favorites[newIndex])
    }

    private func show(_ favorite: Favorite) {
        // Image, title and description change together inside one transition.
        UIView.transition(with: cardView, duration: 0.4, options: .transitionFlipFromRight) {
            self.photoImageView.contentMode = .scaleAspectFill
            self.photoImageView.image = UIImage(named: favorite.imageName)
            self.titleLabel.text = favorite.title
            self.placeLabel.text = favorite.place
            self.descriptionLabel.text = favorite.description
        }
        spinButton.setTitle("Spin again", for: .normal)
    }
}
