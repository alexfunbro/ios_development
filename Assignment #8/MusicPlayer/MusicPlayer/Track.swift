import Foundation

struct Track {
    let title: String
    let artist: String
    let fileName: String
    let coverImageName: String
}

enum TrackLibrary {
    static let tracks: [Track] = [
        Track(title: "Morning Drive", artist: "Iskander Beats", fileName: "track01", coverImageName: "cover01"),
        Track(title: "Night City",    artist: "Iskander Beats", fileName: "track02", coverImageName: "cover02"),
        Track(title: "Steppe Wind",   artist: "Almaty Lo-Fi",   fileName: "track03", coverImageName: "cover03"),
        Track(title: "Blue Hour",     artist: "Almaty Lo-Fi",   fileName: "track04", coverImageName: "cover04"),
        Track(title: "Coffee Break",  artist: "Synth Club",     fileName: "track05", coverImageName: "cover05"),
        Track(title: "Orbit",         artist: "Synth Club",     fileName: "track06", coverImageName: "cover06"),
        Track(title: "Rainy Window",  artist: "Chill Lab",      fileName: "track07", coverImageName: "cover07"),
        Track(title: "Golden Sand",   artist: "Chill Lab",      fileName: "track08", coverImageName: "cover08"),
        Track(title: "Last Train",    artist: "KBTU Sound",     fileName: "track09", coverImageName: "cover09"),
        Track(title: "Starlight",     artist: "KBTU Sound",     fileName: "track10", coverImageName: "cover10")
    ]
}
