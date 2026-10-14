import Foundation
import XCTest
import XCUITestKit

// swiftlint:disable prefer_nimble
/// Plays the App Store preview's script while `Scripts/record-preview.sh` records the simulator.
///
/// The script hands over a directory in `PREVIEW_MARKER_DIRECTORY`. The test touches `ready` once
/// the opening shot is set up, waits for the script to touch `recording`, and from then on notes
/// each stretch worth keeping (a held shot, a tap and its effect) in `segments`, as seconds since
/// recording began along with the scene it belongs to. The script cuts the take down to those
/// stretches, which leaves out the time XCUITest spends between actions, and frames each scene by
/// the storyboard in `fastlane/captions`. Without the variable, as in a `snapshot` run, the test
/// skips.
///
/// Every toggle the camera sees is one of the first four in the questionnaire, so nothing scrolls
/// on screen. Points are for a VFR pilot with over 100 hours: low up to 20, moderate to 25, high
/// from 26.
@MainActor
final class PreviewRecording: XCTestCase {
  private static let markerDirectoryKey = "PREVIEW_MARKER_DIRECTORY"
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
  private var markers: URL!
  private var rollingSince = ContinuousClock.now
  private var currentScene = ""
  private var segments: [(scene: String, seconds: ClosedRange<Double>)] = []

  override func setUp() async throws {
    continueAfterFailure = false
  }

  /// Opens and closes on the same low-risk Results screen at 9 points, so the preview loops
  /// without a seam.
  func testRecordPreview() throws {
    markers = try markerDirectory()
    app = XCUIApplication()
    app.launchArguments = ["UI-TESTING"]
    app.launch()

    setUpOpeningShot()
    startRolling()

    scene("opening") { hold(1.5) }
    scene("climb") {
      showQuestions()
      for toggle in Self.climbToModerate { flip(toggle) }
    }
    scene("moderate") {
      showResults(expecting: "MODERATE RISK")
      hold(1.5)
    }
    scene("tip") {
      showQuestions()
      for toggle in Self.tipIntoHigh { flip(toggle) }
    }
    scene("high") {
      showResults(expecting: "HIGH RISK")
      hold(2.0)
    }
    scene("unwind") {
      showQuestions()
      for toggle in (Self.climbToModerate + Self.tipIntoHigh).reversed() { flip(toggle) }
    }
    scene("closing") {
      showResults(expecting: "LOW RISK")
      hold(1.5)
    }

    writeSegments()
  }

  // MARK: - Steps

  /// Sets the opening answers and shows Results, off camera, where scrolling to reach the toggles
  /// doesn't matter.
  private func setUpOpeningShot() {
    XCTAssert(app.buttons["ratingPicker"].waitForExistence(timeout: 10))
    app.buttons["hoursPicker"].tap()
    app.buttons["hoursOver100"].tap()

    tapTab("Questions")
    for toggle in Self.openingAnswers {
      let control = app.collectionViews.firstMatch.makeVisible(element: app.switches[toggle])
      XCTAssertNotNil(control, "\(toggle) is not in the questionnaire")
      XCTAssert(control!.setSwitch(to: true, in: app), "\(toggle) did not switch on")
    }
    scrollToTop()
    tapTab("Results")
    waitForRisk("LOW RISK")
    Thread.sleep(forTimeInterval: 30)  // wait for the Apple Intelligence banner to self-dismiss
  }

  private func showQuestions() {
    restoreTabBar(showing: "Questions")
    keepTail(Self.tabSettle) {
      tapTab("Questions")
      Thread.sleep(forTimeInterval: Self.tabSettle)
    }
  }

  private func showResults(expecting riskLevel: String) {
    restoreTabBar(showing: "Results")
    keepTail(Self.resultsSettle) {
      tapTab("Results")
      Thread.sleep(forTimeInterval: Self.resultsSettle)
    }
    waitForRisk(riskLevel)
  }

  private func flip(_ identifier: String) {
    let toggle = app.switches[identifier]
    XCTAssert(toggle.isHittable, "\(identifier) is not on screen without scrolling")
    let target = !isOn(toggle)
    keepTail(Self.tapSettle) {
      XCTAssert(toggle.setSwitch(to: target, in: app), "\(identifier) did not switch")
      Thread.sleep(forTimeInterval: Self.tapSettle)
    }
  }

  private func hold(_ seconds: TimeInterval) {
    keep { Thread.sleep(forTimeInterval: seconds) }
  }

  // MARK: - Helpers

  /// Brings back a tab bar that minimized when a switch nudged the form. This happens between
  /// kept stretches, so the camera never sees it.
  private func restoreTabBar(showing tab: String) {
    guard !app.buttons[tab].firstMatch.isHittable else { return }
    scrollToTop()
  }

  private func tapTab(_ tab: String) {
    app.buttons[tab].firstMatch.tap()
  }

  private func waitForRisk(_ riskLevel: String) {
    let settled = expectation(
      for: NSPredicate(format: "label == %@", riskLevel),
      evaluatedWith: app.staticTexts["riskLevelText"]
    )
    wait(for: [settled], timeout: 10)
  }

  private func isOn(_ toggle: XCUIElement) -> Bool {
    (toggle.value as? String) == "1"
  }

  private func scrollToTop() {
    let collectionView = app.collectionViews.firstMatch
    guard collectionView.exists else { return }

    for _ in 0..<5 { collectionView.swipeDown() }
  }

  // MARK: - Recording handshake

  private func markerDirectory() throws -> URL {
    let path = ProcessInfo.processInfo.environment[Self.markerDirectoryKey]
    try XCTSkipIf(path == nil, "Run through Scripts/record-preview.sh to record a preview")
    return URL(filePath: path!)
  }

  private func startRolling() {
    FileManager.default.createFile(atPath: marker("ready").path, contents: nil)
    let recordingPath = marker("recording").path
    let recording = expectation(
      for: NSPredicate { _, _ in FileManager.default.fileExists(atPath: recordingPath) },
      evaluatedWith: nil
    )
    wait(for: [recording], timeout: 30)
    rollingSince = .now
  }

  /// Files the stretches kept during `steps` under a scene the storyboard knows by `name`.
  private func scene(_ name: String, _ steps: () -> Void) {
    currentScene = name
    steps()
  }

  private func keep(_ action: () -> Void) {
    let start = secondsRolling()
    action()
    segments.append((currentScene, start...secondsRolling()))
  }

  /// Keeps only the last moments of an action: the tap landing and what it changes, without the
  /// time XCUITest spends finding the element and waiting for the app to idle beforehand.
  private func keepTail(_ settle: TimeInterval, _ action: () -> Void) {
    action()
    let end = secondsRolling()
    segments.append((currentScene, max(0, end - settle - Self.tapLanding)...end))
  }

  private func secondsRolling() -> Double {
    let elapsed = ContinuousClock.now - rollingSince
    return Double(elapsed.components.seconds) + Double(elapsed.components.attoseconds) / 1e18
  }

  private func writeSegments() {
    let lines = segments.map { "\($0.seconds.lowerBound) \($0.seconds.upperBound) \($0.scene)" }
      .joined(separator: "\n")
    FileManager.default.createFile(atPath: marker("segments").path, contents: Data(lines.utf8))
  }

  private func marker(_ name: String) -> URL {
    markers.appending(path: name)
  }
}
// swiftlint:enable prefer_nimble
