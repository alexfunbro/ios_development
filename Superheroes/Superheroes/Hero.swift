import Foundation

struct Hero: Codable {
    let id: Int
    let name: String
    let powerstats: Powerstats
    let appearance: Appearance
    let biography: Biography
    let images: Images
}

struct Powerstats: Codable {
    let intelligence, strength, speed, durability, power, combat: Int?
}

struct Appearance: Codable {
    let gender, race, eyeColor, hairColor: String?
    let height, weight: [String]?
}

struct Biography: Codable {
    let fullName, placeOfBirth, publisher, alignment, firstAppearance: String?
}

struct Images: Codable {
    let md, lg: String?
}

// "-", null, "" и "0 cm" превращаются в "Unknown"
extension Optional where Wrapped == String {
    var clean: String {
        guard let value = self?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty,
              value != "-",
              value.lowercased() != "null",
              !value.hasPrefix("0 ") else { return "Unknown" }
        return value
    }
}
