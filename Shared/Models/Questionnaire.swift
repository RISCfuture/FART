import Defaults
import Foundation
import Observation

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

  var lessThan50InType = false
  var lessThan15InLast90 = false
  var afterWork = false
  var lessThan8HrSleep = false
  var dualInLast90 = false
  var wingsInLast6Mo = false
  var IFRCurrent = false

  var night = false
  var strongWinds = false
  var strongCrosswinds = false
  var mountainous = false

  var nontowered = false
  var shortRunway = false
  var wetOrSoftFieldRunway = false
  var runwayObstacles = false

  var vfrCeilingUnder3000 = false
  var vfrVisibilityUnder5 = false
  var noDestWx = false
  var vfrFlightPlan = false
  var vfrFlightFollowing = false
  var ifrLowCeiling = false
  var ifrLowVisibility = false
  var ifrApproachType = ApproachType.notApplicable

  // MARK: Outputs

  var score = 0
  var risk = Risk.low

  private var currentData: QuestionnaireData {
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

  init() {
    observeInputs()
    observeProfileDefaults()
  }

  // periphery:ignore - invoked only by the macOS "Reset FRAT" menu command
  /// Clears every answer back to its default, returning the score to baseline. The
  /// `Observations` pipeline coalesces these writes into a single recompute.
  func reset() {
    lessThan50InType = false
    lessThan15InLast90 = false
    afterWork = false
    lessThan8HrSleep = false
    dualInLast90 = false
    wingsInLast6Mo = false
    IFRCurrent = false

    night = false
    strongWinds = false
    strongCrosswinds = false
    mountainous = false

    nontowered = false
    shortRunway = false
    wetOrSoftFieldRunway = false
    runwayObstacles = false

    vfrCeilingUnder3000 = false
    vfrVisibilityUnder5 = false
    noDestWx = false
    vfrFlightPlan = false
    vfrFlightFollowing = false
    ifrLowCeiling = false
    ifrLowVisibility = false
    ifrApproachType = .notApplicable
  }

  /// Recomputes the score and risk whenever any questionnaire answer changes.
  ///
  /// `Observations` coalesces synchronous mutations into a single emission, so a burst of
  /// related answer changes (e.g. switching between VFR and IFR) recomputes only once.
  private func observeInputs() {
    Task {
      for await data in Observations({ self.currentData }) {
        recompute(from: data)
      }
    }
  }

  /// Recomputes when the pilot profile (rating / hours) changes, since those feed the risk
  /// thresholds but live in `Defaults` rather than on this model.
  private func observeProfileDefaults() {
    Task {
      for await _ in Defaults.updates([.hours, .rating]) {
        recompute(from: currentData)
      }
    }
  }

  private func recompute(from data: QuestionnaireData) {
    score = FARTScoreCalculator.calculateScore(from: data)
    risk = RiskCategorizer.categorizeRisk(
      score: score,
      rating: Defaults[.rating],
      hours: Defaults[.hours]
    )
  }
}
