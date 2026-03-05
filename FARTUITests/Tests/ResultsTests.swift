import XCTest

// swiftlint:disable prefer_nimble
final class ResultsTests: FARTUITestCase {

  @MainActor
  func testDefaultScoreAndRiskLevel() throws {
    let results = tabBar.goToResults()
    results.assertResults(score: "0", riskLevel: "LOW RISK")

    let description = results.riskDescription()
    XCTAssertTrue(
      description.contains("in-the-green"),
      "Expected description to contain 'in-the-green'"
    )
  }

  @MainActor
  func testScoreFloorAtZero() throws {
    // VFR >100h, only negative toggles: -1-3-3 = -7, floored to 0
    tabBar.goToPilotProfile()
      .selectVFR()
      .selectOver100Hours()

    let q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setDualInLast90(true)
      .setWingsInLast6Mo(true)
      .setIFRCurrent(true)

    tabBar.goToResults()
      .assertResults(score: "0", riskLevel: "LOW RISK")
  }

  @MainActor
  func testNegativeAdjustmentsReduceScore() throws {
    // VFR >100h: 5-1-3 = 1
    tabBar.goToPilotProfile()
      .selectVFR()
      .selectOver100Hours()

    let q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setLessThan50InType(true)
      .setDualInLast90(true)
      .setWingsInLast6Mo(true)

    tabBar.goToResults()
      .assertResults(score: "1", riskLevel: "LOW RISK")
  }

  @MainActor
  func testIFRApproachTypesAffectScore() throws {
    // IFR >100h
    tabBar.goToPilotProfile()
      .selectIFR()
      .selectOver100Hours()

    let q = tabBar.goToQuestionnaire()
    q.pilotSection.setLessThan50InType(true)

    // Switch to IFR flight type (approach defaults to none +4)
    q.weatherSection.selectIFR()

    // Select precision(-2): 5 + (-2) = 3
    q.weatherSection.selectApproachPrecision()
    tabBar.goToResults()
      .assertResults(score: "3", riskLevel: "LOW RISK")

    // Select nonprecision(+3): 5 + 3 = 8
    _ = tabBar.goToQuestionnaire()
    q.weatherSection.selectApproachNonprecision()
    tabBar.goToResults()
      .assertResults(score: "8", riskLevel: "LOW RISK")

    // Select circling(+7): 5 + 7 = 12
    _ = tabBar.goToQuestionnaire()
    q.weatherSection.selectApproachCircling()
    tabBar.goToResults()
      .assertResults(score: "12", riskLevel: "LOW RISK")

    // Select none(+4): 5 + 4 = 9
    _ = tabBar.goToQuestionnaire()
    q.weatherSection.selectApproachNone()
    tabBar.goToResults()
      .assertResults(score: "9", riskLevel: "LOW RISK")
  }

  @MainActor
  func testModerateRiskShowsCorrectDescription() throws {
    // VFR >100h, score 21 → MODERATE
    tabBar.goToPilotProfile()
      .selectVFR()
      .selectOver100Hours()

    let q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setLessThan50InType(true)
      .setAfterWork(true)
      .setLessThan8HrSleep(true)
    q.conditionsSection.setNight(true)
    q.weatherSection.setVFRCeilingUnder3000(true)

    let results = tabBar.goToResults()
    results.assertResults(score: "21", riskLevel: "MODERATE RISK")

    let description = results.riskDescription()
    XCTAssertTrue(
      description.contains("yellow"),
      "Expected description to contain 'yellow'"
    )
  }

  @MainActor
  func testHighRiskShowsCorrectDescription() throws {
    // VFR >100h, score 27 → HIGH
    tabBar.goToPilotProfile()
      .selectVFR()
      .selectOver100Hours()

    let q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setLessThan50InType(true)
      .setAfterWork(true)
      .setLessThan8HrSleep(true)
    q.conditionsSection
      .setNight(true)
      .setStrongWinds(true)
      .setStrongCrosswinds(true)

    let results = tabBar.goToResults()
    results.assertResults(score: "27", riskLevel: "HIGH RISK")

    let description = results.riskDescription()
    XCTAssertTrue(
      description.contains("red zone"),
      "Expected description to contain 'red zone'"
    )
  }

  @MainActor
  func testVFRUnder100RiskBoundaries() throws {
    // VFR <100h (defaults): LOW ≤14, MODERATE 15-20, HIGH >20

    // Scenario 1: Score 14 → LOW
    var q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setLessThan50InType(true)
      .setAfterWork(true)
    q.conditionsSection.setNight(true)

    tabBar.goToResults()
      .assertResults(score: "14", riskLevel: "LOW RISK")

    // Scenario 2: Score 15 → MODERATE
    q = tabBar.goToQuestionnaire()
    q.conditionsSection.setNight(false)
    q.pilotSection
      .setLessThan15InLast90(true)
      .setDualInLast90(true)
    q.conditionsSection.setStrongWinds(true)

    // 5+4+3-1+4 = 15
    tabBar.goToResults()
      .assertResults(score: "15", riskLevel: "MODERATE RISK")

    // Scenario 3: Score 21 → HIGH
    q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setDualInLast90(false)
      .setLessThan8HrSleep(true)

    // 5+4+3+4+5 = 21
    tabBar.goToResults()
      .assertResults(score: "21", riskLevel: "HIGH RISK")
  }

  @MainActor
  func testVFROver100RiskBoundaries() throws {
    // VFR >100h: LOW ≤20, MODERATE 21-25, HIGH >25
    tabBar.goToPilotProfile()
      .selectVFR()
      .selectOver100Hours()

    // Scenario 1: Score 20 → LOW
    var q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setLessThan50InType(true)
      .setAfterWork(true)
    q.conditionsSection
      .setNight(true)
      .setStrongWinds(true)
    q.weatherSection.setVFRCeilingUnder3000(true)

    // 5+4+5+4+2 = 20
    tabBar.goToResults()
      .assertResults(score: "20", riskLevel: "LOW RISK")

    // Scenario 2: Score 21 → MODERATE
    q = tabBar.goToQuestionnaire()
    q.weatherSection.setVFRCeilingUnder3000(false)
    q.pilotSection.setLessThan15InLast90(true)

    // 5+4+5+4+3 = 21
    tabBar.goToResults()
      .assertResults(score: "21", riskLevel: "MODERATE RISK")

    // Scenario 3: Score 26 → HIGH
    q = tabBar.goToQuestionnaire()
    q.pilotSection.setLessThan8HrSleep(true)

    // 5+4+5+4+3+5 = 26
    tabBar.goToResults()
      .assertResults(score: "26", riskLevel: "HIGH RISK")
  }

  @MainActor
  func testIFRRiskBoundaries() throws {
    // IFR >100h: LOW ≤30, MODERATE 31-35, HIGH >35
    tabBar.goToPilotProfile()
      .selectIFR()
      .selectOver100Hours()

    // Scenario 1: Score 30 → LOW
    var q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setLessThan50InType(true)
      .setLessThan15InLast90(true)
      .setAfterWork(true)
      .setLessThan8HrSleep(true)
    q.conditionsSection
      .setNight(true)
      .setStrongWinds(true)
    q.weatherSection.selectIFR()

    // 5+3+4+5+5+4+4(none) = 30
    tabBar.goToResults()
      .assertResults(score: "30", riskLevel: "LOW RISK")

    // Scenario 2: Score 31 → MODERATE
    q = tabBar.goToQuestionnaire()
    q.pilotSection.setLessThan15InLast90(false)
    q.conditionsSection.setMountainous(true)

    // 5+4+5+5+4+4+4(none) = 31
    tabBar.goToResults()
      .assertResults(score: "31", riskLevel: "MODERATE RISK")

    // Scenario 3: Score 36 → HIGH
    q = tabBar.goToQuestionnaire()
    q.conditionsSection.setStrongCrosswinds(true)
    q.weatherSection.setIFRLowCeiling(true)
    q.pilotSection.setDualInLast90(true)

    // 5+4+5+5+4+4+4+2-1+4(none) = 36
    tabBar.goToResults()
      .assertResults(score: "36", riskLevel: "HIGH RISK")
  }
}
// swiftlint:enable prefer_nimble
