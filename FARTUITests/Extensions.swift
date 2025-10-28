import XCTest

extension XCUIElement {
  func toggleOn() {
    guard switches["0"].exists else { return }
    switches["0"].firstMatch.tap()
  }

  func toggleOff() {
    guard switches["1"].exists else { return }
    switches["1"].firstMatch.tap()
  }

  var isVisible: Bool {
    guard self.exists && !self.frame.isEmpty else { return false }
    return XCUIApplication().windows.element(boundBy: 0).frame.contains(self.frame)
  }

  func makeVisible(element: XCUIElement) -> XCUIElement? {
    if self.elementType == .scrollView || self.elementType == .collectionView
      || self.elementType == .table
    {
      let visible = self.scroll(to: element) || self.swipe(to: element)
      return visible ? element : nil
    }
    return self.swipe(to: element) ? element : nil
  }

  // Use the collection view's scrollToItem method via coordinate-based scrolling
  private func scroll(to element: XCUIElement) -> Bool {
    var attempts = 0

    while !element.isVisible && attempts < 10 {
      let startCoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.6))
      let endCoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
      startCoordinate.press(forDuration: 0.01, thenDragTo: endCoordinate)
      attempts += 1
    }

    return element.isVisible
  }

  // Fallback to swipe-based scrolling with limits
  private func swipe(to element: XCUIElement) -> Bool {
    var attempts = 0

    while !element.isVisible && attempts < 10 {
      swipeUp()
      attempts += 1
    }

    return element.isVisible
  }
}
