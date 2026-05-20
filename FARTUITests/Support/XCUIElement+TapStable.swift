import XCTest

@MainActor
extension XCUIElement {
  /// Tap an element via center coordinate after waiting for its frame to settle.
  ///
  /// Under simulator load, SwiftUI Form/List views can be mid-relayout when XCUITest
  /// computes an activation point — the system then refuses the tap with
  /// "Activation point invalid and no suggested hit points." Polling for two
  /// consecutive identical frame reads guarantees we tap a settled target, and
  /// tapping via `coordinate(0.5, 0.5)` skips activation-point resolution entirely.
  @discardableResult
  func tapStable(
    timeout: TimeInterval = UITestTimeout.element,
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> Self {
    waitForFrameStability(
      requireHittable: true, timeout: timeout, file: file, line: line)
    coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    return self
  }

  /// Like `tapStable` but does not require `isHittable`.
  ///
  /// Use for SwiftUI controls (e.g. `.pickerStyle(.navigationLink)` rows) whose
  /// backing element can report `isHittable = false` for the entire wait window
  /// while still being visibly tappable.
  @discardableResult
  func coordinateTapWhenFrameStable(
    timeout: TimeInterval = UITestTimeout.element,
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> Self {
    waitForFrameStability(
      requireHittable: false, timeout: timeout, file: file, line: line)
    coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    return self
  }

  private func waitForFrameStability(
    requireHittable: Bool,
    timeout: TimeInterval,
    file: StaticString,
    line: UInt
  ) {
    let deadline = Date().addingTimeInterval(timeout)
    var lastFrame: CGRect = .null
    while Date() < deadline {
      guard exists else {
        RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        continue
      }
      let current = frame
      if !current.isEmpty && current == lastFrame
        && (!requireHittable || isHittable)
      {
        return
      }
      lastFrame = current
      RunLoop.current.run(until: Date().addingTimeInterval(0.1))
    }
    if !exists {
      XCTFail(
        "Element did not exist within \(timeout)s for stable tap", file: file, line: line)
    }
  }
}
