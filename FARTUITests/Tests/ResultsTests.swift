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
}
// swiftlint:enable prefer_nimble
