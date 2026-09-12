let firstName: String = "Iskander"
let lastName: String = "Bekishev"
let birthYear: Int = 2007
var isStudent: Bool = true
var height: Double = 181
var currentYear: Int = 2026
var age: Int = currentYear - birthYear
var hobbies = ["Playing guitar", "History"]
var numberOfHobbies: Int = hobbies.count
let favoriteNumber: Int = 4
let isHobbyCreative: Bool = true
var futureGoals: String = "become a pro"
var favoriteEmoji: String =  "👌"
let lifeStory = "My name is \(firstName) \(lastName), I was born in \(birthYear), so I'm currently \(age) years old. I'm \(height) cm tall. Am I a student? \(isStudent). I have \(numberOfHobbies) hobbies: \(hobbies.joined(separator: ", ")). My favorite number is \(favoriteNumber), and yes, my hobbies are creative: \(isHobbyCreative). In the future, I want to \(futureGoals) \(favoriteEmoji)"

print(lifeStory)