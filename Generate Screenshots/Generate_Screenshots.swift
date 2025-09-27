import XCTest

final class Generate_Screenshots: XCTestCase {

  override func setUpWithError() throws {
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
  }

  override func tearDownWithError() throws {
  }

  @MainActor
  func testGenerateScreenshots() throws {
    let app = XCUIApplication()
    setupSnapshot(app)
    app.launch()

    XCTAssert(app.buttons["ratingPicker"].waitForExistence(timeout: 10))
    app.buttons["ratingPicker"].tap()
    app.buttons["ratingVFR"].tap()
    app.buttons["hoursPicker"].tap()
    app.buttons["hoursOver100"].tap()

    Thread.sleep(forTimeInterval: 30)  // wait for Apple Intelligence banner to self-dismiss
    snapshot("0-pilot")

    app /*@START_MENU_TOKEN@*/.buttons[
      "Questions"
    ] /*[[".otherElements.buttons[\"Questions\"]",".buttons[\"Questions\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
      .tap()
    scrollToTop()
    set(app: app, name: "lessThan50InTypeToggle", value: true)
    set(app: app, name: "lessThan15InLast90Toggle", value: false)
    set(app: app, name: "afterWorkToggle", value: true)
    set(app: app, name: "lessThan8HrSleepToggle", value: true)
    set(app: app, name: "dualInLast90Toggle", value: false)
    set(app: app, name: "wingsInLast6MoToggle", value: true)
    snapshot("1-questions")

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

    if app.buttons["Results"].exists {
      app.buttons["Results"].firstMatch.tap()
    }
    Thread.sleep(forTimeInterval: 2)
    snapshot("2-results-low-risk")

    app /*@START_MENU_TOKEN@*/.buttons[
      "Questions"
    ] /*[[".otherElements.buttons[\"Questions\"]",".buttons[\"Questions\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
      .tap()
    scrollToTop()
    set(app: app, name: "ifrCurrentToggle", value: true)
    set(app: app, name: "nightToggle", value: true)
    set(app: app, name: "strongWindsToggle", value: true)
    set(app: app, name: "strongCrosswindsToggle", value: true)

    if app.buttons["Results"].exists {
      app.buttons["Results"].firstMatch.tap()
    }
    Thread.sleep(forTimeInterval: 2)
    snapshot("3-results-moderate-risk")

    app /*@START_MENU_TOKEN@*/.buttons[
      "Questions"
    ] /*[[".otherElements.buttons[\"Questions\"]",".buttons[\"Questions\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
      .tap()
    scrollToTop()
    set(app: app, name: "nontoweredToggle", value: true)
    set(app: app, name: "shortRunwayToggle", value: true)
    set(app: app, name: "wetOrSoftFieldToggle", value: true)
    set(app: app, name: "runwayObstaclesToggle", value: true)

    if app.buttons["Results"].exists {
      app.buttons["Results"].firstMatch.tap()
    }
    Thread.sleep(forTimeInterval: 2)
    snapshot("4-results-high-risk")
  }

  private func set(app: XCUIApplication, name: String, value: Bool) {
    let control = app.collectionViews.firstMatch.makeVisible(element: app.switches[name])
    XCTAssertNotNil(control)
    value ? control!.toggleOn() : control!.toggleOff()
  }

  private func scrollToTop() {
    let springboardApp = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    for bar in springboardApp.statusBars.allElementsBoundByIndex { bar.tap() }
  }
}
