import UIKit

class DetailViewController: UIViewController {

    var hero: Hero!
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!

    private var statBars: [(bar: UIProgressView, value: Float)] = []
    private var didAnimateStats = false
    private var widthConstraint: NSLayoutConstraint?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = hero.name

        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 32, trailing: 16)
        stackView.spacing = 16
        stackView.alignment = .fill

        // картинка не должна распирать экран своей реальной шириной
        heroImageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        heroImageView.setContentHuggingPriority(.defaultLow, for: .horizontal)

        // прокрутка только вертикальная
        if let scrollView = view as? UIScrollView {
            scrollView.alwaysBounceHorizontal = false
            scrollView.showsHorizontalScrollIndicator = false
        }

        // ширина стека = ширина экрана
        widthConstraint = stackView.widthAnchor.constraint(equalToConstant: view.bounds.width)
        widthConstraint?.isActive = true

        setupHeader()
        loadImage()
        buildSections()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        widthConstraint?.constant = view.bounds.width
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didAnimateStats else { return }
        didAnimateStats = true
        // полоски заполняются по очереди
        for (index, item) in statBars.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                item.bar.setProgress(item.value, animated: true)
            }
        }
    }

    // MARK: - Header

    private func setupHeader() {
        heroImageView.image = UIImage(systemName: "photo",
                                      withConfiguration: UIImage.SymbolConfiguration(pointSize: 60))
        heroImageView.tintColor = .systemGray3
        heroImageView.backgroundColor = .secondarySystemGroupedBackground
        heroImageView.contentMode = .center
        heroImageView.layer.cornerRadius = 20
        heroImageView.clipsToBounds = true

        nameLabel.text = hero.name
        nameLabel.font = .systemFont(ofSize: 30, weight: .bold)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
        stackView.setCustomSpacing(4, after: nameLabel)

        let parts = [hero.biography.fullName.clean, hero.biography.publisher.clean]
            .filter { $0 != "Unknown" }
        if !parts.isEmpty {
            let subtitle = UILabel()
            subtitle.text = parts.joined(separator: " • ")
            subtitle.font = .systemFont(ofSize: 15)
            subtitle.textColor = .secondaryLabel
            subtitle.textAlignment = .center
            subtitle.numberOfLines = 0
            stackView.addArrangedSubview(subtitle)
            stackView.setCustomSpacing(12, after: subtitle)
        }

        stackView.addArrangedSubview(makeAlignmentBadge())
    }

    private func loadImage() {
        guard let urlString = hero.images.lg ?? hero.images.md,
              let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                guard let self else { return }
                UIView.transition(with: self.heroImageView, duration: 0.3, options: .transitionCrossDissolve) {
                    self.heroImageView.contentMode = .scaleAspectFill
                    self.heroImageView.image = image
                }
            }
        }.resume()
    }

    private func makeAlignmentBadge() -> UIView {
        let alignment = hero.biography.alignment.clean
        let color: UIColor
        let icon: String
        switch alignment.lowercased() {
        case "good": color = .systemGreen; icon = "hand.thumbsup.fill"
        case "bad":  color = .systemRed;   icon = "flame.fill"
        default:     color = .systemGray;  icon = "circle.lefthalf.filled"
        }

        var config = UIButton.Configuration.filled()
        config.title = alignment.capitalized
        config.image = UIImage(systemName: icon)
        config.imagePadding = 6
        config.baseBackgroundColor = color.withAlphaComponent(0.15)
        config.baseForegroundColor = color
        config.cornerStyle = .capsule
        let badge = UIButton(configuration: config)
        badge.isUserInteractionEnabled = false
        badge.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.addSubview(badge)
        NSLayoutConstraint.activate([
            badge.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            badge.topAnchor.constraint(equalTo: container.topAnchor),
            badge.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    // MARK: - Sections

    private func buildSections() {
        // 1. Powerstats (6 свойств)
        stackView.addArrangedSubview(
            makeSection(title: "Powerstats", icon: "chart.bar.fill", content: makeStatsView()))

        // 2. Appearance (6 свойств)
        let a = hero.appearance
        let chips = [
            makeChip(title: "Gender", value: a.gender.clean, icon: "person.fill"),
            makeChip(title: "Race", value: a.race.clean, icon: "globe"),
            makeChip(title: "Height", value: (a.height?.last).clean, icon: "ruler"),
            makeChip(title: "Weight", value: (a.weight?.last).clean, icon: "scalemass"),
            makeChip(title: "Eyes", value: a.eyeColor.clean, icon: "eye"),
            makeChip(title: "Hair", value: a.hairColor.clean, icon: "scissors")
        ]
        stackView.addArrangedSubview(
            makeSection(title: "Appearance", icon: "figure.stand", content: makeGrid(chips)))

        // 3. Biography (4 свойства + alignment в бейдже)
        let b = hero.biography
        let bio = UIStackView(arrangedSubviews: [
            makeInfoRow(title: "Full name", value: b.fullName.clean),
            makeInfoRow(title: "Place of birth", value: b.placeOfBirth.clean),
            makeInfoRow(title: "Publisher", value: b.publisher.clean),
            makeInfoRow(title: "First appearance", value: b.firstAppearance.clean)
        ])
        bio.axis = .vertical
        bio.spacing = 12
        stackView.addArrangedSubview(
            makeSection(title: "Biography", icon: "book.fill", content: bio))
    }

    /// Карточка с заголовком, которая сворачивается по тапу
    private func makeSection(title: String, icon: String, content: UIView) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = CGSize(width: 0, height: 2)

        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = UIImage(systemName: icon)
        config.imagePadding = 8
        config.baseForegroundColor = .label
        config.contentInsets = .zero
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var new = attrs
            new.font = .systemFont(ofSize: 20, weight: .semibold)
            return new
        }
        let header = UIButton(configuration: config)
        header.contentHorizontalAlignment = .leading

        let chevron = UIImageView(image: UIImage(systemName: "chevron.up"))
        chevron.tintColor = .secondaryLabel
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        let headerRow = UIStackView(arrangedSubviews: [header, chevron])
        headerRow.alignment = .center

        let inner = UIStackView(arrangedSubviews: [headerRow, content])
        inner.axis = .vertical
        inner.spacing = 14
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        header.addAction(UIAction { [weak self] _ in
            let collapse = !content.isHidden
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.85,
                           initialSpringVelocity: 0) {
                content.isHidden = collapse
                content.alpha = collapse ? 0 : 1
                chevron.transform = collapse ? CGAffineTransform(rotationAngle: .pi) : .identity
                self?.view.layoutIfNeeded()
            }
        }, for: .touchUpInside)

        return card
    }

    // MARK: - Powerstats

    private func makeStatsView() -> UIView {
        let p = hero.powerstats
        let stats: [(name: String, icon: String, value: Int?, color: UIColor)] = [
            ("Intelligence", "brain.head.profile", p.intelligence, .systemBlue),
            ("Strength", "dumbbell.fill", p.strength, .systemRed),
            ("Speed", "hare.fill", p.speed, .systemYellow),
            ("Durability", "shield.fill", p.durability, .systemGreen),
            ("Power", "bolt.fill", p.power, .systemOrange),
            ("Combat", "figure.martial.arts", p.combat, .systemPurple)
        ]

        let list = UIStackView()
        list.axis = .vertical
        list.spacing = 14

        for stat in stats {
            let icon = UIImageView(image: UIImage(systemName: stat.icon))
            icon.tintColor = stat.color
            icon.contentMode = .scaleAspectFit
            icon.widthAnchor.constraint(equalToConstant: 22).isActive = true

            let name = UILabel()
            name.text = stat.name
            name.font = .systemFont(ofSize: 15, weight: .medium)

            let value = UILabel()
            value.text = stat.value.map { "\($0)" } ?? "Unknown"
            value.font = .monospacedDigitSystemFont(ofSize: 15, weight: .semibold)
            value.textColor = .secondaryLabel
            value.setContentHuggingPriority(.required, for: .horizontal)

            let top = UIStackView(arrangedSubviews: [icon, name, value])
            top.spacing = 8

            let bar = UIProgressView(progressViewStyle: .default)
            bar.progressTintColor = stat.color
            bar.trackTintColor = .tertiarySystemFill
            bar.progress = 0
            bar.layer.cornerRadius = 4
            bar.clipsToBounds = true
            bar.heightAnchor.constraint(equalToConstant: 8).isActive = true
            statBars.append((bar, Float(min(stat.value ?? 0, 100)) / 100))

            let row = UIStackView(arrangedSubviews: [top, bar])
            row.axis = .vertical
            row.spacing = 6
            list.addArrangedSubview(row)
        }
        return list
    }

    // MARK: - Appearance

    private func makeChip(title: String, value: String, icon: String) -> UIView {
        let box = UIView()
        box.backgroundColor = .tertiarySystemGroupedBackground
        box.layer.cornerRadius = 12

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .systemIndigo
        iconView.contentMode = .scaleAspectFit
        iconView.heightAnchor.constraint(equalToConstant: 20).isActive = true

        let titleLabel = UILabel()
        titleLabel.text = title.uppercased()
        titleLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        titleLabel.textColor = .secondaryLabel

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        valueLabel.textColor = value == "Unknown" ? .tertiaryLabel : .label
        valueLabel.numberOfLines = 2
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.8

        let content = UIStackView(arrangedSubviews: [iconView, titleLabel, valueLabel])
        content.axis = .vertical
        content.spacing = 4
        content.alignment = .leading
        content.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: box.topAnchor, constant: 12),
            content.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 12),
            content.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -12),
            content.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -12)
        ])
        return box
    }

    private func makeGrid(_ chips: [UIView]) -> UIView {
        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 10
        for i in stride(from: 0, to: chips.count, by: 2) {
            let row = UIStackView(arrangedSubviews: Array(chips[i..<min(i + 2, chips.count)]))
            row.axis = .horizontal
            row.spacing = 10
            row.distribution = .fillEqually
            grid.addArrangedSubview(row)
        }
        return grid
    }

    // MARK: - Biography

    private func makeInfoRow(title: String, value: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textColor = .secondaryLabel

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .medium)
        valueLabel.textColor = value == "Unknown" ? .tertiaryLabel : .label
        valueLabel.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        row.axis = .vertical
        row.spacing = 2
        return row
    }
}
