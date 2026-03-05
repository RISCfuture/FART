import XCTest

// swiftlint:disable prefer_nimble
final class QuestionnaireTests: FARTUITestCase {

  @MainActor
  func testFlightTypeSwitchShowsCorrectFields() throws {
    let q = tabBar.goToQuestionnaire()

    // VFR by default — scroll to last VFR weather toggle to ensure all are loaded
    _ = q.scrollTo("vfrFlightFollowingToggle")

    // VFR toggles visible
    XCTAssertTrue(app.switches["vfrFlightFollowingToggle"].exists)
    XCTAssertTrue(app.switches["vfrFlightPlanToggle"].exists)
    XCTAssertTrue(app.switches["vfrVisibilityUnder5Toggle"].exists)
    XCTAssertTrue(app.switches["vfrCeilingUnder3000Toggle"].exists)

    // IFR toggles not present
    XCTAssertFalse(app.switches["ifrLowCeilingToggle"].exists)
    XCTAssertFalse(app.switches["ifrLowVisibilityToggle"].exists)
    XCTAssertFalse(app.buttons["ifrApproachTypePicker"].exists)

    // Switch to IFR
    q.weatherSection.selectIFR()

    // IFR toggles visible
    XCTAssertTrue(app.switches["ifrLowCeilingToggle"].waitForExistence(timeout: 3))
    XCTAssertTrue(app.switches["ifrLowVisibilityToggle"].exists)
    XCTAssertTrue(app.buttons["ifrApproachTypePicker"].exists)

    // VFR toggles gone
    XCTAssertFalse(app.switches["vfrCeilingUnder3000Toggle"].exists)
    XCTAssertFalse(app.switches["vfrVisibilityUnder5Toggle"].exists)
    XCTAssertFalse(app.switches["vfrFlightPlanToggle"].exists)
    XCTAssertFalse(app.switches["vfrFlightFollowingToggle"].exists)

    // Switch back to VFR
    q.weatherSection.selectVFR()

    // VFR toggles back
    XCTAssertTrue(app.switches["vfrCeilingUnder3000Toggle"].waitForExistence(timeout: 3))
    XCTAssertTrue(app.switches["vfrVisibilityUnder5Toggle"].exists)
    XCTAssertTrue(app.switches["vfrFlightPlanToggle"].exists)
    XCTAssertTrue(app.switches["vfrFlightFollowingToggle"].exists)

    // IFR toggles gone again
    XCTAssertFalse(app.switches["ifrLowCeilingToggle"].exists)
    XCTAssertFalse(app.switches["ifrLowVisibilityToggle"].exists)
    XCTAssertFalse(app.buttons["ifrApproachTypePicker"].exists)
  }

  @MainActor
  func testVFRToIFRClearsVFRFieldsAndResetsScore() throws {
    // VFR >100h
    tabBar.goToPilotProfile()
      .selectVFR()
      .selectOver100Hours()

    // Turn on vfrCeilingUnder3000(+2) + vfrFlightPlan(-2) → score 0
    var q = tabBar.goToQuestionnaire()
    q.weatherSection
      .setVFRCeilingUnder3000(true)
      .setVFRFlightPlan(true)

    tabBar.goToResults()
      .assertResults(score: "0", riskLevel: "LOW RISK")

    // Turn on lessThan50InType(+5), turn off vfrFlightPlan → score 7
    q = tabBar.goToQuestionnaire()
    q.pilotSection.setLessThan50InType(true)
    q.weatherSection.setVFRFlightPlan(false)

    tabBar.goToResults()
      .assertResults(score: "7", riskLevel: "LOW RISK")

    // Switch IFR (clears VFR fields) then back to VFR → score 5
    q = tabBar.goToQuestionnaire()
    q.weatherSection.selectIFR()
    q.weatherSection.selectVFR()

    tabBar.goToResults()
      .assertResults(score: "5", riskLevel: "LOW RISK")
  }

  @MainActor
  func testIFRToVFRClearsIFRFieldsAndResetsScore() throws {
    // VFR >100h
    tabBar.goToPilotProfile()
      .selectVFR()
      .selectOver100Hours()

    // Switch to IFR flight type → approach defaults to none(+4)
    var q = tabBar.goToQuestionnaire()
    q.weatherSection.selectIFR()
    q.weatherSection
      .setIFRLowCeiling(true)
      .setIFRLowVisibility(true)
    q.pilotSection.setLessThan50InType(true)

    // Score: 5 + 2 + 2 + 4(none) = 13
    tabBar.goToResults()
      .assertResults(score: "13", riskLevel: "LOW RISK")

    // Switch VFR (clears IFR fields) then back to IFR → score 9
    q = tabBar.goToQuestionnaire()
    q.weatherSection.selectVFR()
    q.weatherSection.selectIFR()

    // Only lessThan50InType(5) + none approach(4) = 9
    tabBar.goToResults()
      .assertResults(score: "9", riskLevel: "LOW RISK")
  }

  @MainActor
  func testPilotTogglesAffectScore() throws {
    // VFR >100h
    tabBar.goToPilotProfile()
      .selectVFR()
      .selectOver100Hours()

    // All 7 pilot toggles: 5+3+4+5-1-3-3 = 10
    let q = tabBar.goToQuestionnaire()
    q.pilotSection.setAllToggles(
      lessThan50InType: true,
      lessThan15InLast90: true,
      afterWork: true,
      lessThan8HrSleep: true,
      dualInLast90: true,
      wingsInLast6Mo: true,
      ifrCurrent: true
    )

    tabBar.goToResults()
      .assertResults(score: "10", riskLevel: "LOW RISK")
  }

  @MainActor
  func testConditionTogglesAffectScore() throws {
    // VFR >100h
    tabBar.goToPilotProfile()
      .selectVFR()
      .selectOver100Hours()

    // All 4 condition toggles: 5+4+4+4 = 17
    let q = tabBar.goToQuestionnaire()
    q.conditionsSection.setAllToggles(
      night: true,
      strongWinds: true,
      strongCrosswinds: true,
      mountainous: true
    )

    tabBar.goToResults()
      .assertResults(score: "17", riskLevel: "LOW RISK")
  }

  @MainActor
  func testAirportTogglesAffectScore() throws {
    // VFR >100h
    tabBar.goToPilotProfile()
      .selectVFR()
      .selectOver100Hours()

    // All 4 airport toggles: 5+3+3+3 = 14
    let q = tabBar.goToQuestionnaire()
    q.airportSection.setAllToggles(
      nontowered: true,
      shortRunway: true,
      wetOrSoftField: true,
      runwayObstacles: true
    )

    tabBar.goToResults()
      .assertResults(score: "14", riskLevel: "LOW RISK")
  }

  @MainActor
  func testWeatherTogglesAffectScore() throws {
    // VFR >100h
    tabBar.goToPilotProfile()
      .selectVFR()
      .selectOver100Hours()

    // VFR weather toggles + noDestWx: 2+2+4-2-3 = 3
    let q = tabBar.goToQuestionnaire()
    q.weatherSection
      .setVFRCeilingUnder3000(true)
      .setVFRVisibilityUnder5(true)
      .setNoDestWx(true)
      .setVFRFlightPlan(true)
      .setVFRFlightFollowing(true)

    tabBar.goToResults()
      .assertResults(score: "3", riskLevel: "LOW RISK")
  }
}
// swiftlint:enable prefer_nimble
