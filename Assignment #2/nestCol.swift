var results: [String: [Int]] = ["Iskander": [3, 4, 3, 5, 4], "Deniel": [4, 5, 3, 5, 5], "Arsen": [5, 4, 5, 5, 4]]
print(results["Iskander"]?[3] ?? 0)