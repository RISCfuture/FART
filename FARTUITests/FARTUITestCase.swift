import XCTest
import XCUITestKit

// swiftlint:disable final_test_case test_case_accessibility
@MainActor
class FARTUITestCase: XCTestCase {
  var app: XCUIApplication!
  var tabBar: TabBarPage!

  /// True when the app shows its two-column NavigationSplitView layout, as on iPad.
  var isTwoColumnLayout: Bool { tabBar.isTwoColumnLayout }

  override func setUp() async throws {
    continueAfterFailure = false
    app = XCUIApplication()
    app.disableLogStderrMirroring()
    app.launchArguments = ["UI-TESTING"]
    app.launch()
    tabBar = TabBarPage(app: app)
  }
}
// swiftlint:enable final_test_case test_case_accessibility
