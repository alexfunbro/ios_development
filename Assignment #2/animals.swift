var firstSet: Set<String> = ["cat", "dog"]
var secondSet: Set<String> = ["dog", "mouse"]
var unionSet = firstSet.union(secondSet)
let result = unionSet.subtracting(secondSet)
print(result)