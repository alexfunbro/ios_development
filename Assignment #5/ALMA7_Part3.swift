// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================



// MARK: - =================== YOUR SOLUTION ===================

// MARK: Level 1 · The Power Cell

// Why a class and not a struct here?  -> The battery is one physical object that many drones
// and screens must observe and drain together, so it needs reference semantics, not copies.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = min(max(charge, 0), 100)
    }

    func level() -> Int { charge }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, amount <= charge else { return false }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        guard amount > 0 else { return }
        charge = min(charge + amount, 100)
    }
}

// Encapsulation proof:
// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level


// MARK: Level 2 · The Fleet

// 2.1  What does `final` on runOnce() buy you?  -> Subclasses can change the cost and the work
// (powerCost, performTask) but can never replace the shift ritual itself, so no drone can skip paying.
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String {
        "\(id): \(cell.level())% \(cell.level().powerBar)"
    }

    func performTask() -> Int { 0 }

    final func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }
    func weldSeam() -> String { "\(id) welded a seam" }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }
    override func performTask() -> Int { 15 }
    override var statusLine: String { super.statusLine + " [scanner]" }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":  return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo":   return CargoDrone(id: id, cell: cell)
    default:        return nil
    }
}

var fleet: [Drone] = []
for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        fleet.append(drone)
    } else {
        print("WARNING: skipped record \(record.id), unknown kind '\(record.kind)'")
    }
}


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var total = 0
    for _ in 0..<max(rounds, 0) {
        for drone in fleet {
            total += drone.runOnce()
        }
    }
    return total
}

let A = runShift(fleet, rounds: 3)

var B = 0
var C = 0
for drone in fleet {
    print(drone.statusLine)
    B += drone.cell.level()
    if drone.cell.level() >= drone.powerCost { C += 1 }
}
print("Drones able to run one more task: \(C)")


// MARK: Level 4 · Diagnostics

// 4.1
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// Why does Drone implement recharge(by:) without `mutating`?  -> Drone is a class (reference type):
// the method changes the object the reference points to, not the reference itself, so `self` is
// never reassigned. `mutating` only exists for value types, where a method must be allowed to replace `self`.
extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }
    var statusCode: Int { healthCode(for: cell.level()) }
    func recharge(by amount: Int) { cell.recharge(by: amount) }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String { id }
    var statusCode: Int { healthCode(for: chargeLevel) }

    mutating func recharge(by amount: Int) {
        guard amount > 0 else { return }
        chargeLevel = min(chargeLevel + amount, 100)
    }
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(id: record.id, chargeLevel: record.charge))
}

// Why could [Drone] never have held the sensors?  -> SensorModule is a struct and cannot inherit
// from the Drone class; only a protocol can be the common element type for a class and a struct.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var lines: [String] = []
    for component in components {
        lines.append(component.diagnose())
    }
    return lines.joined(separator: "\n")
}

var everything: [Diagnosable] = []
for drone in fleet { everything.append(drone) }
for sensor in sensors { everything.append(sensor) }
print("--- Diagnostics ---")
print(diagnosticsReport(everything))


// MARK: Level 5 · Shared Behaviour

// 5.1 · default diagnose() + the single home of the Health Rule
extension Diagnosable {
    func diagnose() -> String { "\(componentID): code \(statusCode)" }

    func healthCode(for level: Int) -> Int {   // THE Health Rule, written once
        if level < 20 { return 2 }
        if level < 50 { return 1 }
        return 0
    }
}

// 5.2 · the beacon you cannot edit
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { healthCode(for: signalStrength) }
    func diagnose() -> String { "[LEGACY] \(name): signal \(signalStrength), code \(statusCode)" }
}

everything.append(beacon)
print("--- Diagnostics (with beacon) ---")
print(diagnosticsReport(everything))

var D = 0
for component in everything {
    D += component.statusCode
}

// Rechargeable demo on a copy (so D stays untouched)
var spareSensor = sensors[0]
spareSensor.recharge(by: 50)
print("Spare sensor after recharge: \(spareSensor.chargeLevel)")

// 5.3
extension Int {
    var powerBar: String {
        let filled = Swift.min(Swift.max(self / 10, 0), 10)
        return String(repeating: "#", count: filled) + String(repeating: ".", count: 10 - filled)
    }
}


// MARK: Level 6 · Incident Reports
// Note: by my analysis Reports 1, 2 and 3 do not compile, and only Report 4 compiles and lies.
//
// Report 1: expected: PatchDrone gives 30 work units. Actual: compile error "overriding declaration
//   requires an 'override' keyword". Rule: redeclaring an inherited member must be marked `override`,
//   so accidental overrides are impossible. Fix: `override func performTask() -> Int { 30 }`.
//
// Report 2: expected: HeavyWelder customises the shift. Actual: compile error "cannot inherit from
//   final class 'WelderDrone'" (and runOnce() is final too). Rule: `final` forbids subclassing and
//   overriding. Fix: subclass a non-final base (or drop `final` on purpose) and override powerCost /
//   performTask, never runOnce().
//
// Report 3: expected: first.weldSeam() works. Actual: compile error "value of type 'Drone' has no
//   member 'weldSeam'". Rule: the compiler only allows members of the static type (Drone). Fix: below.
//   as? returns an optional because the cast can fail at runtime if the object is not a WelderDrone.
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
if let welder = first as? WelderDrone {
    print(welder.weldSeam())
}
//
// Report 4: expected: "thruster T-1". Actual: prints "generic component". Rule: label() is not a protocol
//   requirement, only an extension method, so a call through the existential `Labelled` is dispatched
//   statically to the extension body. Fix: add `func label() -> String` to the protocol requirements,
//   then the call goes through the witness table and reaches Thruster's own method.
protocol LabelledFixed {
    var componentID: String { get }
    func label() -> String          // the one added line
}
extension LabelledFixed {
    func label() -> String { "generic component" }
}
struct Thruster: LabelledFixed {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}
let parts: [LabelledFixed] = [Thruster(componentID: "T-1")]
print(parts[0].label())   // thruster T-1

/*
// Original reports (kept for reference)
class PatchDrone: Drone {
    func performTask() -> Int { return 30 }
}
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int { return 999 }
}
*/


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: Bonus

// Runtime: in Drone.init, after the stored properties are set:
//     precondition(type(of: self) != Drone.self, "Drone is abstract, use a subclass")
// (or fatalError inside performTask()). Fails only when the line actually executes.
// Compile time: make the base type a protocol, below. A protocol cannot be instantiated at all.

protocol DroneLike: Diagnosable {
    var id: String { get }
    var cell: PowerCell { get }
    var powerCost: Int { get }
    func performTask() -> Int
}

extension DroneLike {
    var componentID: String { id }
    var statusCode: Int { healthCode(for: cell.level()) }
    func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

struct WelderUnit: DroneLike {
    let id: String
    let cell: PowerCell
    var powerCost: Int { 25 }
    func performTask() -> Int { 40 }
}

// Comparison: the class design guarantees the shift ritual with `final` and shares stored state
// through the hierarchy, but allows a meaningless bare Drone and single inheritance only. The
// protocol design makes misuse impossible at compile time and accepts structs and legacy types,
// but runOnce() in an extension can be shadowed and offers no stored properties to inherit. For this
// station I would pick protocols; if drones had to share mutable state, I would keep a class
// (or a shared class like PowerCell inside the structs) to get reference semantics.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. A class is a reference type: a method changes the object behind the reference and never has to
    reassign `self`, so no keyword is needed. A struct's method may modify the value `self` itself,
    so it must say `mutating` to be allowed to.

 2. Inheritance can pass down stored properties and a ready implementation (id, cell, init, runOnce)
    through a hierarchy; protocols cannot hold stored state. Protocols can unite unrelated types,
    including structs and types you cannot edit (LegacyBeacon via an extension); a class can only
    inherit from one superclass and structs cannot inherit at all.

 3. `final` forbids overriding a member (or subclassing a class). Making runOnce() final protected the
    shift ritual: no subclass can skip paying powerCost or return fake work, as Report 2 tried (999 for free).

 4. label() was not a protocol requirement, only an extension method. For such methods Swift picks the
    implementation by the static type (Labelled), so the extension body is called. Once it is a requirement,
    the call is dynamically dispatched and the struct's own method wins.
*/