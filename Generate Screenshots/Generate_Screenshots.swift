import XCTest
import XCUITestKit

// swiftlint:disable prefer_nimble
@MainActor
final class Generate_Screenshots: XCTestCase {
  private var usesSplitView = false

  override func setUp() async throws {
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
  }

  func testGenerateScreenshots() throws {
    let app = XCUIApplication()
    setupSnapshot(app)
    app.launch()

    XCTAssert(app.buttons["ratingPicker"].waitForExistence(timeout: 10))
    usesSplitView = !app.buttons["Results"].waitForExistence(timeout: 5)
    app.buttons["ratingPicker"].tap()
    app.buttons["ratingVFR"].tap()
    app.buttons["hoursPicker"].tap()
    app.buttons["hoursOver100"].tap()

    app /*@START_MENU_TOKEN@*/.buttons[
      "Questions"
    ] /*[[".otherElements.buttons[\"Questions\"]",".buttons[\"Questions\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
      .tap()
    scrollToTop(in: app)
    set(app: app, name: "lessThan50InTypeToggle", value: true)
    set(app: app, name: "lessThan15InLast90Toggle", value: false)
    set(app: app, name: "afterWorkToggle", value: true)
    set(app: app, name: "lessThan8HrSleepToggle", value: true)
    set(app: app, name: "dualInLast90Toggle", value: false)
    set(app: app, name: "wingsInLast6MoToggle", value: true)
    scrollToTop(in: app)
    Thread.sleep(forTimeInterval: 30)  // wait for Apple Intelligence banner to self-dismiss
    capture(.questions)

    set(app: app, name: "ifrCurrentToggle", value: false)
    set(app: app, name: "nightToggle", value: false)
    set(app: app, name: "strongWindsToggle", value: false)
    set(app: app, name: "strongCrosswindsToggle", value: false)
    set(app: app, name: "mountainousToggle", value: false)

    set(app: app, name: "nontoweredToggle", value: false)
    set(app: app, name: "shortRunwayToggle", value: false)
    set(app: app, name: "wetOrSoftFieldToggle", value: false)
    set(app: app, name: "runwayObstaclesToggle", value: false)

    let flightTypePicker = app.collectionViews.firstMatch.makeVisible(
      element: app.buttons["flightTypePicker"]
    )
    XCTAssertNotNil(flightTypePicker)
    flightTypePicker!.tap()
    app.buttons["flightTypeVFR"].tap()

    set(app: app, name: "vfrCeilingUnder3000Toggle", value: false)
    set(app: app, name: "vfrVisibilityUnder5Toggle", value: false)
    set(app: app, name: "vfrFlightPlanToggle", value: false)
    set(app: app, name: "vfrFlightFollowingToggle", value: false)
    set(app: app, name: "noDestWxToggle", value: false)

    showResults(in: app, expecting: "LOW RISK")
    capture(.resultsLowRisk)

    app /*@START_MENU_TOKEN@*/.buttons[
      "Questions"
    ] /*[[".otherElements.buttons[\"Questions\"]",".buttons[\"Questions\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
      .tap()
    scrollToTop(in: app)
    set(app: app, name: "nightToggle", value: true)
    set(app: app, name: "strongWindsToggle", value: true)
    set(app: app, name: "strongCrosswindsToggle", value: true)

    showResults(in: app, expecting: "MODERATE RISK")
    capture(.resultsModerateRisk)

    app /*@START_MENU_TOKEN@*/.buttons[
      "Questions"
    ] /*[[".otherElements.buttons[\"Questions\"]",".buttons[\"Questions\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
      .tap()
    scrollToTop(in: app)
    set(app: app, name: "nontoweredToggle", value: true)
    set(app: app, name: "shortRunwayToggle", value: true)
    set(app: app, name: "wetOrSoftFieldToggle", value: true)
    set(app: app, name: "runwayObstaclesToggle", value: true)

    showResults(in: app, expecting: "HIGH RISK")
    capture(.resultsHighRisk)

    showPilotProfile(in: app)
    capture(.pilot)
  }

  /// Takes a screenshot, numbered by its place in this layout's order.
  private func capture(_ shot: Shot) {
    let order = usesSplitView ? Shot.splitViewOrder : Shot.tabOrder
    guard let index = order.firstIndex(of: shot) else { return }
    snapshot("\(index)-\(shot.rawValue)")
  }

  /// Shows the Pilot Profile, its score badge carrying the questionnaire's high-risk total.
  private func showPilotProfile(in app: XCUIApplication) {
    scrollToTop(in: app)
    app.buttons["Pilot"].firstMatch.tap()
    XCTAssert(
      app.buttons["ratingPicker"].waitForExistence(timeout: 10),
      "Pilot Profile is not on screen"
    )
  }

  /// Sets a toggle, failing the test if it does not take. A lost tap would otherwise go unnoticed
  /// and skew every score that follows it.
  private func set(app: XCUIApplication, name: String, value: Bool) {
    let control = app.collectionViews.firstMatch.makeVisible(element: app.switches[name])
    XCTAssertNotNil(control, "\(name) is not in the questionnaire")
    XCTAssert(
      control!.setSwitch(to: value, in: app),
      "\(name) did not switch \(value ? "on" : "off")"
    )
  }

  /// Brings the results on screen and waits for the risk level the caller expects, so a
  /// screenshot is never taken of a screen that disagrees with its own filename.
  ///
  /// The compact layout reaches the results through a tab; the regular layout keeps them in the
  /// split view's detail column, where there is no tab to tap. Scrolling the questionnaire
  /// minimizes the tab bar, so the tab only becomes reachable again after scrolling back to the
  /// top.
  private func showResults(in app: XCUIApplication, expecting riskLevel: String) {
    scrollToTop(in: app)

    let riskLevelText = app.staticTexts["riskLevelText"]
    let resultsTab = app.buttons["Results"]
    if resultsTab.waitForExistence(timeout: ScaledTimeouts.short) {
      // The tab bar is one of the translucent bars that can swallow a plain tap, so escalate
      // until the results actually render.
      resultsTab.firstMatch.tap(
        untilExists: riskLevelText,
        using: XCUIElement.TapStrategy.escalating
      )
    }

    XCTAssert(riskLevelText.waitForExistence(timeout: 5), "Results are not on screen")

    let settled = expectation(
      for: NSPredicate(format: "label == %@", riskLevel),
      evaluatedWith: riskLevelText
    )
    wait(for: [settled], timeout: 10)

    Thread.sleep(forTimeInterval: 2)  // let the gauge finish sweeping to the score
  }

  /// Scrolls the questionnaire back to its top.
  ///
  /// Scrolls the form itself rather than tapping the status bar to scroll-to-top: on iPadOS 26 a
  /// tap delivered to SpringBoard's status bar pulls a full-screen app into a window, and every
  /// screenshot taken after it shows the app floating over the desktop with the dock visible.
  private func scrollToTop(in app: XCUIApplication) {
    let collectionView = app.collectionViews.firstMatch
    guard collectionView.exists else { return }

    for _ in 0..<5 { collectionView.swipeDown() }
  }

  /// The listing's screenshots. The split view keeps the results beside the questionnaire, so it
  /// leaves out the questionnaire on its own.
  private enum Shot: String {
    case resultsModerateRisk = "results-moderate-risk"
    case questions
    case resultsHighRisk = "results-high-risk"
    case resultsLowRisk = "results-low-risk"
    case pilot

    static let tabOrder: [Self] = [
      .resultsModerateRisk, .questions, .resultsHighRisk, .resultsLowRisk, .pilot
    ]
    static let splitViewOrder: [Self] = [
      .resultsModerateRisk, .resultsHighRisk, .resultsLowRisk, .pilot
    ]
  }
}
// swiftlint:enable prefer_nimble
