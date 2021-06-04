import Foundation

extension String {
    func removingCharacters(in set: CharacterSet) -> String {
        var newString = Data(capacity: lengthOfBytes(using: .utf8))
        for character in self.unicodeScalars {
            if !set.contains(character) {
                newString.append(contentsOf: character.utf8)
            }
        }
        return String(data: newString, encoding: .utf8)!
    }
}
