import XCTest
import XCUITestKit

class BasePage {
  let app: XCUIApplication

  init(app: XCUIApplication) {
    self.app = app
  }

  @discardableResult
  func waitForElement(_ identifier: String, timeout: TimeInterval = 10) -> Bool {
    app.descendants(matching: .any)[identifier].waitForExistence(timeout: timeout)
  }

  @discardableResult
  func scrollTo(_ identifier: String) -> XCUIElement? {
    let element = app.descendants(matching: .any)[identifier]
    return scrollToElement(element)
  }

  func scrollToTop() {
    let collectionView = app.collectionViews.firstMatch
    guard collectionView.exists else { return }

    for _ in 0..<5 {
      collectionView.swipeDown()
    }
  }

  @discardableResult
  func setToggle(_ identifier: String, to value: Bool) -> Self {
    let element = app.switches[identifier]

    // If the switch is already accessible, scroll to it and toggle
    if element.waitForExistence(timeout: 2) {
      let collectionView = app.collectionViews.firstMatch
      if let control = collectionView.makeVisible(element: element) {
        toggleSwitch(control, to: value, named: identifier)
        return self
      }
      // Element exists but makeVisible failed — scroll to top and retry
      scrollToTop()
      if let control = collectionView.makeVisible(element: element) {
        toggleSwitch(control, to: value, named: identifier)
        return self
      }
      XCTFail("Could not scroll to toggle: \(identifier)")
      return self
    }

    // Element not in tree — scroll down from current position to find it
    let collectionView = app.collectionViews.firstMatch
    if collectionView.exists {
      if let control = collectionView.makeVisible(element: element) {
        toggleSwitch(control, to: value, named: identifier)
        return self
      }

      // Try from the top
      scrollToTop()
      if let control = collectionView.makeVisible(element: element) {
        toggleSwitch(control, to: value, named: identifier)
        return self
      }
    }

    XCTFail("Could not find toggle: \(identifier)")
    return self
  }

  func toggleValue(_ identifier: String) -> Bool {
    let element = app.switches[identifier]
    guard element.waitForExistence(timeout: 3) else { return false }
    return element.value as? String == "1"
  }

  /// Chooses an option from a menu-style picker, keeping the page object's chaining return.
  @discardableResult
  func selectPickerOption(picker: String, option: String) -> Self {
    app.selectPickerOption(option, in: picker)
    return self
  }

  func textLabel(_ identifier: String) -> String? {
    let element = app.staticTexts[identifier]
    guard element.waitForExistence(timeout: 5) else { return nil }
    return element.label
  }

  // MARK: - Private

  /// Toggle a switch to the desired state using the child switch control.
  ///
  /// A switch that never flips would otherwise surface much later as a wrong score, naming
  /// neither the toggle nor the step that lost it.
  private func toggleSwitch(_ element: XCUIElement, to value: Bool, named identifier: String) {
    if !element.setSwitch(to: value, in: app) {
      XCTFail("Could not set toggle \(identifier) to \(value)")
    }
  }

  /// Scrolls to an element in the collection view.
  /// First tries from current position, then from top.
  private func scrollToElement(_ element: XCUIElement) -> XCUIElement? {
    let collectionView = app.collectionViews.firstMatch
    guard collectionView.waitForExistence(timeout: 10) else { return nil }

    if let result = collectionView.makeVisible(element: element) {
      return result
    }

    scrollToTop()
    return collectionView.makeVisible(element: element)
  }
}
