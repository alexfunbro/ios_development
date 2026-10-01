// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================

// SOLUTION

// MARK: Level 1 · The Deck Register

// 1.1
enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine

    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab:    return 3
        case .engine: return 4
        case .cargo:  return 5
        }
    }
}

for deck in Deck.allCases {
    print("Deck \(deck.rawValue): evacuation priority \(deck.evacuationPriority)")
}

// 1.2
enum AlarmLevel: Int {
    case green = 0, yellow, orange, red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let step = min(max(mass / 500, 0), 3)
        return AlarmLevel(rawValue: step) ?? .green
    }
}

print("0 kg -> \(AlarmLevel.level(forTotalMass: 0))")
print("940 kg -> \(AlarmLevel.level(forTotalMass: 940))")
print("4000 kg -> \(AlarmLevel.level(forTotalMass: 4000))")


// MARK: Level 2 · The Manifest

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

// 2.2
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)
    guard let tag = parts.first else { return .unknown(raw: line) }

    if tag == "crate", parts.count == 3,
       let id = Int(parts[1]), let mass = Int(parts[2]) {
        return .crate(id: id, massKg: mass)
    }
    if tag == "container", parts.count == 3,
       let mass = Int(parts[2]) {
        return .container(code: parts[1], massKg: mass)
    }
    if tag == "livestock", parts.count == 4,
       let count = Int(parts[2]), let perUnit = Int(parts[3]) {
        return .livestock(species: parts[1], count: count, massPerUnitKg: perUnit)
    }
    return .unknown(raw: line)
}

// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case .crate(_, let massKg):
        return massKg
    case .container(_, let massKg):
        return massKg
    case .livestock(_, let count, let massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

var totalManifestMass = 0
var unknownCount = 0
for line in rawManifest {
    let entry = parseEntry(line)
    totalManifestMass += mass(of: entry)
    if case .unknown = entry { unknownCount += 1 }
}
print("Manifest total mass: \(totalManifestMass) kg")
print("Unknown (corrupted) lines: \(unknownCount)")

let A = totalManifestMass


// MARK: Level 3 · Crew Snapshots

// 3.1
// No init written: a struct gets a free memberwise initializer.
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen -= amount
        if oxygen < 0 { oxygen = 0 }
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        return CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

// 3.2
func buildRoster() -> [CrewSnapshot] {
    var result: [CrewSnapshot] = []
    for record in crewData {
        if let deck = Deck(rawValue: record.deck) {
            result.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
        } else {
            print("Warning: \(record.name) is on unknown deck '\(record.deck)', skipped")
        }
    }
    return result
}

let crewRoster: [CrewSnapshot] = buildRoster()
print("Roster size: \(crewRoster.count)")
print("First crew member: \(crewRoster[0])")

let rookie = CrewSnapshot.rookie(named: "Dana")
print("Rookie: \(rookie)")

// 3.3 · Value-semantics demonstration
func drainCopy(_ snapshot: CrewSnapshot) {
    var local = snapshot          // parameter is a constant, so work on a local copy
    local.breathe(30)
    print("  inside drainCopy: \(local.name) oxygen = \(local.oxygen)")
}

func drainInPlace(_ snapshot: inout CrewSnapshot) {
    snapshot.breathe(30)
    print("  inside drainInPlace: \(snapshot.name) oxygen = \(snapshot.oxygen)")
}

var original = crewRoster[0]
print("1) Copy test")
print("  before: original = \(original.oxygen)")
var copy = original
copy.breathe(10)
print("  after:  copy = \(copy.oxygen), original = \(original.oxygen)")

print("2) Plain function test")
print("  before: original = \(original.oxygen)")
drainCopy(original)
print("  after:  original = \(original.oxygen)")

print("3) inout test")
print("  before: original = \(original.oxygen)")
drainInPlace(&original)
print("  after:  original = \(original.oxygen)")

var reviveTest = CrewSnapshot(name: "Test", deck: .cargo, oxygen: 3)
reviveTest.move(to: .lab)
print("Moved: \(reviveTest)")
reviveTest.reviveInMedbay()
print("Revived: \(reviveTest)")


// MARK: Level 4 · The Teleport Pod

// 4.1
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    // A struct gets a memberwise init for free because the compiler can fill every
    // property from arguments. A class gets no memberwise init: a class may have
    // superclass state, optional/computed setup, and shared references, so the
    // compiler requires us to write init and decide how every property starts.
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    deinit {
        print("TeleportPod \(id) deinitialized")
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        if occupant != nil || chargeLevel < 20 { return false }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let passenger = occupant else { return nil }
        chargeLevel -= 20
        occupant = nil
        return passenger
    }
}

// 4.2 · Charge ledger
let pod = TeleportPod(id: "P-1", chargeLevel: 100)
let timur = crewRoster[0]
let dana = crewRoster[1]
let nurlan = crewRoster[3]

let loaded1 = pod.load(timur)
let sent1 = pod.fire()
print("Step 1: loaded=\(loaded1), sent=\(sent1?.name ?? "nobody"), charge=\(pod.chargeLevel)")

let loaded2 = pod.load(dana)
let sent2 = pod.fire()
print("Step 2: loaded=\(loaded2), sent=\(sent2?.name ?? "nobody"), charge=\(pod.chargeLevel)")

let loaded3 = pod.load(nurlan)
let sent3 = pod.fire()
print("Step 3: loaded=\(loaded3), sent=\(sent3?.name ?? "nobody"), charge=\(pod.chargeLevel)")

let sent4 = pod.fire()
print("Step 4 (empty pod): sent=\(sent4?.name ?? "nobody"), charge=\(pod.chargeLevel)")

let C = pod.chargeLevel

// 4.3 · Reference-semantics demonstration
let samePod = pod
samePod.chargeLevel = 5
print("pod.chargeLevel = \(pod.chargeLevel), samePod.chargeLevel = \(samePod.chargeLevel)")

var snapA = crewRoster[0]
var snapB = snapA
snapB.oxygen = 1
print("snapA.oxygen = \(snapA.oxygen), snapB.oxygen = \(snapB.oxygen)")
// Rule: assigning a class instance copies the reference (both names see one object),
// assigning a struct copies the value (each name owns an independent copy).


// MARK: Level 5 · Station Systems

// 5.1
final class Station {
    let callSign: String                         // stored (let)
    var oxygenByDeck: [Deck: Int] = [:]

    var hullIntegrity: Int = 100 {               // stored (var) with observers
        willSet {
            print("Hull: \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            hullIntegrity = min(max(hullIntegrity, 0), 100)
        }
    }

    lazy var fullDiagnostics: String = {         // lazy stored
        print("Running full scan...")
        return "Station \(self.callSign): hull \(self.hullIntegrity)%, "
            + "\(self.oxygenByDeck.count) decks, total oxygen \(self.totalOxygen)"
    }()

    var totalOxygen: Int {                       // computed, read-only
        var sum = 0
        for value in oxygenByDeck.values { sum += value }
        return sum
    }

    var averageOxygen: Int {                     // computed, get + set
        get {
            if oxygenByDeck.isEmpty { return 0 }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in Array(oxygenByDeck.keys) {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    // Class: the station is one shared live object that many parts of the
    // program must see and update, which is reference semantics.
    init(callSign: String, readings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        for reading in readings {
            if let deck = Deck(rawValue: reading.deck) {
                oxygenByDeck[deck] = reading.oxygen
            } else {
                print("Skipping reading for unknown deck '\(reading.deck)'")
            }
        }
    }
}

let station = Station(callSign: "ALMA-7", readings: deckReadings)
print("Station built, diagnostics not touched yet")
print("Total oxygen: \(station.totalOxygen)")

let B = station.averageOxygen
print("Average oxygen at start-up: \(B)")

print("First access:")
print(station.fullDiagnostics)
print("Second access (no scan message expected):")
print(station.fullDiagnostics)

let quietStation = Station(callSign: "ALMA-7-QUIET", readings: deckReadings)
print("Quiet station created, never touched fullDiagnostics: no scan ran")

station.averageOxygen = 70
print("After setting average to 70: total = \(station.totalOxygen), average = \(station.averageOxygen)")

// 5.2 · The clamp trap: 130, then -40, then 55
station.hullIntegrity = 130
print("Hull after 130: \(station.hullIntegrity)")
station.hullIntegrity = -40
print("Hull after -40: \(station.hullIntegrity)")
station.hullIntegrity = 55
print("Hull after 55: \(station.hullIntegrity)")
// Why no infinite loop: inside a property's own didSet, assigning to that same
// property does not call the observers again, it just stores the value.


// MARK: Level 6 · Incident Reports

// Report 1: compiles, wrong.
//  Expected: every crew member loses 10 oxygen.
//  Actual: roster[0].oxygen is unchanged (62). `for var member` makes a mutable
//  COPY of each struct element (value semantics), so the array is never touched.
//  Fix: mutate through the index.
var fixedRoster = crewRoster
for index in fixedRoster.indices {
    fixedRoster[index].oxygen -= 10
}
print("Fixed report 1: \(fixedRoster[0].oxygen) (was \(crewRoster[0].oxygen))")

// Report 2: compiles, wrong.
//  Expected: podA stays at 100.
//  Actual: prints 0. TeleportPod is a class, so `let podB = podA` copies the
//  reference; both names point at one object (reference semantics).
//  Fix: if you want an independent pod, create a new one.
let fixedPodA = TeleportPod(id: "A", chargeLevel: 100)
let fixedPodB = TeleportPod(id: "B-copy", chargeLevel: fixedPodA.chargeLevel)
fixedPodB.chargeLevel = 0
print("Fixed report 2: podA = \(fixedPodA.chargeLevel), podB = \(fixedPodB.chargeLevel)")

// Report 3: does NOT compile.
//  Error: "cannot use mutating member on immutable value: 'self' is immutable".
//  A struct method is non-mutating by default, so self is a constant inside it.
//  Fix: mark the method `mutating` (and call it on a `var`).
struct Logbook {
    var entries: [String] = []
    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}
var logbook = Logbook()
logbook.add("Teleporter online")
logbook.add("Teleporter fault")
print("Fixed report 3: \(logbook.entries.count) entries")

// Report 4: the struct half does not compile.
//  `snapshot.oxygen = 40` -> error: cannot assign to property: 'snapshot' is a 'let' constant.
//  `pod.chargeLevel = 10` is fine.
//  For a struct, `let` freezes the whole value, including every property.
//  For a class, `let` freezes only the reference (the variable can't point to another
//  object), but the object's own `var` properties stay mutable.
//  Fix: declare the struct with `var`.
var fixedSnapshot = CrewSnapshot.rookie(named: "Dana")
fixedSnapshot.oxygen = 40
let classPod = TeleportPod(id: "B", chargeLevel: 50)
classPod.chargeLevel = 10
print("Fixed report 4: snapshot oxygen = \(fixedSnapshot.oxygen), pod charge = \(classPod.chargeLevel)")


// MARK: Level 7 · Sealing the Black Box

final class FlightRecorder {
    // private: outside code cannot read, replace or clear the entry list.
    private var entries: [String] = []

    // private(set): anyone can read it, but only this type can write, so it can't be unsealed.
    private(set) var isSealed = false

    // internal: outside code may read the count, but cannot change it.
    internal var entryCount: Int {
        return entries.count
    }

    // internal: outside code may read a formatted transcript.
    internal var transcript: String {
        return numberedLines().joined(separator: "\n")
    }

    // internal: outside code may add an entry, but the guard blocks it after sealing.
    internal func add(_ entry: String) {
        if isSealed { return }
        entries.append(entry)
    }

    // internal: outside code may seal, and there is no way to undo it.
    internal func seal() {
        isSealed = true
    }

    // fileprivate: usable by the free function below in this file, hidden from other files.
    fileprivate func numberedLines() -> [String] {
        var lines: [String] = []
        var number = 1
        for entry in entries {
            lines.append("\(number). \(entry)")
            number += 1
        }
        return lines
    }
}

func auditTranscript(of recorder: FlightRecorder) -> String {
    let lines = recorder.numberedLines()
    return "AUDIT: \(lines.count) lines, sealed = \(recorder.isSealed)\n"
        + lines.joined(separator: "\n")
}

let recorder = FlightRecorder()
recorder.add("Teleporter powered on")
recorder.add("Crew transferred")
print("Entries: \(recorder.entryCount)")
recorder.seal()
recorder.add("This entry must be rejected")
print("Entries after sealing: \(recorder.entryCount)")
print(recorder.transcript)
print(auditTranscript(of: recorder))

// Failed attempts from outside the type (kept commented, they don't compile):
// recorder.entries = []
//   error: 'entries' is inaccessible due to 'private' protection level
// recorder.isSealed = false
//   error: cannot assign to property: 'isSealed' setter is inaccessible
// (Run these yourself and paste the exact messages your compiler gives.)


// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")   // expected 1244-57-40-2


// MARK: Bonus

var survivor: TeleportPod?
do {
    let temp = TeleportPod(id: "TMP", chargeLevel: 50)
    survivor = temp
    print("Inside block: pod \(temp.id) created")
}
let survivorId = survivor?.id ?? "none"
print("After block: pod still alive through second reference: \(survivorId)")
survivor = nil   // deinit fires on this line: the last strong reference is gone
print("After survivor = nil")

func describeRelation(_ a: TeleportPod, _ b: TeleportPod) -> String {
    if a === b { return "same pod (one object)" }
    if a.id == b.id && a.chargeLevel == b.chargeLevel { return "two pods with equal contents" }
    return "different pods"
}
let twinPod = TeleportPod(id: pod.id, chargeLevel: pod.chargeLevel)
print("pod vs samePod: \(describeRelation(pod, samePod))")
print("pod vs twinPod: \(describeRelation(pod, twinPod))")
// === compares object identity (addresses), and structs have no identity: every
// variable holds its own copy, so there is no shared object to compare.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. CrewSnapshot is a struct, so Swift generates a memberwise initializer. A class
    never gets one, so TeleportPod needs a hand-written init that sets every
    stored property (occupant starts as nil).

 2. `mutating` makes self an inout parameter: the method gets the value, changes
    it, and writes it back to the caller's variable. Classes are references, so a
    method changes the shared object and never needs to replace the value itself.

 3. Struct: `let` freezes the entire value, so no property can change. Class:
    `let` freezes only the reference, so the variable can't point to another
    object, but the object's `var` properties can still change.

 4. A lazy property is computed on first access, which changes the stored
    property after init, so it must be var. It changes behaviour when the
    initializer has side effects (e.g. prints "Running full scan...", or reads
    state that changes later): it runs once, and only if it is ever used.

 5. numberedLines() is fileprivate so the free function auditTranscript(of:),
    declared outside the class but in the same file, can call it. With private
    it would be visible only inside FlightRecorder and the audit function
    would not compile.

 Bonus. deinit fires on `survivor = nil`, when the last strong reference goes
 away (leaving the do-block only drops `temp`). === can't be used on
 CrewSnapshot because structs are values with no identity or shared storage.
*/