import UIKit

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet private weak var tableView: UITableView!

    private let items: [FavoriteItem] = [
        FavoriteItem(title: "Austria", subtitle: "Europe • Vienna", imageName: "austria", rating: 4),
        FavoriteItem(title: "Brazil", subtitle: "South America • Rio De Janeiro", imageName: "brazil", rating: 5),
        FavoriteItem(title: "China", subtitle: "Asia • Chunching", imageName: "china", rating: 3),
        FavoriteItem(title: "Egypt", subtitle: "Africa • Luxor", imageName: "egypt", rating: 5),
        FavoriteItem(title: "England", subtitle: "Europe • London", imageName: "england", rating: 2),
        FavoriteItem(title: "France", subtitle: "Europe • Paris", imageName: "france", rating: 4),
        FavoriteItem(title: "Germany", subtitle: "Europe • Frankfurt am Main", imageName: "germany", rating: 3),
        FavoriteItem(title: "India", subtitle: "Asia • Agra", imageName: "india", rating: 5),
        FavoriteItem(title: "Israel", subtitle: "Asia • Jerusalem", imageName: "israel", rating: 4),
        FavoriteItem(title: "Italy", subtitle: "Europe • Pisa", imageName: "italy", rating: 4),
        FavoriteItem(title: "South Korea", subtitle: "Asia • Seoul", imageName: "korea", rating: 2),
        FavoriteItem(title: "Mexico", subtitle: "North America • Mexico City", imageName: "mexico", rating: 3),
        FavoriteItem(title: "Morocco", subtitle: "Africa • Kasablanka", imageName: "morocco", rating: 5),
        FavoriteItem(title: "Poland", subtitle: "Europe • Gdansk", imageName: "poland", rating: 4),
        FavoriteItem(title: "Portugal", subtitle: "Europe • Lisbon", imageName: "portugal", rating: 5),
        FavoriteItem(title: "Slovenia", subtitle: "Europe • Piran", imageName: "slovenia", rating: 5),
        FavoriteItem(title: "Spain", subtitle: "Europe • Salamanca", imageName: "spain", rating: 4),
        FavoriteItem(title: "Tunisia", subtitle: "Africa • Tunis", imageName: "tunisia", rating: 5),
        FavoriteItem(title: "Ukraine", subtitle: "Europe • Ivano-Frankivsk", imageName: "ukraine", rating: 5),
        FavoriteItem(title: "United States of America", subtitle: "North America • New York", imageName: "usa", rating: 4)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoriteCell
        cell.configure(with: items[indexPath.row])
        return cell
    }
}
