import XCTest

// swiftlint:disable prefer_nimble
final class FARTUITests: XCTestCase {

  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  @MainActor
  func testGreenRiskQuestionnaireFlow() throws {
    let app = launchApp()
    setupInitialRatingAndHours(app: app)
    navigateToQuestions(app: app)

    // Pilot experience toggles
    setToggles(
      app: app,
      values: [
        ("lessThan50InTypeToggle", true),
        ("lessThan15InLast90Toggle", false),
        ("afterWorkToggle", true),
        ("lessThan8HrSleepToggle", true),
        ("dualInLast90Toggle", false),
        ("wingsInLast6MoToggle", true),
        ("ifrCurrentToggle", false)
      ]
    )

    // Environment condition toggles
    setToggles(
      app: app,
      values: [
        ("nightToggle", false),
        ("strongWindsToggle", false),
        ("strongCrosswindsToggle", false),
        ("mountainousToggle", false)
      ]
    )

    // Airport condition toggles
    setToggles(
      app: app,
      values: [
        ("nontoweredToggle", false),
        ("shortRunwayToggle", false),
        ("wetOrSoftFieldToggle", false),
        ("runwayObstaclesToggle", false)
      ]
    )

    selectFlightType(app: app, type: "flightTypeVFR")

    // VFR-specific toggles
    setToggles(
      app: app,
      values: [
        ("vfrCeilingUnder3000Toggle", false),
        ("vfrVisibilityUnder5Toggle", false),
        ("vfrFlightPlanToggle", false),
        ("vfrFlightFollowingToggle", false),
        ("noDestWxToggle", false)
      ]
    )

    assertRiskLevel(app: app, expectedRisk: "LOW RISK")
  }

  @MainActor
  func testYellowRiskQuestionnaireFlow() throws {
    let app = launchApp()
    setupInitialRatingAndHours(app: app)
    navigateToQuestions(app: app)

    // Pilot experience toggles
    setToggles(
      app: app,
      values: [
        ("lessThan50InTypeToggle", true),
        ("lessThan15InLast90Toggle", false),
        ("afterWorkToggle", true),
        ("lessThan8HrSleepToggle", true),
        ("dualInLast90Toggle", false),
        ("wingsInLast6MoToggle", true),
        ("ifrCurrentToggle", true)
      ]
    )

    // Environment condition toggles (moderate risk)
    setToggles(
      app: app,
      values: [
        ("nightToggle", true),
        ("strongWindsToggle", true),
        ("strongCrosswindsToggle", true),
        ("mountainousToggle", false)
      ]
    )

    // Airport condition toggles
    setToggles(
      app: app,
      values: [
        ("nontoweredToggle", false),
        ("shortRunwayToggle", false),
        ("wetOrSoftFieldToggle", false),
        ("runwayObstaclesToggle", false)
      ]
    )

    selectFlightType(app: app, type: "flightTypeVFR")

    // VFR-specific toggles
    setToggles(
      app: app,
      values: [
        ("vfrCeilingUnder3000Toggle", false),
        ("vfrVisibilityUnder5Toggle", false),
        ("vfrFlightPlanToggle", false),
        ("vfrFlightFollowingToggle", false),
        ("noDestWxToggle", false)
      ]
    )

    assertRiskLevel(app: app, expectedRisk: "MODERATE RISK")
  }

  @MainActor
  func testRedRiskQuestionnaireFlow() throws {
    let app = launchApp()
    setupInitialRatingAndHours(app: app)
    navigateToQuestions(app: app)

    // Pilot experience toggles
    setToggles(
      app: app,
      values: [
        ("lessThan50InTypeToggle", true),
        ("lessThan15InLast90Toggle", false),
        ("afterWorkToggle", true),
        ("lessThan8HrSleepToggle", true),
        ("dualInLast90Toggle", false),
        ("wingsInLast6MoToggle", true),
        ("ifrCurrentToggle", true)
      ]
    )

    // Environment condition toggles (moderate risk)
    setToggles(
      app: app,
      values: [
        ("nightToggle", true),
        ("strongWindsToggle", true),
        ("strongCrosswindsToggle", true),
        ("mountainousToggle", false)
      ]
    )

    // Airport condition toggles (high risk)
    setToggles(
      app: app,
      values: [
        ("nontoweredToggle", true),
        ("shortRunwayToggle", true),
        ("wetOrSoftFieldToggle", true),
        ("runwayObstaclesToggle", true)
      ]
    )

    selectFlightType(app: app, type: "flightTypeVFR")

    // VFR-specific toggles
    setToggles(
      app: app,
      values: [
        ("vfrCeilingUnder3000Toggle", false),
        ("vfrVisibilityUnder5Toggle", false),
        ("vfrFlightPlanToggle", false),
        ("vfrFlightFollowingToggle", false),
        ("noDestWxToggle", false)
      ]
    )

    assertRiskLevel(app: app, expectedRisk: "HIGH RISK")
  }

  // MARK: - Helper Functions

  private func launchApp() -> XCUIApplication {
    let app = XCUIApplication()
    app.launchArguments = ["UI-TESTING"]
    app.launch()
    return app
  }

  private func setupInitialRatingAndHours(app: XCUIApplication) {
    XCTAssert(app.buttons["ratingPicker"].waitForExistence(timeout: 10))
    app.buttons["ratingPicker"].tap()
    app.buttons["ratingVFR"].tap()
    app.buttons["hoursPicker"].tap()
    app.buttons["hoursOver100"].tap()
  }

  private func navigateToQuestions(app: XCUIApplication) {
    app.buttons["Questions"].tap()
    scrollToTop(app: app)
  }

  private func setToggles(app: XCUIApplication, values: [(String, Bool)]) {
    for (name, value) in values {
      set(app: app, name: name, value: value)
    }
  }

  private func selectFlightType(app: XCUIApplication, type: String) {
    let flightTypePicker = app.collectionViews.firstMatch.makeVisible(
      element: app.buttons["flightTypePicker"]
    )
    XCTAssertNotNil(flightTypePicker)
    flightTypePicker!.tap()
    app.buttons[type].tap()
  }

  private func assertRiskLevel(app: XCUIApplication, expectedRisk: String) {
    if app.buttons["Results"].exists {
      app.buttons["Results"].firstMatch.tap()
    }
    let riskLevel = app.staticTexts["riskLevelText"]
    XCTAssertTrue(riskLevel.waitForExistence(timeout: 5))
    XCTAssertEqual(riskLevel.label, expectedRisk)
  }

  private func set(app: XCUIApplication, name: String, value: Bool) {
    let control = app.collectionViews.firstMatch.makeVisible(element: app.switches[name])
    XCTAssertNotNil(control)
    value ? control!.toggleOn() : control!.toggleOff()
  }

  private func scrollToTop(app: XCUIApplication) {
    // First try tapping status bar
    let springboardApp = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    for bar in springboardApp.statusBars.allElementsBoundByIndex { bar.tap() }

    // Give it time to scroll and wait for app to idle
    Thread.sleep(forTimeInterval: 0.5)

    // Ensure we're at the top by scrolling down from top of collection view
    let collectionView = app.collectionViews.firstMatch
    if collectionView.exists {
      let topCoordinate = collectionView.coordinate(
        withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1)
      )
      let bottomCoordinate = collectionView.coordinate(
        withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9)
      )
      bottomCoordinate.press(forDuration: 0.1, thenDragTo: topCoordinate)
      Thread.sleep(forTimeInterval: 0.3)
    }
  }
}
// swiftlint:enable prefer_nimble
