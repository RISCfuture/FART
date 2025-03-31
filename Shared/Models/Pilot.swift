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

    var stringValue: String {
        return ceilingFormatter.string(for: rawValue)!
    }
}

enum Visibility: Float, CaseIterable, Defaults.Serializable {
    case threeSM = 3.0
    case oneSM = 1.0
    case oneHalfSM = 0.5
    case oneQuarterSM = 0.25

    var stringValue: String {
        switch self {
            case .threeSM: return "3"
            case .oneSM: return "1"
            case .oneHalfSM: return "½"
            case .oneQuarterSM: return "¼"
        }
    }
}
