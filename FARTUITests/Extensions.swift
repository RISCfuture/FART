import XCTest
import XCUITestKit

// App-specific UI-test helpers shared between the FARTUITests and "Generate Screenshots" targets,
// both of which link XCUITestKit. Anything general enough to serve another app belongs there
// instead; this is only what the questionnaire's switches need.
extension XCUIElement {
  /// Sets this switch on or off, returning whether it ended up in the wanted state.
  ///
  /// A SwiftUI switch publishes the state it is *leaving* as a child element, so that child
  /// disappearing is what proves the gesture registered — reading `value` straight back races the
  /// update. Each attempt first nudges the row clear of the translucent navigation and tab bars,
  /// which report an element as hittable while swallowing its taps.
  @discardableResult
  func setSwitch(to value: Bool, in app: XCUIApplication, maxAttempts: UInt = 5) -> Bool {
    let leaving = value ? "0" : "1"
    let wanted = NSPredicate(format: "value == %@", value ? "1" : "0")

    for attempt in 0..<maxAttempts {
      guard switches[leaving].exists else { return true }

      app.scrollIntoSafeBand(self)
      waitForStableFrame()
      switches[leaving].firstMatch.press(forDuration: holdDuration(forAttempt: attempt))
      if waitFor(wanted, timeout: ScaledTimeouts.short) { return true }
    }

    return !switches[leaving].exists
  }

  /// How long to hold the touch down on a given attempt, in seconds.
  ///
  /// An iOS 26 SwiftUI switch drops a synthesized touch that goes down and up in the same instant,
  /// and how long it needs held varies from row to row, so each retry holds longer than the last.
  /// Every value stays under the half-second that would turn the gesture into a long press.
  private func holdDuration(forAttempt attempt: UInt) -> TimeInterval {
    let durations: [TimeInterval] = [0.1, 0.2, 0.35, 0.45]
    return durations[min(Int(attempt), durations.count - 1)]
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
