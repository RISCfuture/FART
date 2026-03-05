import XCTest

class FARTUITestCase: XCTestCase {
  var app: XCUIApplication!
  var tabBar: TabBarPage!

  /// True when running on iPad (two-column NavigationSplitView layout).
  var isIPad: Bool { tabBar.isIPad }

  override func setUpWithError() throws {
    continueAfterFailure = false
    app = XCUIApplication()
    app.launchArguments = ["UI-TESTING"]
    app.launch()
    tabBar = TabBarPage(app: app)
  }
}
