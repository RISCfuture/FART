import Foundation

/// Pure data structure containing all questionnaire inputs
/// This struct has no dependencies and can be easily created and tested
struct QuestionnaireData: Equatable {
  // MARK: - Pilot Experience & Condition
  var lessThan50InType: Bool = false
  var lessThan15InLast90: Bool = false
  var afterWork: Bool = false
  var lessThan8HrSleep: Bool = false
  var dualInLast90: Bool = false
  var wingsInLast6Mo: Bool = false
  var ifrCurrent: Bool = false

  // MARK: - Flight Environment
  var night: Bool = false
  var strongWinds: Bool = false
  var strongCrosswinds: Bool = false
  var mountainous: Bool = false

  // MARK: - Airport Environment
  var nontowered: Bool = false
  var shortRunway: Bool = false
  var wetOrSoftFieldRunway: Bool = false
  var runwayObstacles: Bool = false

  // MARK: - VFR Weather
  var vfrCeilingUnder3000: Bool = false
  var vfrVisibilityUnder5: Bool = false
  var noDestWx: Bool = false
  var vfrFlightPlan: Bool = false
  var vfrFlightFollowing: Bool = false

  // MARK: - IFR Weather
  var ifrLowCeiling: Bool = false
  var ifrLowVisibility: Bool = false
  var ifrApproachType: ApproachType = .notApplicable
}
