import XCTest

@MainActor
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
        toggleSwitch(control, to: value)
        return self
      }
      // Element exists but makeVisible failed — scroll to top and retry
      scrollToTop()
      if let control = collectionView.makeVisible(element: element) {
        toggleSwitch(control, to: value)
        return self
      }
      XCTFail("Could not scroll to toggle: \(identifier)")
      return self
    }

    // Element not in tree — scroll down from current position to find it
    let collectionView = app.collectionViews.firstMatch
    if collectionView.exists {
      if let control = collectionView.makeVisible(element: element) {
        toggleSwitch(control, to: value)
        return self
      }

      // Try from the top
      scrollToTop()
      if let control = collectionView.makeVisible(element: element) {
        toggleSwitch(control, to: value)
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

  @discardableResult
  func selectPickerOption(picker: String, option: String, optionLabel: String? = nil) -> Self {
    let pickerButton = app.buttons[picker]

    // If picker is already in the tree, scroll to it
    if pickerButton.waitForExistence(timeout: 2) {
      let collectionView = app.collectionViews.firstMatch
      if collectionView.exists {
        _ = collectionView.makeVisible(element: pickerButton)
        ensureHittable(pickerButton, in: collectionView)
      }
    } else {
      // Picker not in tree — scroll down to find it (lazy-loaded off-screen)
      let collectionView = app.collectionViews.firstMatch
      if collectionView.exists {
        if collectionView.makeVisible(element: pickerButton) == nil {
          scrollToTop()
          _ = collectionView.makeVisible(element: pickerButton)
        }
        ensureHittable(pickerButton, in: collectionView)
      }

      guard pickerButton.exists else {
        XCTFail("Could not find picker: \(picker)")
        return self
      }
    }

    // Tap picker and find option — retry once if menu doesn't open
    for attempt in 0..<2 {
      if attempt > 0 {
        // Dismiss any partial state, then retry
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1)).tap()
        sleep(1)
        forceTap(pickerButton)
      } else {
        forceTap(pickerButton)
      }

      // Find and tap the option — try buttons first, then any element type
      let allButtons = app.buttons.matching(identifier: option)
      if allButtons.firstMatch.waitForExistence(timeout: 5) {
        for i in 0..<allButtons.count {
          let button = allButtons.element(boundBy: i)
          if button.exists && button.isHittable {
            button.tap()
            return self
          }
        }
        forceTap(allButtons.firstMatch)
        return self
      }

      // Fallback: match any element type by identifier
      let anyOption = app.descendants(matching: .any)[option]
      if anyOption.waitForExistence(timeout: 3) {
        forceTap(anyOption)
        return self
      }

      // Fallback: match by label text (iOS 26 picker menus may not carry identifiers)
      if let label = optionLabel {
        let labelPredicate = NSPredicate(format: "label == %@", label)
        let labelButton = app.buttons.matching(labelPredicate).firstMatch
        if labelButton.waitForExistence(timeout: 3) {
          forceTap(labelButton)
          return self
        }
      }
    }

    XCTFail("Could not find picker option: \(option)")
    return self
  }

  func textLabel(_ identifier: String) -> String? {
    let element = app.staticTexts[identifier]
    guard element.waitForExistence(timeout: 5) else { return nil }
    return element.label
  }

  // MARK: - Private

  /// Nudge content to make an element hittable.
  /// Handles two cases on iOS 26:
  /// - Top: Liquid Glass nav bar overlays elements near the top → nudge content down
  /// - Bottom: Tab bar/home indicator overlays elements near the bottom → nudge content up
  func ensureHittable(_ element: XCUIElement, in collectionView: XCUIElement) {
    guard element.exists, !element.isHittable else { return }
    let windowHeight = app.windows.firstMatch.frame.height

    for _ in 0..<3 {
      if element.frame.minY < windowHeight * 0.35 {
        // Element near top — nudge content down
        let start = collectionView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
        let end = collectionView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.45))
        start.press(forDuration: 0.01, thenDragTo: end)
      } else if element.frame.maxY > windowHeight * 0.75 {
        // Element near bottom — nudge content up
        let start = collectionView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.7))
        let end = collectionView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.55))
        start.press(forDuration: 0.01, thenDragTo: end)
      } else {
        break
      }
      if element.isHittable || !element.exists { return }
    }
  }

  /// Tap an element, falling back to coordinate-based tap when not hittable.
  /// Works around iOS 26 Liquid Glass overlay making elements "not hittable"
  /// or producing invalid hit points.
  func forceTap(_ element: XCUIElement) {
    if element.isHittable {
      element.tap()
    } else {
      element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }
  }

  /// Toggle a switch to the desired state using the child switch control.
  /// Retries with scroll nudges if the tap doesn't register (iOS 26 Liquid Glass).
  private func toggleSwitch(_ element: XCUIElement, to value: Bool) {
    let targetValue = value ? "0" : "1"
    let childSwitch = element.switches[targetValue]
    guard childSwitch.exists else { return }

    // Try standard tap first
    childSwitch.firstMatch.tap()

    // If tap registered, we're done
    guard element.switches[targetValue].exists else { return }

    // Tap didn't register — nudge content to move element away from Liquid Glass overlay
    let collectionView = app.collectionViews.firstMatch
    guard collectionView.exists else { return }
    let windowMidY = app.windows.firstMatch.frame.height / 2

    for _ in 0..<3 {
      let elementMidY = element.frame.midY
      if elementMidY < windowMidY {
        // Element in top half — nudge content down
        let start = collectionView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.35))
        let end = collectionView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        start.press(forDuration: 0.01, thenDragTo: end)
      } else {
        // Element in bottom half — nudge content up
        let start = collectionView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.65))
        let end = collectionView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        start.press(forDuration: 0.01, thenDragTo: end)
      }

      // Retry with standard tap (forceTap doesn't toggle SwiftUI switches on iOS 26)
      guard element.switches[targetValue].exists else { return }
      element.switches[targetValue].firstMatch.tap()
      guard element.switches[targetValue].exists else { return }
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
