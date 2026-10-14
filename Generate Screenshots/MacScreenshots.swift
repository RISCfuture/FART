import XCTest

// swiftlint:disable prefer_nimble
/// Drives the Mac app through the Mac App Store screenshots and attaches each window capture to
/// the result bundle, named in listing order. `Scripts/export-mac-screenshots.sh` pulls them out
/// and composes them onto 16:10 canvases.
@MainActor
final class MacScreenshots: XCTestCase {
  /// The same pilot as the iOS captures, VFR with over 100 hours, set through the argument domain
  /// so the first-launch welcome window never opens.
  private static let pilot = ["-hours", "over100", "-hasCompletedWelcome", "YES"]

  private var app: XCUIApplication!

  override func setUp() async throws {
    continueAfterFailure = false
    app = XCUIApplication()
    app.launchArguments = ["UI-TESTING", "-NSRequiresAquaSystemAppearance", "YES"] + Self.pilot
    app.launch()
  }

  override func tearDown() async throws {
    app.terminate()
  }

  func testGenerateMacScreenshots() throws {
    let window = mainWindow()

    answerBaselineQuestions()
    answer(["nightToggle", "strongWindsToggle", "strongCrosswindsToggle"], with: true)
    waitForRisk("MODERATE RISK")
    capture(window, named: "0-results-moderate-risk")

    answer(
      ["nontoweredToggle", "shortRunwayToggle", "wetOrSoftFieldToggle", "runwayObstaclesToggle"],
      with: true
    )
    waitForRisk("HIGH RISK")
    capture(window, named: "1-results-high-risk")

    answer(
      [
        "nontoweredToggle", "shortRunwayToggle", "wetOrSoftFieldToggle", "runwayObstaclesToggle",
        "nightToggle", "strongWindsToggle", "strongCrosswindsToggle"
      ],
      with: false
    )
    waitForRisk("LOW RISK")
    capture(window, named: "2-results-low-risk")

    capturePilotProfileSettings(named: "3-pilot")
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

  private func capturePilotProfileSettings(named name: String) {
    app.typeKey(",", modifierFlags: .command)
    let settings = app.windows.containing(.popUpButton, identifier: "ratingPicker").firstMatch
    XCTAssert(settings.waitForExistence(timeout: 10), "Settings did not open")
    capture(settings, named: name)
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
  private func waitForRisk(_ riskLevel: String) {
    let riskLevelText = app.staticTexts["riskLevelText"]
    XCTAssert(riskLevelText.waitForExistence(timeout: 5), "Results are not on screen")
    let settled = expectation(
      for: NSPredicate(format: "value == %@ OR label == %@", riskLevel, riskLevel),
      evaluatedWith: riskLevelText
    )
    wait(for: [settled], timeout: 10)
    Thread.sleep(forTimeInterval: 2)  // let the gauge finish sweeping to the score
  }

  private func capture(_ element: XCUIElement, named name: String) {
    let attachment = XCTAttachment(screenshot: element.screenshot())
    attachment.name = name
    attachment.lifetime = .keepAlways
    add(attachment)
  }
}
// swiftlint:enable prefer_nimble
