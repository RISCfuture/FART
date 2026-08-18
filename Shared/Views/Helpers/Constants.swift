import Foundation

/// Risk thresholds fixed by regulation rather than by the pilot's own minimums.
enum RegulatoryThresholds {
  /// The VFR ceiling a flight is scored against, which every VFR pilot shares.
  static let vfrCeiling = Measurement(value: 3000, unit: UnitLength.feet)
}
