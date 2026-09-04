import Foundation
public import MeasurementKit

extension UnitSpeed: @retroactive CanonicalUnit {
  /// Aviation flies knots worldwide, so every speed the app stores is a number of knots.
  static var canonical: UnitSpeed { .knots }
}

extension UnitLength: @retroactive CanonicalUnit {
  /// Aviation flies feet worldwide, so every length the app stores is a number of feet.
  static var canonical: UnitLength { .feet }
}
