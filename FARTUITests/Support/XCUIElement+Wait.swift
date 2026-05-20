import XCTest

@MainActor
extension XCUIElement {
  /// Wait for the element to appear and fail the test if it does not.
  @discardableResult
  func assertExists(
    timeout: TimeInterval = UITestTimeout.element,
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> Self {
    if !waitForExistence(timeout: timeout) {
      XCTFail("Element did not appear within \(timeout)s: \(self)", file: file, line: line)
    }
    return self
  }

  /// Wait for the element to no longer exist. Fails the test if it remains.
  @discardableResult
  func assertHidden(
    timeout: TimeInterval = UITestTimeout.element,
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> Self {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
      if !exists { return self }
      RunLoop.current.run(until: Date().addingTimeInterval(0.1))
    }
    if exists {
      XCTFail("Element did not disappear within \(timeout)s: \(self)", file: file, line: line)
    }
    return self
  }

  /// Assert that the element never appears within the given window.
  ///
  /// Guards against state that surfaces a beat after the trigger that produced it.
  /// Uses `waitForExistence` returning false rather than `XCTAssertFalse(exists)`
  /// — covers the whole window instead of a single instant.
  @discardableResult
  func assertNeverAppears(
    within window: TimeInterval = UITestTimeout.short,
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> Self {
    if waitForExistence(timeout: window) {
      XCTFail(
        "Element unexpectedly appeared within \(window)s: \(self)", file: file, line: line)
    }
    return self
  }

  /// Wait for a predicate to evaluate true on this element. Returns whether
  /// the predicate was satisfied within the timeout (does not assert).
  func waitFor(
    _ predicate: NSPredicate,
    timeout: TimeInterval = UITestTimeout.element
  ) -> Bool {
    let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
    return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
  }
}
