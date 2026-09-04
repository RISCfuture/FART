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

    @Test
    func `categorizes VFR risk under 100 hours`() {
      let rating = Rating.VFR
      let hours = Hours.under100

      // Low risk (0-14)
      #expect(RiskCategorizer.categorizeRisk(score: 0, rating: rating, hours: hours) == .low)
      #expect(RiskCategorizer.categorizeRisk(score: 14, rating: rating, hours: hours) == .low)

      // Moderate risk (15-20)
      #expect(RiskCategorizer.categorizeRisk(score: 15, rating: rating, hours: hours) == .moderate)
      #expect(RiskCategorizer.categorizeRisk(score: 20, rating: rating, hours: hours) == .moderate)

      // High risk (>20)
      #expect(RiskCategorizer.categorizeRisk(score: 21, rating: rating, hours: hours) == .high)
      #expect(RiskCategorizer.categorizeRisk(score: 30, rating: rating, hours: hours) == .high)
    }

    @Test
    func `categorizes VFR risk over 100 hours`() {
      let rating = Rating.VFR
      let hours = Hours.over100

      // Low risk (0-20)
      #expect(RiskCategorizer.categorizeRisk(score: 0, rating: rating, hours: hours) == .low)
      #expect(RiskCategorizer.categorizeRisk(score: 20, rating: rating, hours: hours) == .low)

      // Moderate risk (21-25)
      #expect(RiskCategorizer.categorizeRisk(score: 21, rating: rating, hours: hours) == .moderate)
      #expect(RiskCategorizer.categorizeRisk(score: 25, rating: rating, hours: hours) == .moderate)

      // High risk (>25)
      #expect(RiskCategorizer.categorizeRisk(score: 26, rating: rating, hours: hours) == .high)
      #expect(RiskCategorizer.categorizeRisk(score: 35, rating: rating, hours: hours) == .high)
    }

    @Test
    func `categorizes IFR risk under 100 hours`() {
      let rating = Rating.IFR
      let hours = Hours.under100

      // Low risk (0-20)
      #expect(RiskCategorizer.categorizeRisk(score: 0, rating: rating, hours: hours) == .low)
      #expect(RiskCategorizer.categorizeRisk(score: 20, rating: rating, hours: hours) == .low)

      // Moderate risk (21-30)
      #expect(RiskCategorizer.categorizeRisk(score: 21, rating: rating, hours: hours) == .moderate)
      #expect(RiskCategorizer.categorizeRisk(score: 30, rating: rating, hours: hours) == .moderate)

      // High risk (>30)
      #expect(RiskCategorizer.categorizeRisk(score: 31, rating: rating, hours: hours) == .high)
      #expect(RiskCategorizer.categorizeRisk(score: 40, rating: rating, hours: hours) == .high)
    }

    @Test
    func `categorizes IFR risk over 100 hours`() {
      let rating = Rating.IFR
      let hours = Hours.over100

      // Low risk (0-30)
      #expect(RiskCategorizer.categorizeRisk(score: 0, rating: rating, hours: hours) == .low)
      #expect(RiskCategorizer.categorizeRisk(score: 30, rating: rating, hours: hours) == .low)

      // Moderate risk (31-35)
      #expect(RiskCategorizer.categorizeRisk(score: 31, rating: rating, hours: hours) == .moderate)
      #expect(RiskCategorizer.categorizeRisk(score: 35, rating: rating, hours: hours) == .moderate)

      // High risk (>35)
      #expect(RiskCategorizer.categorizeRisk(score: 36, rating: rating, hours: hours) == .high)
      #expect(RiskCategorizer.categorizeRisk(score: 45, rating: rating, hours: hours) == .high)
    }
  }

  @Suite
  struct `Score Value Configuration Tests` {

    @Test
    func `configures every score value`() {
      // Verify all score values match expected values
      #expect(FARTScoreCalculator.ScoreValues.lessThan50InType == 5)
      #expect(FARTScoreCalculator.ScoreValues.lessThan15InLast90 == 3)
      #expect(FARTScoreCalculator.ScoreValues.afterWork == 4)
      #expect(FARTScoreCalculator.ScoreValues.lessThan8HrSleep == 5)
      #expect(FARTScoreCalculator.ScoreValues.dualInLast90 == -1)
      #expect(FARTScoreCalculator.ScoreValues.wingsInLast6Mo == -3)
      #expect(FARTScoreCalculator.ScoreValues.ifrCurrent == -3)

      #expect(FARTScoreCalculator.ScoreValues.night == 5)
      #expect(FARTScoreCalculator.ScoreValues.strongWinds == 4)
      #expect(FARTScoreCalculator.ScoreValues.strongCrosswinds == 4)
      #expect(FARTScoreCalculator.ScoreValues.mountainous == 4)

      #expect(FARTScoreCalculator.ScoreValues.nontowered == 5)
      #expect(FARTScoreCalculator.ScoreValues.shortRunway == 3)
      #expect(FARTScoreCalculator.ScoreValues.wetOrSoftFieldRunway == 3)
      #expect(FARTScoreCalculator.ScoreValues.runwayObstacles == 3)

      #expect(FARTScoreCalculator.ScoreValues.vfrCeilingUnder3000 == 2)
      #expect(FARTScoreCalculator.ScoreValues.vfrVisibilityUnder5 == 2)
      #expect(FARTScoreCalculator.ScoreValues.noDestWx == 4)
      #expect(FARTScoreCalculator.ScoreValues.vfrFlightPlan == -2)
      #expect(FARTScoreCalculator.ScoreValues.vfrFlightFollowing == -3)

      #expect(FARTScoreCalculator.ScoreValues.ifrLowCeiling == 2)
      #expect(FARTScoreCalculator.ScoreValues.ifrLowVisibility == 2)
    }

    @Test
    func `configures the approach type scores`() {
      #expect(FARTScoreCalculator.ScoreValues.approachTypeScore(.precision) == -2)
      #expect(FARTScoreCalculator.ScoreValues.approachTypeScore(.nonprecision) == 3)
      #expect(FARTScoreCalculator.ScoreValues.approachTypeScore(.none) == 4)
      #expect(FARTScoreCalculator.ScoreValues.approachTypeScore(.circling) == 7)
      #expect(FARTScoreCalculator.ScoreValues.approachTypeScore(.notApplicable) == 0)
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
