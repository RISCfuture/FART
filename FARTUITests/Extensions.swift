import XCTest

extension XCUIElement {
  var isVisible: Bool {
    guard exists else { return false }
    // On smaller screens (iPhone SE), isHittable can return false even when
    // the element is visible but near screen edges. Check frame instead.
    let window = XCUIApplication().windows.firstMatch
    guard window.exists else { return isHittable }
    let windowFrame = window.frame
    let elementFrame = frame
    // Element is visible if its center is within the window bounds (with margin for tab bar)
    let centerY = elementFrame.midY
    let tabBarMargin: CGFloat = 100  // Account for tab bar height
    return centerY > 0 && centerY < (windowFrame.height - tabBarMargin)
  }

  func toggleOn() {
    guard switches["0"].exists else { return }
    switches["0"].firstMatch.tap()
  }

  func toggleOff() {
    guard switches["1"].exists else { return }
    switches["1"].firstMatch.tap()
  }

  func makeVisible(element: XCUIElement) -> XCUIElement? {
    // If already visible, return immediately
    if element.isVisible { return element }

    // Element must at least exist to scroll to it
    guard element.exists else { return nil }

    // Try scrolling to make it visible
    if self.elementType == .scrollView || self.elementType == .collectionView
      || self.elementType == .table
    {
      if scrollToElement(element) { return element }
    }
    return nil
  }

  private func scrollToElement(_ element: XCUIElement) -> Bool {
    // Try scrolling down first (swipe up) - increased for smaller screens like iPhone SE
    for _ in 0..<10 {
      if element.isVisible { return true }
      swipeUp()
    }

    // If not found, scroll back up past starting point (swipe down)
    for _ in 0..<20 {
      if element.isVisible { return true }
      swipeDown()
    }

    return element.isVisible
  }
}
