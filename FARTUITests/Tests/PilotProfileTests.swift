import XCTest
import XCUITestKit

// swiftlint:disable prefer_nimble
final class PilotProfileTests: FARTUITestCase {

  func testIFRConditionalFieldsVisibility() throws {
    let profile = tabBar.goToPilotProfile()

    // Select IFR — pickers should appear
    profile.selectIFR()
    XCTAssertTrue(profile.isLowCeilingPickerVisible())
    XCTAssertTrue(profile.isLowVisibilityPickerVisible())

    // Switch back to VFR — pickers should disappear
    profile.selectVFR()
    profile.lowCeilingPicker.assertHidden()
    profile.lowVisibilityPicker.assertHidden()

    // Switch to IFR again — pickers should reappear
    profile.selectIFR()
    XCTAssertTrue(profile.isLowCeilingPickerVisible())
    XCTAssertTrue(profile.isLowVisibilityPickerVisible())
  }

  /// The thresholds are the one place in the app a pilot types a number rather than tapping one,
  /// and each is bound to a preference that echoes the write back asynchronously. A field that
  /// rewrote itself from that lagging value would mangle what was being typed, and one that never
  /// wrote would leave the questionnaire asking about the old threshold — neither of which shows
  /// up anywhere but here.
  func testShortRunwayThresholdSurvivesTypingAndNavigation() throws {
    let profile = tabBar.goToPilotProfile()
    profile.enter("4550", into: profile.shortRunwayField)
    XCTAssertEqual(profile.enteredNumber(in: profile.shortRunwayField), "4550")

    // The threshold's whole purpose is the question it writes, so it has to have reached
    // preferences and not just the field it was typed into.
    let questionnaire = tabBar.goToQuestionnaire()
    XCTAssertEqual(questionnaire.airportSection.shortRunwayThreshold(), "4550")

    XCTAssertEqual(
      tabBar.goToPilotProfile().enteredNumber(in: profile.shortRunwayField),
      "4550"
    )
  }

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
