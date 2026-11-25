import UIKit

class ViewController: UITableViewController {

    var heroes: [Hero] = []
    private let spinner = UIActivityIndicatorView(style: .large)
    private let url = URL(string: "https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/all.json")!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Heroes"
        loadHeroes()
    }

    private func loadHeroes() {
        tableView.backgroundView = spinner
        spinner.startAnimating()

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self else { return }
            guard let data else {
                DispatchQueue.main.async { self.showError(error?.localizedDescription ?? "No data") }
                return
            }
            do {
                let decoded = try JSONDecoder().decode([Hero].self, from: data)
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.tableView.backgroundView = nil
                    self.heroes = decoded
                    self.tableView.reloadData()
                }
            } catch {
                DispatchQueue.main.async { self.showError("Could not read data") }
            }
        }.resume()
    }

    private func showError(_ message: String) {
        spinner.stopAnimating()
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.loadHeroes()
        })
        present(alert, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        heroes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeroCell", for: indexPath)
        let hero = heroes[indexPath.row]
        cell.textLabel?.text = hero.name

        switch hero.appearance.gender {
        case "Male":
            cell.imageView?.image = UIImage(systemName: "person.fill")
            cell.imageView?.tintColor = .systemBlue
        case "Female":
            cell.imageView?.image = UIImage(systemName: "person.fill")
            cell.imageView?.tintColor = .systemPink
        default:
            cell.imageView?.image = UIImage(systemName: "questionmark.circle.fill")
            cell.imageView?.tintColor = .systemGray
        }
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail",
           let detailVC = segue.destination as? DetailViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            detailVC.hero = heroes[indexPath.row]
        }
    }
}
