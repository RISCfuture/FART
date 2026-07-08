#if os(macOS)
  import Defaults
  import Foundation

  /// A point-in-time snapshot of a completed FRAT, structured for printing or PDF export.
  ///
  /// The report enumerates only the risk factors the pilot actually answered “yes” to,
  /// grouped by the same sections used in the questionnaire, so a printed record shows what
  /// drove the score rather than the full checklist.
  struct FRATReport {
    private typealias Scores = FARTScoreCalculator.ScoreValues

    let generatedAt: Date
    let score: Int
    let risk: Risk
    let categories: [Category]

    @MainActor
    init(questionnaire: Questionnaire, generatedAt: Date) {
      self.generatedAt = generatedAt
      score = questionnaire.score
      risk = questionnaire.risk
      categories = Self.activeCategories(for: questionnaire)
    }

    @MainActor
    private static func activeCategories(for questionnaire: Questionnaire) -> [Category] {
      let windsString = windSpeedFormatter.string(from: .init(value: Defaults[.strongWinds]))!
      let crosswindsString = windSpeedFormatter.string(
        from: .init(value: Defaults[.strongCrosswinds])
      )!
      let runwayString = runwayLengthFormatter.string(from: .init(value: Defaults[.shortRunway]))!

      let groups: [(name: String, factors: [Factor?])] = [
        (
          String(localized: "Pilot"),
          [
            factor(
              questionnaire.lessThan50InType,
              String(localized: "Fewer than 50 hours in aircraft or avionics type"),
              Scores.lessThan50InType
            ),
            factor(
              questionnaire.lessThan15InLast90,
              String(localized: "Fewer than 15 hours in last 90 days"),
              Scores.lessThan15InLast90
            ),
            factor(
              questionnaire.afterWork,
              String(localized: "Flight will occur after work"),
              Scores.afterWork
            ),
            factor(
              questionnaire.lessThan8HrSleep,
              String(localized: "Fewer than 8 hours’ sleep prior to flight"),
              Scores.lessThan8HrSleep
            ),
            factor(
              questionnaire.dualInLast90,
              String(localized: "Dual instruction received in last 90 days"),
              Scores.dualInLast90
            ),
            factor(
              questionnaire.wingsInLast6Mo,
              String(localized: "WINGS phase completion in last 6 months"),
              Scores.wingsInLast6Mo
            ),
            factor(
              questionnaire.IFRCurrent,
              String(localized: "Instrument rated, current, and proficient"),
              Scores.ifrCurrent
            )
          ]
        ),
        (
          String(localized: "Flight Conditions"),
          [
            factor(questionnaire.night, String(localized: "Twilight or night"), Scores.night),
            factor(
              questionnaire.strongWinds,
              String(localized: "Surface wind greater than \(windsString) knots"),
              Scores.strongWinds
            ),
            factor(
              questionnaire.strongCrosswinds,
              String(localized: "Crosswind greater than \(crosswindsString) knots"),
              Scores.strongCrosswinds
            ),
            factor(
              questionnaire.mountainous,
              String(localized: "Mountainous terrain"),
              Scores.mountainous
            )
          ]
        ),
        (
          String(localized: "Departure and Destination Airport"),
          [
            factor(
              questionnaire.nontowered,
              String(localized: "Nontowered airport (or tower closed)"),
              Scores.nontowered
            ),
            factor(
              questionnaire.shortRunway,
              String(localized: "Runway length less than \(runwayString)′"),
              Scores.shortRunway
            ),
            factor(
              questionnaire.wetOrSoftFieldRunway,
              String(localized: "Wet or soft-field runway"),
              Scores.wetOrSoftFieldRunway
            ),
            factor(
              questionnaire.runwayObstacles,
              String(localized: "Obstacles on departure/approach"),
              Scores.runwayObstacles
            )
          ]
        ),
        (String(localized: "Weather"), weatherFactors(for: questionnaire))
      ]

      return groups.compactMap { group in
        let active = group.factors.compactMap(\.self)
        return active.isEmpty ? nil : Category(name: group.name, factors: active)
      }
    }

    @MainActor
    private static func weatherFactors(for questionnaire: Questionnaire) -> [Factor?] {
      let ceilingString = ceilingFormatter.string(
        from: .init(value: Defaults[.lowCeiling].rawValue)
      )!
      let visibilityString = Defaults[.lowVisibility].stringValue

      var factors: [Factor?] = [
        factor(
          questionnaire.vfrCeilingUnder3000,
          String(localized: "Ceiling less than 3,000′ AGL"),
          Scores.vfrCeilingUnder3000
        ),
        factor(
          questionnaire.vfrVisibilityUnder5,
          String(localized: "Visibility less than 5 SM"),
          Scores.vfrVisibilityUnder5
        ),
        factor(
          questionnaire.vfrFlightPlan,
          String(localized: "Flight plan filed and activated"),
          Scores.vfrFlightPlan
        ),
        factor(
          questionnaire.vfrFlightFollowing,
          String(localized: "ATC flight following used"),
          Scores.vfrFlightFollowing
        ),
        factor(
          questionnaire.ifrLowCeiling,
          String(localized: "Ceiling less than \(ceilingString)′ AGL"),
          Scores.ifrLowCeiling
        ),
        factor(
          questionnaire.ifrLowVisibility,
          String(localized: "Visibility less than \(visibilityString) SM"),
          Scores.ifrLowVisibility
        ),
        factor(
          questionnaire.noDestWx,
          String(localized: "No weather reporting at destination"),
          Scores.noDestWx
        )
      ]

      if questionnaire.ifrApproachType != .notApplicable {
        factors.append(
          Factor(
            label: approachLabel(questionnaire.ifrApproachType),
            points: Scores.approachTypeScore(questionnaire.ifrApproachType)
          )
        )
      }

      return factors
    }

    private static func approachLabel(_ type: ApproachType) -> String {
      switch type {
        case .precision: String(localized: "Best available approach: precision")
        case .nonprecision: String(localized: "Best available approach: non-precision")
        case .circling: String(localized: "Best available approach: circling only")
        case .none: String(localized: "Best available approach: none")
        case .notApplicable: ""
      }
    }

    private static func factor(_ isActive: Bool, _ label: String, _ points: Int) -> Factor? {
      isActive ? Factor(label: label, points: points) : nil
    }

    /// A single risk factor that contributed to the score.
    struct Factor: Identifiable {
      let label: String
      let points: Int

      var id: String { label }
    }

    /// A group of related factors, mirroring the questionnaire's sections.
    struct Category: Identifiable {
      let name: String
      let factors: [Factor]

      var id: String { name }
    }
  }
#endif
