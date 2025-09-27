import Foundation

/// Pure risk categorizer with no external dependencies
struct RiskCategorizer {

  /// Risk thresholds for different pilot qualifications
  struct RiskThresholds {
    struct VFR {
      struct Under100Hours {
        static let moderateThreshold = 14
        static let highThreshold = 20
      }
      struct Over100Hours {
        static let moderateThreshold = 20
        static let highThreshold = 25
      }
    }

    struct IFR {
      struct Under100Hours {
        static let moderateThreshold = 20
        static let highThreshold = 30
      }
      struct Over100Hours {
        static let moderateThreshold = 30
        static let highThreshold = 35
      }
    }
  }

  /// Categorize risk level based on score, rating, and hours
  /// - Parameters:
  ///   - score: The calculated FART score
  ///   - rating: Pilot's rating (VFR or IFR)
  ///   - hours: Pilot's flight hours category
  /// - Returns: The risk level (low, moderate, or high)
  static func categorizeRisk(score: Int, rating: Rating, hours: Hours) -> Risk {
    switch rating {
      case .VFR:
        switch hours {
          case .under100:
            if score > RiskThresholds.VFR.Under100Hours.highThreshold {
              return .high
            }
            if score > RiskThresholds.VFR.Under100Hours.moderateThreshold {
              return .moderate
            }
            return .low
          case .over100:
            if score > RiskThresholds.VFR.Over100Hours.highThreshold {
              return .high
            }
            if score > RiskThresholds.VFR.Over100Hours.moderateThreshold {
              return .moderate
            }
            return .low
        }
      case .IFR:
        switch hours {
          case .under100:
            if score > RiskThresholds.IFR.Under100Hours.highThreshold {
              return .high
            }
            if score > RiskThresholds.IFR.Under100Hours.moderateThreshold {
              return .moderate
            }
            return .low
          case .over100:
            if score > RiskThresholds.IFR.Over100Hours.highThreshold {
              return .high
            }
            if score > RiskThresholds.IFR.Over100Hours.moderateThreshold {
              return .moderate
            }
            return .low
        }
    }
  }
}
