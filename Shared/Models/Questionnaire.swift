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
  private var updatesPaused = false

  var lessThan50InType = false {
    didSet { scheduleUpdate() }
  }
  var lessThan15InLast90 = false {
    didSet { scheduleUpdate() }
  }
  var afterWork = false {
    didSet { scheduleUpdate() }
  }
  var lessThan8HrSleep = false {
    didSet { scheduleUpdate() }
  }
  var dualInLast90 = false {
    didSet { scheduleUpdate() }
  }
  var wingsInLast6Mo = false {
    didSet { scheduleUpdate() }
  }
  var IFRCurrent = false {
    didSet { scheduleUpdate() }
  }

  var night = false {
    didSet { scheduleUpdate() }
  }
  var strongWinds = false {
    didSet { scheduleUpdate() }
  }
  var strongCrosswinds = false {
    didSet { scheduleUpdate() }
  }
  var mountainous = false {
    didSet { scheduleUpdate() }
  }

  var nontowered = false {
    didSet { scheduleUpdate() }
  }
  var shortRunway = false {
    didSet { scheduleUpdate() }
  }
  var wetOrSoftFieldRunway = false {
    didSet { scheduleUpdate() }
  }
  var runwayObstacles = false {
    didSet { scheduleUpdate() }
  }

  var vfrCeilingUnder3000 = false {
    didSet { scheduleUpdate() }
  }
  var vfrVisibilityUnder5 = false {
    didSet { scheduleUpdate() }
  }
  var noDestWx = false {
    didSet { scheduleUpdate() }
  }
  var vfrFlightPlan = false {
    didSet { scheduleUpdate() }
  }
  var vfrFlightFollowing = false {
    didSet { scheduleUpdate() }
  }
  var ifrLowCeiling = false {
    didSet { scheduleUpdate() }
  }
  var ifrLowVisibility = false {
    didSet { scheduleUpdate() }
  }
  var ifrApproachType = ApproachType.notApplicable {
    didSet { scheduleUpdate() }
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

  private func scheduleUpdate() {
    guard !updatesPaused else { return }
    update()
  }

  func batchUpdates(_ block: () -> Void) {
    updatesPaused = true
    block()
    updatesPaused = false
    update()
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
