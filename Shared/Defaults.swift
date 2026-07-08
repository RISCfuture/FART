import Defaults

extension Defaults.Keys {
  // periphery:ignore - used only in the macOS welcome flow, invisible to the iOS scan
  static let hasCompletedWelcome = Key<Bool>("hasCompletedWelcome", default: false)

  static let rating = Key<Rating>("rating", default: .VFR)
  static let hours = Key<Hours>("hours", default: .under100)

  static let shortRunway = Key<Int>("shortRunway", default: 3000)

  static let strongWinds = Key<Int>("strongWinds", default: 15)
  static let strongCrosswinds = Key<Int>("strongCrosswinds", default: 7)
  static let lowCeiling = Key<Ceiling>("lowCeiling", default: .oneThousandFeet)
  static let lowVisibility = Key<Visibility>("lowVisibility", default: .threeSM)
}
