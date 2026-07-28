import XCTest
import XCUITestKit

// App-specific UI-test helpers shared between the FARTUITests and "Generate Screenshots" targets,
// both of which link XCUITestKit. Anything general enough to serve another app belongs there
// instead; this is only what the questionnaire's switches need.
extension XCUIElement {
  /// Sets this switch on or off, returning whether it ended up in the wanted state.
  ///
  /// A SwiftUI switch publishes the state it is *leaving* as a child element, so that child
  /// disappearing is what proves the tap registered — reading `value` straight back races the
  /// update. Taps are plain `tap()`s because `forceTap()`'s coordinate fallback does not flip a
  /// SwiftUI switch on iOS 26. Each attempt first nudges the row clear of the translucent
  /// navigation and tab bars, which report an element as hittable while swallowing its taps.
  @discardableResult
  func setSwitch(to value: Bool, in app: XCUIApplication, maxAttempts: UInt = 5) -> Bool {
    let leaving = value ? "0" : "1"
    let wanted = NSPredicate(format: "value == %@", value ? "1" : "0")

    for _ in 0..<maxAttempts {
      guard switches[leaving].exists else { return true }

      app.scrollIntoSafeBand(self)
      waitForStableFrame()
      switches[leaving].firstMatch.tap()
      if waitFor(wanted, timeout: ScaledTimeouts.short) { return true }
    }

    return !switches[leaving].exists
  }

  /// Polls until this element's frame stops moving.
  ///
  /// Scrolling a row into place leaves the form decelerating, and a tap issued into a moving list
  /// lands on whichever row slides under it instead — the switch never flips, and nothing about
  /// the tap reports a failure.
  private func waitForStableFrame(timeout: TimeInterval = 2, pollInterval: TimeInterval = 0.1) {
    let requiredStableReads = 2
    let deadline = Date().addingTimeInterval(timeout)
    var previous = CGRect.null
    var stableReads = 0

    while Date() < deadline {
      let current = frame
      if current == previous {
        stableReads += 1
        if stableReads >= requiredStableReads { return }
      } else {
        stableReads = 0
        previous = current
      }
      Thread.sleep(forTimeInterval: pollInterval)
    }
  }
}
