import Foundation
import MeasurementKitDefaults
import PDFKit
import Testing

@testable import Flight_Assessment_of_Risk_Tool

// swiftlint:disable convenience_type
@Suite
struct `FART Score and Risk Tests` {

  @Suite
  struct `FARTScoreCalculator Tests` {

    @Test
    func `empty data scores zero`() {
      let data = QuestionnaireData()
      let score = FARTScoreCalculator.calculateScore(from: data)
      #expect(score == 0)
    }

    @Test
    func `scores a single risk factor`() {
      var data = QuestionnaireData()
      data.lessThan50InType = true
      let score = FARTScoreCalculator.calculateScore(from: data)
      #expect(score == 5)
    }

    @Test
    func `sums multiple risk factors`() {
      var data = QuestionnaireData()
      data.lessThan50InType = true  // +5
      data.night = true  // +5
      data.strongWinds = true  // +4
      let score = FARTScoreCalculator.calculateScore(from: data)
      #expect(score == 14)
    }

    @Test
    func `subtracts mitigating factors`() {
      var data = QuestionnaireData()
      data.lessThan50InType = true  // +5
      data.night = true  // +5
      data.dualInLast90 = true  // -1
      data.ifrCurrent = true  // -3
      let score = FARTScoreCalculator.calculateScore(from: data)
      #expect(score == 6)
    }

    @Test
    func `never scores below zero`() {
      var data = QuestionnaireData()
      data.dualInLast90 = true  // -1
      data.wingsInLast6Mo = true  // -3
      data.ifrCurrent = true  // -3
      data.vfrFlightPlan = true  // -2
      data.vfrFlightFollowing = true  // -3
      let score = FARTScoreCalculator.calculateScore(from: data)
      #expect(score == 0)
    }

    @Test
    func `scores each approach type`() {
      var data = QuestionnaireData()
      data.ifrApproachType = .circling
      var score = FARTScoreCalculator.calculateScore(from: data)
      #expect(score == 7)

      data.ifrApproachType = .precision
      score = FARTScoreCalculator.calculateScore(from: data)
      #expect(score == 0)  // -2 becomes 0 due to max(0, score)

      data.lessThan50InType = true  // +5
      data.ifrApproachType = .nonprecision  // +3
      score = FARTScoreCalculator.calculateScore(from: data)
      #expect(score == 8)
    }

    @Test
    func `scores every factor answered at once`() {
      var data = QuestionnaireData()
      // Pilot factors
      data.lessThan50InType = true  // +5
      data.lessThan15InLast90 = true  // +3
      data.afterWork = true  // +4
      data.lessThan8HrSleep = true  // +5

      // Flight Environment
      data.night = true  // +5
      data.strongWinds = true  // +4
      data.strongCrosswinds = true  // +4
      data.mountainous = true  // +4

      // Airport
      data.nontowered = true  // +5
      data.shortRunway = true  // +3
      data.wetOrSoftFieldRunway = true  // +3
      data.runwayObstacles = true  // +3

      // Weather
      data.vfrCeilingUnder3000 = true  // +2
      data.vfrVisibilityUnder5 = true  // +2
      data.noDestWx = true  // +4
      data.ifrLowCeiling = true  // +2
      data.ifrLowVisibility = true  // +2
      data.ifrApproachType = .circling  // +7

      let score = FARTScoreCalculator.calculateScore(from: data)
      #expect(score == 67)
    }
  }

  @Suite
  struct `RiskCategorizer Tests` {

    /// Both edges of every band, for each rating and hours combination: the highest score that
    /// stays in a band and the lowest that leaves it, which is where a wrong comparison shows.
    /// The thresholds are written out rather than read from `RiskThresholds`, so that moving a
    /// threshold fails this suite instead of silently moving the expectation with it.
    static let categorizations: [Categorization] = [
      .init(rating: .VFR, hours: .under100, score: 14, risk: .low),
      .init(rating: .VFR, hours: .under100, score: 15, risk: .moderate),
      .init(rating: .VFR, hours: .under100, score: 20, risk: .moderate),
      .init(rating: .VFR, hours: .under100, score: 21, risk: .high),

      .init(rating: .VFR, hours: .over100, score: 20, risk: .low),
      .init(rating: .VFR, hours: .over100, score: 21, risk: .moderate),
      .init(rating: .VFR, hours: .over100, score: 25, risk: .moderate),
      .init(rating: .VFR, hours: .over100, score: 26, risk: .high),

      .init(rating: .IFR, hours: .under100, score: 20, risk: .low),
      .init(rating: .IFR, hours: .under100, score: 21, risk: .moderate),
      .init(rating: .IFR, hours: .under100, score: 30, risk: .moderate),
      .init(rating: .IFR, hours: .under100, score: 31, risk: .high),

      .init(rating: .IFR, hours: .over100, score: 30, risk: .low),
      .init(rating: .IFR, hours: .over100, score: 31, risk: .moderate),
      .init(rating: .IFR, hours: .over100, score: 35, risk: .moderate),
      .init(rating: .IFR, hours: .over100, score: 36, risk: .high)
    ]

    @Test(arguments: categorizations)
    func `categorizes a score against the pilot's thresholds`(_ expected: Categorization) {
      let risk = RiskCategorizer.categorizeRisk(
        score: expected.score,
        rating: expected.rating,
        hours: expected.hours
      )

      #expect(risk == expected.risk)
    }

    /// A pilot with no risk factors is low risk whoever they are, which no band edge covers.
    @Test(arguments: [Rating.VFR, .IFR], [Hours.under100, .over100])
    func `categorizes a clean questionnaire as low risk`(rating: Rating, hours: Hours) {
      #expect(RiskCategorizer.categorizeRisk(score: 0, rating: rating, hours: hours) == .low)
    }

    /// A score, the pilot it belongs to, and the band it should fall in.
    struct Categorization: Sendable, CustomTestStringConvertible {
      let rating: Rating
      let hours: Hours
      let score: Int
      let risk: Risk

      var testDescription: String {
        "\(rating.rawValue) \(hours.rawValue), \(score) points: \(risk)"
      }
    }
  }

  @Suite
  struct `Answer Restoration Tests` {

    /// Every boolean answer, so restoring one at a time proves each lands back on the
    /// property it came from rather than on a neighbour.
    static let booleanAnswers: [any WritableKeyPath<QuestionnaireData, Bool> & Sendable] = [
      \.lessThan50InType, \.lessThan15InLast90, \.afterWork, \.lessThan8HrSleep,
      \.dualInLast90, \.wingsInLast6Mo, \.ifrCurrent,
      \.night, \.strongWinds, \.strongCrosswinds, \.mountainous,
      \.nontowered, \.shortRunway, \.wetOrSoftFieldRunway, \.runwayObstacles,
      \.vfrCeilingUnder3000, \.vfrVisibilityUnder5, \.noDestWx, \.vfrFlightPlan,
      \.vfrFlightFollowing, \.ifrLowCeiling, \.ifrLowVisibility
    ]

    @MainActor
    @Test(arguments: booleanAnswers)
    func `restores each answer onto its own property`(
      answer: any WritableKeyPath<QuestionnaireData, Bool> & Sendable
    ) throws {
      var stored = QuestionnaireData()
      stored[keyPath: answer] = true
      let encoded = try JSONEncoder().encode(stored)

      let questionnaire = Questionnaire()
      questionnaire.restoreAnswers(from: encoded)

      #expect(questionnaire.answers == stored)
    }

    @MainActor
    @Test(arguments: [ApproachType.precision, .nonprecision, .none, .circling])
    func `restores the approach type`(approachType: ApproachType) throws {
      var stored = QuestionnaireData()
      stored.ifrApproachType = approachType
      let encoded = try JSONEncoder().encode(stored)

      let questionnaire = Questionnaire()
      questionnaire.restoreAnswers(from: encoded)

      #expect(questionnaire.answers == stored)
    }

    @MainActor
    @Test
    func `leaves the answers alone when the scene has none stored`() {
      let questionnaire = Questionnaire()
      questionnaire.night = true

      questionnaire.restoreAnswers(from: nil)

      #expect(questionnaire.answers.night)
    }
  }

  @Suite
  struct `Threshold Storage Tests` {

    /// Thresholds are stored as bare numbers, so preferences written before they became
    /// measurements have to keep reading back as the same quantity.
    @Test
    func `reads a bare threshold back in its canonical unit`() throws {
      let runway = try #require(MeasurementBridge<UnitLength>().deserialize(3000))
      #expect(runway == Measurement(value: 3000, unit: .feet))

      let wind = try #require(MeasurementBridge<UnitSpeed>().deserialize(15))
      #expect(wind == Measurement(value: 15, unit: .knots))
    }

    /// Storing the raw value without converting first would write, say, a count of meters
    /// under a key everything else reads as feet, so the unit has to be normalized on the
    /// way down rather than assumed.
    @Test
    func `normalizes a threshold in another unit before storing it`() throws {
      let runway = MeasurementBridge<UnitLength>()
        .serialize(Measurement(value: 1, unit: .miles))
      #expect(try #require(runway).isApproximately(5280))

      let wind = MeasurementBridge<UnitSpeed>()
        .serialize(Measurement(value: 1, unit: .milesPerHour))
      #expect(try #require(wind).isApproximately(0.868976))
    }
  }

  @Suite
  @MainActor
  struct `FRAT Report Sharing Tests` {

    @Test
    func `exports a one-page PDF named as the report suggests`() throws {
      let report = FRATReport(questionnaire: Questionnaire(), generatedAt: .now)
      let url = try report.writeTemporaryPDF()
      defer { removeExport(at: url) }
      let document = try #require(PDFDocument(url: url))

      #expect(url.lastPathComponent == report.suggestedFileName)
      #expect(document.pageCount == 1)
    }

    /// Two reports assessed the same day share a suggested file name, so only the enclosing
    /// directory keeps a second export from overwriting a file the system is still copying.
    @Test
    func `gives each export its own directory`() throws {
      let questionnaire = Questionnaire()
      let generatedAt = Date.now
      let first = try FRATReport(questionnaire: questionnaire, generatedAt: generatedAt)
        .writeTemporaryPDF()
      defer { removeExport(at: first) }
      let second = try FRATReport(questionnaire: questionnaire, generatedAt: generatedAt)
        .writeTemporaryPDF()
      defer { removeExport(at: second) }

      #expect(first.lastPathComponent == second.lastPathComponent)
      #expect(first != second)
      #expect(FileManager.default.fileExists(atPath: first.path(percentEncoded: false)))
    }

    /// Each export gets a directory of its own, so cleaning up after one means removing the
    /// directory that holds it rather than just the file.
    private func removeExport(at url: URL) {
      try? FileManager.default.removeItem(at: url.deletingLastPathComponent())
    }
  }
}
// swiftlint:enable convenience_type

extension Double {
  /// Compares against `other` loosely enough to absorb the rounding of a unit conversion.
  fileprivate func isApproximately(_ other: Self) -> Bool { (self - other).magnitude < 0.001 }
}
