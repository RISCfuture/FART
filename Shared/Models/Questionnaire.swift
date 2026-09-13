import Defaults
import Foundation
import Observation

enum Risk {
  case low
  case moderate
  case high
}

/// These raw values are the wire format for a scene's stored answers, so renaming a case
/// would invalidate the answers of every window awaiting restoration.
enum ApproachType: String, Codable {
  case precision
  case nonprecision
  case none
  case circling
  case notApplicable = "not_applicable"  // for VFR flights
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

  /// Every answer as a plain value, for scoring and for scene-storage restoration.
  var answers: QuestionnaireData {
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
  func reset() { apply(QuestionnaireData()) }

  /// Restores answers the scene stored before it was terminated, leaving the questionnaire
  /// untouched when the scene is new or its stored answers no longer decode.
  func restoreAnswers(from stored: Data?) {
    guard let stored,
      let restored = try? JSONDecoder().decode(QuestionnaireData.self, from: stored)
    else { return }

    apply(restored)
  }

  private func apply(_ data: QuestionnaireData) {
    lessThan50InType = data.lessThan50InType
    lessThan15InLast90 = data.lessThan15InLast90
    afterWork = data.afterWork
    lessThan8HrSleep = data.lessThan8HrSleep
    dualInLast90 = data.dualInLast90
    wingsInLast6Mo = data.wingsInLast6Mo
    IFRCurrent = data.ifrCurrent

    night = data.night
    strongWinds = data.strongWinds
    strongCrosswinds = data.strongCrosswinds
    mountainous = data.mountainous

    nontowered = data.nontowered
    shortRunway = data.shortRunway
    wetOrSoftFieldRunway = data.wetOrSoftFieldRunway
    runwayObstacles = data.runwayObstacles

    vfrCeilingUnder3000 = data.vfrCeilingUnder3000
    vfrVisibilityUnder5 = data.vfrVisibilityUnder5
    noDestWx = data.noDestWx
    vfrFlightPlan = data.vfrFlightPlan
    vfrFlightFollowing = data.vfrFlightFollowing
    ifrLowCeiling = data.ifrLowCeiling
    ifrLowVisibility = data.ifrLowVisibility
    ifrApproachType = data.ifrApproachType
  }

  /// Recomputes the score and risk whenever any questionnaire answer changes.
  ///
  /// `Observations` coalesces synchronous mutations into a single emission, so a burst of
  /// related answer changes (e.g. switching between VFR and IFR) recomputes only once.
  private func observeInputs() {
    Task {
      for await data in Observations({ self.answers }) {
        recompute(from: data)
      }
    }
  }

  /// Recomputes when the pilot profile (rating / hours) changes, since those feed the risk
  /// thresholds but live in `Defaults` rather than on this model.
  private func observeProfileDefaults() {
    Task {
      for await _ in Defaults.updates([.hours, .rating]) {
        recompute(from: answers)
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
