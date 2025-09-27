import Defaults
import Foundation

enum Risk {
  case low
  case moderate
  case high
}

enum ApproachType: String {
  case precision
  case nonprecision
  case none
  case circling
  case notApplicable  // for VFR flights
}

@MainActor
@Observable
class Questionnaire {
  // MARK: Inputs
  var lessThan50InType = false {
    didSet { update() }
  }
  var lessThan15InLast90 = false {
    didSet { update() }
  }
  var afterWork = false {
    didSet { update() }
  }
  var lessThan8HrSleep = false {
    didSet { update() }
  }
  var dualInLast90 = false {
    didSet { update() }
  }
  var wingsInLast6Mo = false {
    didSet { update() }
  }
  var IFRCurrent = false {
    didSet { update() }
  }

  var night = false {
    didSet { update() }
  }
  var strongWinds = false {
    didSet { update() }
  }
  var strongCrosswinds = false {
    didSet { update() }
  }
  var mountainous = false {
    didSet { update() }
  }

  var nontowered = false {
    didSet { update() }
  }
  var shortRunway = false {
    didSet { update() }
  }
  var wetOrSoftFieldRunway = false {
    didSet { update() }
  }
  var runwayObstacles = false {
    didSet { update() }
  }

  var vfrCeilingUnder3000 = false {
    didSet { update() }
  }
  var vfrVisibilityUnder5 = false {
    didSet { update() }
  }
  var noDestWx = false {
    didSet { update() }
  }
  var vfrFlightPlan = false {
    didSet { update() }
  }
  var vfrFlightFollowing = false {
    didSet { update() }
  }
  var ifrLowCeiling = false {
    didSet { update() }
  }
  var ifrLowVisibility = false {
    didSet { update() }
  }
  var ifrApproachType = ApproachType.notApplicable {
    didSet { update() }
  }

  // MARK: Outputs
  var score = 0
  var risk = Risk.low

  init() {
    Task {
      for await _ in Defaults.updates([.hours, .rating]) {
        update()
      }
    }
  }

  func update() {
    // Create data structure from current state
    let data = createQuestionnaireData()

    // Use pure calculators
    score = FARTScoreCalculator.calculateScore(from: data)
    risk = RiskCategorizer.categorizeRisk(
      score: score,
      rating: Defaults[.rating],
      hours: Defaults[.hours]
    )
  }

  private func createQuestionnaireData() -> QuestionnaireData {
    QuestionnaireData(
      lessThan50InType: lessThan50InType,
      lessThan15InLast90: lessThan15InLast90,
      afterWork: afterWork,
      lessThan8HrSleep: lessThan8HrSleep,
      dualInLast90: dualInLast90,
      wingsInLast6Mo: wingsInLast6Mo,
      ifrCurrent: IFRCurrent,
      night: night,
      strongWinds: strongWinds,
      strongCrosswinds: strongCrosswinds,
      mountainous: mountainous,
      nontowered: nontowered,
      shortRunway: shortRunway,
      wetOrSoftFieldRunway: wetOrSoftFieldRunway,
      runwayObstacles: runwayObstacles,
      vfrCeilingUnder3000: vfrCeilingUnder3000,
      vfrVisibilityUnder5: vfrVisibilityUnder5,
      noDestWx: noDestWx,
      vfrFlightPlan: vfrFlightPlan,
      vfrFlightFollowing: vfrFlightFollowing,
      ifrLowCeiling: ifrLowCeiling,
      ifrLowVisibility: ifrLowVisibility,
      ifrApproachType: ifrApproachType
    )
  }
}
