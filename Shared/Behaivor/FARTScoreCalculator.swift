import Foundation

/// Pure calculator for FART scores with no external dependencies
struct FARTScoreCalculator {

  /// Score values for each risk factor
  struct ScoreValues {
    // Pilot Experience & Condition
    static let lessThan50InType = 5
    static let lessThan15InLast90 = 3
    static let afterWork = 4
    static let lessThan8HrSleep = 5
    static let dualInLast90 = -1
    static let wingsInLast6Mo = -3
    static let ifrCurrent = -3

    // Flight Environment
    static let night = 5
    static let strongWinds = 4
    static let strongCrosswinds = 4
    static let mountainous = 4

    // Airport Environment
    static let nontowered = 5
    static let shortRunway = 3
    static let wetOrSoftFieldRunway = 3
    static let runwayObstacles = 3

    // VFR Weather
    static let vfrCeilingUnder3000 = 2
    static let vfrVisibilityUnder5 = 2
    static let noDestWx = 4
    static let vfrFlightPlan = -2
    static let vfrFlightFollowing = -3

    // IFR Weather
    static let ifrLowCeiling = 2
    static let ifrLowVisibility = 2

    // Approach Types
    static func approachTypeScore(_ type: ApproachType) -> Int {
      switch type {
        case .precision: return -2
        case .nonprecision: return 3
        case .none: return 4
        case .circling: return 7
        case .notApplicable: return 0
      }
    }
  }

  /// Calculate the total FART score from questionnaire data
  /// - Parameter data: The questionnaire input data
  /// - Returns: The calculated FART score (minimum 0)
  static func calculateScore(from data: QuestionnaireData) -> Int {
    var score = 0

    // Pilot Experience & Condition
    if data.lessThan50InType { score += ScoreValues.lessThan50InType }
    if data.lessThan15InLast90 { score += ScoreValues.lessThan15InLast90 }
    if data.afterWork { score += ScoreValues.afterWork }
    if data.lessThan8HrSleep { score += ScoreValues.lessThan8HrSleep }
    if data.dualInLast90 { score += ScoreValues.dualInLast90 }
    if data.wingsInLast6Mo { score += ScoreValues.wingsInLast6Mo }
    if data.ifrCurrent { score += ScoreValues.ifrCurrent }

    // Flight Environment
    if data.night { score += ScoreValues.night }
    if data.strongWinds { score += ScoreValues.strongWinds }
    if data.strongCrosswinds { score += ScoreValues.strongCrosswinds }
    if data.mountainous { score += ScoreValues.mountainous }

    // Airport Environment
    if data.nontowered { score += ScoreValues.nontowered }
    if data.shortRunway { score += ScoreValues.shortRunway }
    if data.wetOrSoftFieldRunway { score += ScoreValues.wetOrSoftFieldRunway }
    if data.runwayObstacles { score += ScoreValues.runwayObstacles }

    // VFR Weather
    if data.vfrCeilingUnder3000 { score += ScoreValues.vfrCeilingUnder3000 }
    if data.vfrVisibilityUnder5 { score += ScoreValues.vfrVisibilityUnder5 }
    if data.noDestWx { score += ScoreValues.noDestWx }
    if data.vfrFlightPlan { score += ScoreValues.vfrFlightPlan }
    if data.vfrFlightFollowing { score += ScoreValues.vfrFlightFollowing }

    // IFR Weather
    if data.ifrLowCeiling { score += ScoreValues.ifrLowCeiling }
    if data.ifrLowVisibility { score += ScoreValues.ifrLowVisibility }

    // Approach Type
    score += ScoreValues.approachTypeScore(data.ifrApproachType)

    return max(0, score)
  }
}
