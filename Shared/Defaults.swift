import Defaults
import Foundation
import MeasurementKitDefaults

extension Defaults.Keys {
  // periphery:ignore - used only in the macOS welcome flow, invisible to the iOS scan
  static let hasCompletedWelcome = Key<Bool>("hasCompletedWelcome", default: false)

  static let rating = Key<Rating>("rating", default: .VFR)
  static let hours = Key<Hours>("hours", default: .under100)

  static let shortRunway = Key<Measurement<UnitLength>>(
    "shortRunway",
    default: .init(value: 3000, unit: .feet)
  )

  static let strongWinds = Key<Measurement<UnitSpeed>>(
    "strongWinds",
    default: .init(value: 15, unit: .knots)
  )
  static let strongCrosswinds = Key<Measurement<UnitSpeed>>(
    "strongCrosswinds",
    default: .init(value: 7, unit: .knots)
  )
  static let lowCeiling = Key<Ceiling>("lowCeiling", default: .oneThousandFeet)
  static let lowVisibility = Key<Visibility>("lowVisibility", default: .threeSM)
}
