// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each signature when you start working on it.


// MARK: Level 1 · Decoding Telemetry

// 1.1
func parseReading(_ raw: String) -> Reading? { 
    guard let (sensor, valueStr) = splitOnce(raw, by: ":"),
        !sensor.isEmpty,
        let value = Int(valueStr),
        value >= 0 || sensor == "TEMP"
    else {
        return nil
    }
    
    return (sensor: sensor, value: value)
}
print(parseReading("O2:87") as Any)     // (sensor: "O2", value: 87)
print(parseReading("TEMP:-12") as Any)  // (sensor: "TEMP", value: -12)
print(parseReading("RAD:-1") as Any)    // nil
print(parseReading(":55") as Any)       // nil

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0
    
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }
    
    return (valid: valid, invalidCount: invalidCount)
}

let A = parseLog(rawLog).invalidCount


// MARK: Level 2 · Analysis

// 2.1
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}
let o2Readings = select(parseLog(rawLog).valid) { $0.sensor == "O2" }
// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard !values.isEmpty else { return nil }
    
    var minVal = values[0]
    var maxVal = values[0]
    var sum = 0
    
    for v in values {
        if v < minVal { minVal = v }
        if v > maxVal { maxVal = v }
        sum += v
    }
    
    let average = Double(sum) / Double(values.count)
    return (min: minVal, max: maxVal, average: average)
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}


let B: Int = {
    guard let s = stats(of: values(of: o2Readings)) else { return 0 }
    return Int(s.average)
}()

// 2.3 · The Closure Ladder (5 sorts, then compare results in code)
let validReadings = parseLog(rawLog).valid

// 1. Full closure syntax with explicit types and return keyword
let sort1 = validReadings.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})

// 2. Types inferred from context (compiler knows Reading from sorted(by:))
let sort2 = validReadings.sorted(by: { (a, b) in
    return a.value > b.value
})

// 3. Implicit return (single expression body, no "return" keyword needed)
let sort3 = validReadings.sorted(by: { (a, b) in a.value > b.value })

// 4. Shorthand argument names ($0, $1) instead of named parameters
let sort4 = validReadings.sorted(by: { $0.value > $1.value })

// 5. Trailing closure syntax (closure moved outside parentheses, "by:" label dropped)
let sort5 = validReadings.sorted { $0.value > $1.value }

// Verify all five results are identical, without using map/filter/reduce.
// We compare arrays element by element using only a for-loop.
func sameOrder(_ a: [Reading], _ b: [Reading]) -> Bool {
    // different lengths can't be the same order
    guard a.count == b.count else { return false }
    for i in 0..<a.count {
        if a[i].value != b[i].value {
            return false
        }
    }
    return true
}

let allMatch = sameOrder(sort1, sort2)
    && sameOrder(sort2, sort3)
    && sameOrder(sort3, sort4)
    && sameOrder(sort4, sort5)

print("All five sorts match: \(allMatch)")

// MARK: Level 3 · Temperature Stabilization

// 3.1
func heatUp(_ t: Int) -> Int {
    return t + 5
}

func coolDown(_ t: Int) -> Int {
    return t - 3
}

func hold(_ t: Int) -> Int {
    return t
}

// Safe range is 18...24 inclusive.
// Below 18 -> heatUp, above 24 -> coolDown, otherwise -> hold.
// This function returns a FUNCTION, not a value — that's the point of Level 3.
func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 {
        return heatUp
    } else if temp > 24 {
        return coolDown
    } else {
        return hold
    }
}
// quick tests
print(chooseProtocol(for: 10)(10))  // heatUp(10) -> 15
print(chooseProtocol(for: 30)(30))  // coolDown(30) -> 27
print(chooseProtocol(for: 20)(20))  // hold(20) -> 20


// 3.2
// While temp is out of [18...24] and steps < maxSteps:
// pick a protocol with chooseProtocol, apply it, increment counter.
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var temp = start
    var steps = 0
    
    while !(18...24).contains(temp) && steps < maxSteps {
        let protocolFunc = chooseProtocol(for: temp)
        temp = protocolFunc(temp)
        steps += 1
    }
    
    let isStable = (18...24).contains(temp)
    return (finalTemp: temp, steps: steps, isStable: isStable)
}

// tests from the assignment
print(runUntilStable(from: 31))              // (finalTemp: 22, steps: 3, isStable: true)
print(runUntilStable(from: -100, maxSteps: 5)) // (finalTemp: -75, steps: 5, isStable: false)

// let C = steps for the lowest valid TEMP reading in the log
let tempReadings = select(validReadings) { $0.sensor == "TEMP" }
let tempValues = values(of: tempReadings)

let C: Int = {
    guard let s = stats(of: tempValues) else { return 0 }
    let result = runUntilStable(from: s.min)
    return result.steps
}()

print("C = \(C)")

print(runUntilStable(from: 31))
print(runUntilStable(from: -100, maxSteps: 5))
// MARK: Level 4 · The Crew

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    return member.module?.oxygenTank?.level
}

// tests
if let timur = roster["Timur"] {
    print(oxygenLevel(of: timur) as Any)  // Optional(40)
}
if let dana = roster["Dana"] {
    print(oxygenLevel(of: dana) as Any)   // nil (Dock has no tank)
}

// 4.2
// Rules:
// level < 20            -> "Name: X% CRITICAL"
// level >= 20            -> "Name: X% OK"
// no data, but has module -> "Name: no data (ModuleName)"
// no module              -> "Name: no data (open space)"
func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        // no tank data — either module exists (no tank) or module is nil
        let location = member.module?.name ?? "open space"
        return "\(member.name): no data (\(location))"
    }
    
    let state = level < 20 ? "CRITICAL" : "OK"
    return "\(member.name): \(level)% \(state)"
}

// print status of whole crew
for member in crew {
    print(status(of: member))
}

// 4.3
// Tank max = 100.
// Can't take more than source has, can't add more than target can hold (up to 100).
// Negative amount -> nothing happens.
// Returns actually transferred amount.
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }
    
    let availableFromSource = min(amount, source)
    let spaceInTarget = 100 - target
    let actualTransfer = min(availableFromSource, spaceInTarget)
    
    guard actualTransfer > 0 else { return 0 }
    
    source -= actualTransfer
    target += actualTransfer
    return actualTransfer
}
let D: Int = {
    guard var labLevel = lab.oxygenTank?.level,
          var habLevel = hab.oxygenTank?.level
    else {
        return 0
    }
    
    transferOxygen(from: &labLevel, to: &habLevel, amount: 30)
    
    // write the values back into the actual tanks
    lab.oxygenTank?.level = labLevel
    hab.oxygenTank?.level = habLevel
    
    return habLevel
}()

print("D = \(D)")  // Hab had 12, +30 = 42
// 4.4
// Variadic: takes any number of names, looks each up in roster,
// skips unknown names with a console message, sorts found members by priority.
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []
    
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }
    
    // sort by priority manually (no closures required here, but you could use sorted { })
    for i in 0..<found.count {
        for j in 0..<(found.count - i - 1) {
            if found[j].priority > found[j + 1].priority {
                found.swapAt(j, j + 1)
            }
        }
    }
    
    var result: [String] = []
    for member in found {
        result.append(member.name)
    }
    return result
}

// test
print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))
// Unknown crew member: Ghost
// ["Aigerim", "Timur", "Dana"]

// MARK: Level 5 · The Saboteur's Logbook
// The saboteur's code is below, commented out (it needs your
// oxygenLevel(of:) to compile). Comment on every problem, then
// write fixed versions and a test that proves the logic bug is gone.

/*
func reportOxygen(for member: CrewMember) -> String {
    let tank = member.module!.oxygenTank!
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String {
    var result: String?
    for member in crew {
        if oxygenLevel(of: member)! < 20 {
            result = member.name
        }
    }
    return result!
}
*/

/*
 Problems in reportOxygen(for:):
 1. `member.module!` — crashes if the crew member has no module
    (e.g. Nurlan, who is in open space). This is real data in our crew array.
 2. `.oxygenTank!` — crashes if the module exists but has no tank
    (e.g. Dock, assigned to Dana). Also real data in our crew.
 3. Even without crashing, the force-unwrap chain hides the fact that
    "no data" is a legitimate state that should be handled, not crashed on.

 Problems in firstCritical(in:):
 4. `oxygenLevel(of: member)!` — crashes for any crew member with no
    oxygen data (Dana or Nurlan), instead of just skipping them.
 5. LOGIC BUG (not a `!` at all): the loop keeps overwriting `result`
    for every member below 20%, so it returns the LAST critical member
    found, not the FIRST one. The function name promises "first" but
    delivers "last". With the starter crew this bug is invisible because
    only Aigerim is critical — you need two+ critical members to see it.
 6. `return result!` — crashes if nobody is critical at all (result stays nil).
*/

func reportOxygen(for member: CrewMember) -> String {
    guard let tank = member.module?.oxygenTank else {
        return "\(member.name): no tank data"
    }
    return "\(member.name): \(tank.level)%"
}

// Returns String? now, as required — nil means "nobody is critical"
func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        guard let level = oxygenLevel(of: member) else {
            continue
        }
        if level < 20 {
            return member.name  // stop at the FIRST match
        }
    }
    return nil
}

// Build a test crew where TWO members are critical, in a known order
let testLab  = Module(name: "TestLab", oxygenTank: Tank(level: 5))   // critical
let testHab  = Module(name: "TestHab", oxygenTank: Tank(level: 8))   // also critical

let testCrew = [
    CrewMember(name: "First",  role: "Test", priority: 1, module: testLab),
    CrewMember(name: "Second", role: "Test", priority: 2, module: testHab)
]

let result = firstCritical(in: testCrew)
print("First critical: \(result ?? "none")")
// Expected: "First" — proving we return the FIRST critical member,
// not the last one (the original buggy version would return "Second")

// MARK: Finale · Launch Code

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")


// MARK: Bonus

// Closure captures `threshold` and `count` from its enclosing scope.
// Each call to makeAlarm creates a NEW, independent `count` variable
// that lives inside the returned closure, not on the stack of makeAlarm.
func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var count = 0
    
    return { level in
        if level < threshold {
            count += 1
            print("Alarm #\(count)")
            return true
        }
        return false
    }
}

let alarm = makeAlarm(threshold: 20)
print(alarm(12))  // Alarm #1 -> true
print(alarm(40))  // false
print(alarm(5))   // Alarm #2 -> true


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:
    guard let exits the current scope early if the condition fails, so
    the unwrapped value stays available for the REST of the function,
    without nesting. if let only makes the value available INSIDE its
    own braces. Example where if let is noticeably worse:
    
        func status(of member: CrewMember) -> String {
            if let level = oxygenLevel(of: member) {
                // have to put ALL remaining logic inside this block
                return level < 20 ? "critical" : "ok"
            } else {
                return "no data"
            }
        }
    With many sequential optional checks, if let forces deep nesting
    ("pyramid of doom"); guard let keeps the function flat.

 2. Why can't you pass [Int] to stats(_ values: Int...)?
    A variadic parameter Int... expects individual Int arguments
    separated by commas (like stats(3, 8, 1)), which Swift packs into
    an [Int] array INSIDE the function. It does not automatically
    unpack an existing array into separate arguments — that's a
    different call shape. That's exactly why the assignment has the
    variadic version call the array version internally, instead of
    duplicating the logic.

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?
    Swift forbids passing the same variable as two different inout
    parameters to the same call, because inout is implemented via
    "copy in, copy out" — both parameters would independently write
    back to x when the function returns, and the order of those writes
    is undefined, which could silently produce wrong results depending
    on the compiler. This is caught at compile time ("overlapping
    accesses to 'x'") to prevent that undefined behavior.

 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?
    oxygenLevel(of:) returns Int?, but "no data" is a String literal.
    The ?? operator requires both sides to be the same type (or the
    right side convertible to the left side's wrapped type). You can't
    mix an Int? with a String default — the types don't match.

 5. Full type of chooseProtocol and how to read it:
    chooseProtocol has type: (Int) -> ((Int) -> Int)
    Read it right to left / outside-in: it's a function that takes an
    Int (temp) and returns another function, which itself takes an Int
    and returns an Int. In other words: chooseProtocol takes a
    temperature and gives you back a "protocol" (a transformation rule)
    that you can later apply to any Int.

 Bonus. Where does the alarm counter live after makeAlarm returns?
    It lives on the heap, inside the closure's captured environment.
    Swift closures that capture a `var` from their enclosing scope heap-
    allocate that variable so it survives after the enclosing function
    (makeAlarm) returns. Each call to makeAlarm creates its own separate
    heap-allocated `count`, captured by reference — which is why two
    different alarms created by makeAlarm keep independent counters.
*/