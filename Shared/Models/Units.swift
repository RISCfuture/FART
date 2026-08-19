import Foundation
import MeasurementKit

extension UnitSpeed: @retroactive CanonicalUnit {
  /// Aviation flies knots worldwide, so every speed the app stores is a number of knots.
  public static var canonical: UnitSpeed { .knots }
}

extension UnitLength: @retroactive CanonicalUnit {
  /// Aviation flies feet worldwide, so every length the app stores is a number of feet.
  public static var canonical: UnitLength { .feet }
}
