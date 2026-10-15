import XCTest
import XCUIPromoKit

// swiftlint:disable prefer_nimble
/// Drives the Mac app through the Mac App Store screenshots and attaches each window capture to
/// the result bundle. `promokit mac-stills` exports them, and `promokit render` sets them on 16:10
/// canvases; anywhere else, the test skips.
@MainActor
final class MacStoreScreenshots: XCTestCase {
  /// The same pilot as the iOS captures, VFR with over 100 hours, set through the argument domain
  /// so the first-launch welcome window never opens.
  private static let pilot: [String: DefaultsValue] = [
    "hours": "over100", "hasCompletedWelcome": true
  ]

  private static let bundleIdentifier = "codes.tim.FART"

  private var app: XCUIApplication!

  override func setUp() async throws {
    continueAfterFailure = false
    try XCTSkipUnless(
      ProcessInfo.processInfo.environment[PromoLaunch.localeVariable] != nil,
      "Only `promokit mac-stills` captures the Mac App Store stills."
    )
    app = XCUIApplication()
    var defaults = Self.pilot
    defaults["NSRequiresAquaSystemAppearance"] = true
    app.launchArguments = PromoLaunch(flags: ["UI-TESTING"], defaults: defaults).arguments
    app.launch()
  }

  override func tearDown() async throws {
    app?.terminate()
  }

  func testCaptureStills() async throws {
    let window = mainWindow()

    answerBaselineQuestions()
    answer(["nightToggle", "strongWindsToggle", "strongCrosswindsToggle"], with: true)
    try await waitForRisk("MODERATE RISK")
    try await capture(window, named: "results-moderate-risk")

    answer(
      ["nontoweredToggle", "shortRunwayToggle", "wetOrSoftFieldToggle", "runwayObstaclesToggle"],
      with: true
    )
    try await waitForRisk("HIGH RISK")
    try await capture(window, named: "results-high-risk")

    answer(
      [
        "nontoweredToggle", "shortRunwayToggle", "wetOrSoftFieldToggle", "runwayObstaclesToggle",
        "nightToggle", "strongWindsToggle", "strongCrosswindsToggle"
      ],
      with: false
    )
    try await waitForRisk("LOW RISK")
    try await capture(window, named: "results-low-risk")

    try await capturePilotProfileSettings(named: "pilot")
  }

  // MARK: - Steps

  private func mainWindow() -> XCUIElement {
    let window = app.windows.containing(.staticText, identifier: "riskLevelText").firstMatch
    XCTAssert(window.waitForExistence(timeout: 10), "The main window did not open")
    return window
  }

  private func answerBaselineQuestions() {
    answer(
      [
        "lessThan50InTypeToggle", "afterWorkToggle", "lessThan8HrSleepToggle",
        "wingsInLast6MoToggle"
      ],
      with: true
    )
  }

  private func capturePilotProfileSettings(named name: String) async throws {
    app.typeKey(",", modifierFlags: .command)
    let settings = app.windows.containing(.popUpButton, identifier: "ratingPicker").firstMatch
    XCTAssert(settings.waitForExistence(timeout: 10), "Settings did not open")
    try await capture(settings, named: name)
  }

  // MARK: - Helpers

  private func answer(_ identifiers: [String], with value: Bool) {
    for identifier in identifiers {
      let control = app.checkBoxes[identifier].firstMatch
      let toggle = control.waitForExistence(timeout: 2) ? control : app.switches[identifier]
      XCTAssert(toggle.waitForExistence(timeout: 5), "\(identifier) is not in the questionnaire")
      if isOn(toggle) != value { toggle.click() }
      XCTAssertEqual(isOn(toggle), value, "\(identifier) did not switch \(value ? "on" : "off")")
    }
  }

  private func isOn(_ toggle: XCUIElement) -> Bool {
    switch toggle.value {
      case let number as NSNumber: number.boolValue
      case let string as String: string == "1"
      default: false
    }
  }

  /// Waits for the results column to agree with the questionnaire, so no capture shows a
  /// score that disagrees with its filename.
  private func waitForRisk(_ riskLevel: String) async throws {
    let riskLevelText = app.staticTexts["riskLevelText"]
    XCTAssert(riskLevelText.waitForExistence(timeout: 5), "Results are not on screen")
    let settled = expectation(
      for: NSPredicate(format: "value == %@ OR label == %@", riskLevel, riskLevel),
      evaluatedWith: riskLevelText
    )
    await fulfillment(of: [settled], timeout: 10)
    try await Task.sleep(for: .seconds(2))  // let the gauge finish sweeping to the score
  }

  private func capture(_ window: XCUIElement, named name: String) async throws {
    try await PromoStill.capture(name, of: window, ownedBy: Self.bundleIdentifier, in: self)
  }
}
// swiftlint:enable prefer_nimble
