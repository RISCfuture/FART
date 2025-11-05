import Foundation

extension String {
  func removingCharacters(in set: CharacterSet) -> String {
    String(unicodeScalars.filter { !set.contains($0) })
  }
}
