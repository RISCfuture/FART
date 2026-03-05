import XCTest

// swiftlint:disable prefer_nimble
final class PilotProfileTests: FARTUITestCase {

  @MainActor
  func testIFRConditionalFieldsVisibility() throws {
    let profile = tabBar.goToPilotProfile()

    // Select IFR — pickers should appear
    profile.selectIFR()
    XCTAssertTrue(profile.isLowCeilingPickerVisible())
    XCTAssertTrue(profile.isLowVisibilityPickerVisible())

    // Switch back to VFR — pickers should disappear
    profile.selectVFR()
    XCTAssertFalse(app.buttons["lowCeilingPicker"].exists)
    XCTAssertFalse(app.buttons["lowVisibilityPicker"].exists)

    // Switch to IFR again — pickers should reappear
    profile.selectIFR()
    XCTAssertTrue(profile.isLowCeilingPickerVisible())
    XCTAssertTrue(profile.isLowVisibilityPickerVisible())
  }

  @MainActor
  func testRatingAffectsRiskCategorization() throws {
    // VFR <100h (defaults). Score 18 → VFR<100h MODERATE (>14)
    let q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setLessThan50InType(true)
      .setAfterWork(true)
      .setLessThan8HrSleep(true)
    q.weatherSection.setNoDestWx(true)

    tabBar.goToResults()
      .assertResults(score: "18", riskLevel: "MODERATE RISK")

    // Switch to IFR. Score stays 18 → IFR<100h LOW (≤20)
    tabBar.goToPilotProfile()
      .selectIFR()

    tabBar.goToResults()
      .assertResults(score: "18", riskLevel: "LOW RISK")
  }

  @MainActor
  func testHoursAffectsRiskCategorization() throws {
    // VFR <100h (defaults). Score 18 → VFR<100h MODERATE (>14)
    let q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setLessThan50InType(true)
      .setAfterWork(true)
      .setLessThan8HrSleep(true)
    q.weatherSection.setNoDestWx(true)

    tabBar.goToResults()
      .assertResults(score: "18", riskLevel: "MODERATE RISK")

    // Switch to >100h. Score stays 18 → VFR>100h LOW (≤20)
    tabBar.goToPilotProfile()
      .selectOver100Hours()

    tabBar.goToResults()
      .assertResults(score: "18", riskLevel: "LOW RISK")
  }
}
// swiftlint:enable prefer_nimble
