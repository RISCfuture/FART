import Foundation
import MeasurementKitDefaults
import Testing

@testable import Flight_Assessment_of_Risk_Tool

// swiftlint:disable convenience_type
@Suite("FART Score and Risk Tests")
struct FARTUnitTests {

  @Suite("FARTScoreCalculator Tests")
  struct CalculatorTests {

    @Test("Empty data returns zero score")
    func emptyDataReturnsZero() {
      let data = QuestionnaireData()
      let score = FARTScoreCalculator.calculateScore(from: data)
      #expect(score == 0)
    }

    @Test("Single risk factor calculates correctly")
    func singleRiskFactor() {
      var data = QuestionnaireData()
      data.lessThan50InType = true
      let score = FARTScoreCalculator.calculateScore(from: data)
      #expect(score == 5)
    }

    @Test("Multiple risk factors sum correctly")
    func multipleRiskFactors() {
      var data = QuestionnaireData()
      data.lessThan50InType = true  // +5
      data.night = true  // +5
      data.strongWinds = true  // +4
      let score = FARTScoreCalculator.calculateScore(from: data)
      #expect(score == 14)
    }

    @Test("Mitigating factors reduce score")
    func mitigatingFactors() {
      var data = QuestionnaireData()
      data.lessThan50InType = true  // +5
      data.night = true  // +5
      data.dualInLast90 = true  // -1
      data.ifrCurrent = true  // -3
      let score = FARTScoreCalculator.calculateScore(from: data)
      #expect(score == 6)
    }

    @Test("Score cannot go negative")
    func scoreCannotGoNegative() {
      var data = QuestionnaireData()
      data.dualInLast90 = true  // -1
      data.wingsInLast6Mo = true  // -3
      data.ifrCurrent = true  // -3
      data.vfrFlightPlan = true  // -2
      data.vfrFlightFollowing = true  // -3
      let score = FARTScoreCalculator.calculateScore(from: data)
      #expect(score == 0)
    }

    @Test("Approach type affects score")
    func approachTypeScore() {
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

    @Test("Maximum realistic score")
    func maximumRealisticScore() {
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

  @Suite("RiskCategorizer Tests")
  struct CategorizerTests {

    @Test("VFR under 100 hours risk thresholds")
    func vfrUnder100Categories() {
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

    @Test("VFR over 100 hours risk thresholds")
    func vfrOver100Categories() {
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

    @Test("IFR under 100 hours risk thresholds")
    func ifrUnder100Categories() {
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

    @Test("IFR over 100 hours risk thresholds")
    func ifrOver100Categories() {
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

  @Suite("Score Value Configuration Tests")
  struct ScoreValueTests {

    @Test("All score values are correctly configured")
    func verifyScoreValues() {
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

    @Test("Approach type scores are correct")
    func verifyApproachScores() {
      #expect(FARTScoreCalculator.ScoreValues.approachTypeScore(.precision) == -2)
      #expect(FARTScoreCalculator.ScoreValues.approachTypeScore(.nonprecision) == 3)
      #expect(FARTScoreCalculator.ScoreValues.approachTypeScore(.none) == 4)
      #expect(FARTScoreCalculator.ScoreValues.approachTypeScore(.circling) == 7)
      #expect(FARTScoreCalculator.ScoreValues.approachTypeScore(.notApplicable) == 0)
    }
  }

  @Suite("Answer Restoration Tests")
  struct RestorationTests {

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
    @Test("Each answer restores onto its own property", arguments: booleanAnswers)
    func booleanAnswerRestores(
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
    @Test(
      "The approach type restores",
      arguments: [ApproachType.precision, .nonprecision, .none, .circling]
    )
    func approachTypeRestores(approachType: ApproachType) throws {
      var stored = QuestionnaireData()
      stored.ifrApproachType = approachType
      let encoded = try JSONEncoder().encode(stored)

      let questionnaire = Questionnaire()
      questionnaire.restoreAnswers(from: encoded)

      #expect(questionnaire.answers == stored)
    }

    @MainActor
    @Test("Answers are left alone when the scene has none stored")
    func missingAnswersLeaveQuestionnaireUntouched() {
      let questionnaire = Questionnaire()
      questionnaire.night = true

      questionnaire.restoreAnswers(from: nil)

      #expect(questionnaire.answers.night)
    }
  }

  @Suite("Threshold Storage Tests")
  struct ThresholdStorageTests {

    /// Thresholds are stored as bare numbers, so preferences written before they became
    /// measurements have to keep reading back as the same quantity.
    @Test("A threshold stored as a bare number reads back in its canonical unit")
    func bareNumberReadsBack() throws {
      let runway = try #require(MeasurementBridge<UnitLength>().deserialize(3000))
      #expect(runway == Measurement(value: 3000, unit: .feet))

      let wind = try #require(MeasurementBridge<UnitSpeed>().deserialize(15))
      #expect(wind == Measurement(value: 15, unit: .knots))
    }

    /// Storing the raw value without converting first would write, say, a count of meters
    /// under a key everything else reads as feet, so the unit has to be normalized on the
    /// way down rather than assumed.
    @Test("A threshold in another unit is normalized before it is stored")
    func otherUnitsNormalizeOnWrite() throws {
      let runway = MeasurementBridge<UnitLength>()
        .serialize(Measurement(value: 1, unit: .miles))
      #expect(try #require(runway).isApproximately(5280))

      let wind = MeasurementBridge<UnitSpeed>()
        .serialize(Measurement(value: 1, unit: .milesPerHour))
      #expect(try #require(wind).isApproximately(0.868976))
    }
  }
}
// swiftlint:enable convenience_type

extension Double {
  /// Compares against `other` loosely enough to absorb the rounding of a unit conversion.
  fileprivate func isApproximately(_ other: Self) -> Bool { (self - other).magnitude < 0.001 }
}
