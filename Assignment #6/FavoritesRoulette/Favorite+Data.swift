//
//  Favorite+Data.swift
//  FavoritesRoulette
//

import Foundation

extension Favorite {
    /// My 10 favorite countries — the single source of data for the roulette.
    static let all: [Favorite] = [
        Favorite(title: "Brazil", place: "South America • Rio de Janeiro", imageName: "brazil",
                 description: "The largest country in South America. Rio is famous for Christ the Redeemer, Copacabana beach and the world's biggest carnival."),
        Favorite(title: "Egypt", place: "Africa • Luxor", imageName: "egypt",
                 description: "Shaped by the Nile for five thousand years. Luxor is an open-air museum with Karnak temple and the Valley of the Kings."),
        Favorite(title: "France", place: "Europe • Paris", imageName: "france",
                 description: "One of the most visited countries on Earth. Paris has the Eiffel Tower, the Louvre and endless cafés along the Seine."),
        Favorite(title: "India", place: "Asia • Agra", imageName: "india",
                 description: "The most populous country in the world. Agra is home to the Taj Mahal, a white marble mausoleum built by Shah Jahan."),
        Favorite(title: "Israel", place: "Asia • Jerusalem", imageName: "israel",
                 description: "Jerusalem's Old City holds sites sacred to three religions within a few hundred metres. The Dead Sea is the lowest point on land."),
        Favorite(title: "Morocco", place: "Africa • Casablanca", imageName: "morocco",
                 description: "Where the Atlas Mountains meet the Sahara. Casablanca's Hassan II Mosque stands partly over the Atlantic Ocean."),
        Favorite(title: "Portugal", place: "Europe • Lisbon", imageName: "portugal",
                 description: "The westernmost country of mainland Europe. Lisbon is known for its hills, yellow trams, azulejo tiles and pastéis de nata."),
        Favorite(title: "Slovenia", place: "Europe • Piran", imageName: "slovenia",
                 description: "A small green country between the Alps and the Adriatic. Piran is a Venetian-style seaside town with red roofs and narrow streets."),
        Favorite(title: "Tunisia", place: "Africa • Tunis", imageName: "tunisia",
                 description: "The northernmost country in Africa. Tunis has a UNESCO-listed medina, and the ruins of ancient Carthage are nearby."),
        Favorite(title: "Ukraine", place: "Europe • Ivano-Frankivsk", imageName: "ukraine",
                 description: "The largest country entirely in Europe. Ivano-Frankivsk is a cosy city near the Carpathians with Austro-Hungarian architecture.")
    ]
}
