import Defaults
import Foundation

enum Rating: String, Defaults.Serializable {
  case VFR
  case IFR
}

enum Hours: String, Defaults.Serializable {
  case under100
  case over100
}

enum Ceiling: Int, CaseIterable, Defaults.Serializable {
  case threeThousandFeet = 3000
  case oneThousandFeet = 1000
  case fiveHundredFeet = 500
  case twoHundredFeet = 200

  /// The ceiling as a height above ground. The raw value is this case's stored form; every
  /// use of the ceiling as a quantity goes through here.
  var height: Measurement<UnitLength> { .init(value: Double(rawValue), unit: .feet) }
}

enum Visibility: Float, CaseIterable, Defaults.Serializable {
  case threeSM = 3.0
  case oneSM = 1.0
  case oneHalfSM = 0.5
  case oneQuarterSM = 0.25

  /// The visibility as pilots write it, pairing with a literal “SM” at each use site.
  ///
  /// This is the one quantity spelled out rather than run through a measurement format
  /// style: approach minimums are written as vulgar fractions, which no number format style
  /// produces, and Foundation abbreviates statute miles as “mi” rather than the “SM” an
  /// aviation reader expects.
  var stringValue: String {
    switch self {
      case .threeSM: return "3"
      case .oneSM: return "1"
      case .oneHalfSM: return "½"
      case .oneQuarterSM: return "¼"
    }
  }
}
