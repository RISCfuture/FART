import Defaults
import Foundation

/// A dimension the app expresses in a single unit everywhere.
///
/// Aviation units are fixed worldwide, so each dimension the app measures has one canonical
/// unit — knots for speed, feet for length. Pinning that unit to the dimension lets a
/// measurement be stored as the bare number a preference already holds, and lets a
/// measurement arriving in any other unit be normalized on its way down to storage.
///
/// - Note: `CanonicalDimension` stands in for `Self`, which a non-final class such as
///   ``Foundation/UnitSpeed`` cannot satisfy in a static requirement.
public protocol CanonicalUnit: Dimension {
  associatedtype CanonicalDimension: Dimension = Self

  /// The unit this app stores and displays every measurement of this dimension in.
  static var canonical: CanonicalDimension { get }
}

extension UnitSpeed: CanonicalUnit {
  public static var canonical: UnitSpeed { .knots }
}

extension UnitLength: CanonicalUnit {
  public static var canonical: UnitLength { .feet }
}

/// Stores a measurement as a bare number in its dimension's ``CanonicalUnit/canonical`` unit.
///
/// Serializing to a plain number keeps the preference readable and lets a value an earlier
/// build wrote as an integer read straight back, since `UserDefaults` bridges either through
/// `NSNumber`. Conversion happens only here, at the storage boundary.
public struct MeasurementBridge<UnitType>: Defaults.Bridge
where UnitType: CanonicalUnit, UnitType.CanonicalDimension == UnitType {
  public typealias Value = Measurement<UnitType>
  public typealias Serializable = Double

  public func serialize(_ value: Value?) -> Serializable? {
    value?.converted(to: .canonical).value
  }

  public func deserialize(_ object: Serializable?) -> Value? {
    object.map { Measurement(value: $0, unit: .canonical) }
  }
}

extension Measurement: @retroactive Defaults.Serializable
where UnitType: CanonicalUnit, UnitType.CanonicalDimension == UnitType {
  public static var bridge: MeasurementBridge<UnitType> { .init() }
}
