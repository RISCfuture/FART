import Testing

@testable import Flight_Assessment_of_Risk_Tool

// swiftlint:disable convenience_type
@Suite("FART Score and Risk Tests")
struct FARTUnitTests {

  @Suite("BoolScorer Tests")
  struct BoolScorerTests {

    @Test("BoolScorer returns correct value when true")
    func scorerReturnsValueWhenTrue() {
      let scorer = BoolScorer(5)
      #expect(scorer.score(true) == 5)
    }

    @Test("BoolScorer returns 0 when false")
    func scorerReturnsZeroWhenFalse() {
      let scorer = BoolScorer(5)
      #expect(scorer.score(false) == 0)
    }

    @Test("BoolScorer handles negative values")
    func scorerHandlesNegativeValues() {
      let scorer = BoolScorer(-3)
      #expect(scorer.score(true) == -3)
      #expect(scorer.score(false) == 0)
    }
  }

  @Suite("ApproachScorer Tests")
  struct ApproachScorerTests {

    @Test("ApproachScorer returns correct scores")
    func scoreApproachTypes() {
      let scorer = ApproachScorer()
      #expect(scorer.score(.precision) == -2)
      #expect(scorer.score(.nonprecision) == 3)
      #expect(scorer.score(.none) == 4)
      #expect(scorer.score(.circling) == 7)
      #expect(scorer.score(.notApplicable) == 0)
    }
  }

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

    @Test("Risk boundary edge cases")
    func riskBoundaries() {
      // Test exact boundary values for VFR under 100
      let vfrUnder100 = (Rating.VFR, Hours.under100)
      #expect(
        RiskCategorizer.categorizeRisk(score: 14, rating: vfrUnder100.0, hours: vfrUnder100.1)
          == .low
      )
      #expect(
        RiskCategorizer.categorizeRisk(score: 15, rating: vfrUnder100.0, hours: vfrUnder100.1)
          == .moderate
      )
      #expect(
        RiskCategorizer.categorizeRisk(score: 20, rating: vfrUnder100.0, hours: vfrUnder100.1)
          == .moderate
      )
      #expect(
        RiskCategorizer.categorizeRisk(score: 21, rating: vfrUnder100.0, hours: vfrUnder100.1)
          == .high
      )
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
}
// swiftlint:enable convenience_type
