import Foundation
import XCTest
import XCUIPromoKit
import XCUITestKit

// swiftlint:disable prefer_nimble
/// Plays the App Store preview's script while `promokit record risk-loop` films the simulator.
///
/// The take keeps each stretch worth showing (a held shot, a tap and its effect) and files it
/// under the scene `promo/storyboard.json` frames. Outside `promokit record`, the test skips.
///
/// Every toggle the camera sees is one of the first four in the questionnaire, so nothing scrolls
/// on screen. Points are for a VFR pilot with over 100 hours: low up to 20, moderate to 25, high
/// from 26.
@MainActor
final class PreviewRecording: XCTestCase {
  private static let tapSettle: TimeInterval = 0.6
  private static let tabSettle: TimeInterval = 1.2
  private static let resultsSettle: TimeInterval = 1.6
  private static let tapLanding: TimeInterval = 0.3

  /// Off camera: strong wind, strong crosswind and mountains, less a recent WINGS phase, for 9.
  private static let openingAnswers = [
    "strongWindsToggle", "strongCrosswindsToggle", "mountainousToggle", "wingsInLast6MoToggle"
  ]
  /// 9 + 5 + 4 + 5 = 23.
  private static let climbToModerate = [
    "lessThan50InTypeToggle", "afterWorkToggle", "lessThan8HrSleepToggle"
  ]
  /// 23 + 3 = 26.
  private static let tipIntoHigh = ["lessThan15InLast90Toggle"]

  private var app: XCUIApplication!
  private var take: PromoTake!

  override func setUp() async throws {
    continueAfterFailure = false
  }

  /// Opens and closes on the same low-risk Results screen at 9 points, so the preview loops
  /// without a seam.
  func testRecordPreview() throws {
    app = XCUIApplication()
    take = try PromoTake(app: app, tapLanding: Self.tapLanding)
    app.launchArguments = PromoLaunch(flags: ["UI-TESTING", "PROMO-RECORDING"]).arguments
    app.launch()

    setUpOpeningShot()
    try take.startRolling()

    take.scene("opening") { take.hold(1.5) }
    take.scene("climb") {
      showQuestions()
      for toggle in Self.climbToModerate { flip(toggle) }
    }
    take.scene("moderate") {
      showResults(expecting: "MODERATE RISK")
      take.hold(1.5)
    }
    take.scene("tip") {
      showQuestions()
      for toggle in Self.tipIntoHigh { flip(toggle) }
    }
    take.scene("high") {
      showResults(expecting: "HIGH RISK")
      take.hold(2.0)
    }
    take.scene("unwind") {
      showQuestions()
      for toggle in (Self.climbToModerate + Self.tipIntoHigh).reversed() { flip(toggle) }
    }
    take.scene("closing") {
      showResults(expecting: "LOW RISK")
      take.hold(1.5)
    }

    try take.finish()
  }

  // MARK: - Steps

  /// Sets the opening answers and shows Results, off camera, where scrolling to reach the toggles
  /// doesn't matter.
  private func setUpOpeningShot() {
    XCTAssert(app.buttons["ratingPicker"].waitForExistence(timeout: 10))
    app.buttons["hoursPicker"].tap()
    app.buttons["hoursOver100"].tap()

    app.buttons["Questions"].firstMatch.tap()
    for toggle in Self.openingAnswers {
      let control = app.collectionViews.firstMatch.makeVisible(element: app.switches[toggle])
      XCTAssertNotNil(control, "\(toggle) is not in the questionnaire")
      XCTAssert(control!.setSwitch(to: true, in: app), "\(toggle) did not switch on")
    }
    scrollToTop()
    app.buttons["Results"].firstMatch.tap()
    waitForRisk("LOW RISK")
    Thread.sleep(forTimeInterval: 30)  // wait for the Apple Intelligence banner to self-dismiss
  }

  private func showQuestions() {
    restoreTabBar(showing: "Questions")
    take.tap(app.buttons["Questions"].firstMatch, settle: Self.tabSettle)
  }

  private func showResults(expecting riskLevel: String) {
    restoreTabBar(showing: "Results")
    take.tap(app.buttons["Results"].firstMatch, settle: Self.resultsSettle)
    waitForRisk(riskLevel)
  }

  private func flip(_ identifier: String) {
    let toggle = app.switches[identifier]
    XCTAssert(toggle.isHittable, "\(identifier) is not on screen without scrolling")
    XCTAssert(
      take.setSwitch(toggle, to: !toggle.isOn, settle: Self.tapSettle),
      "\(identifier) did not switch"
    )
  }

  // MARK: - Helpers

  /// Brings back a tab bar that minimized when a switch nudged the form. This happens between
  /// kept stretches, so the camera never sees it.
  private func restoreTabBar(showing tab: String) {
    guard !app.buttons[tab].firstMatch.isHittable else { return }
    scrollToTop()
  }

  private func waitForRisk(_ riskLevel: String) {
    let settled = expectation(
      for: NSPredicate(format: "label == %@", riskLevel),
      evaluatedWith: app.staticTexts["riskLevelText"]
    )
    wait(for: [settled], timeout: 10)
  }

  private func scrollToTop() {
    let collectionView = app.collectionViews.firstMatch
    guard collectionView.exists else { return }

    for _ in 0..<5 { collectionView.swipeDown() }
  }
}
// swiftlint:enable prefer_nimble
