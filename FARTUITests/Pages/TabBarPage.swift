import XCTest
import XCUITestKit

class TabBarPage: BasePage {
  // swiftlint:disable:next type_contents_order
  enum Tab: String {
    case pilot = "Pilot"
    case questions = "Questions"
    case results = "Results"
    case about = "About"
  }

  /// Whether the app shows its two-column NavigationSplitView, with Pilot, Questions, and
  /// About tabs in the sidebar and Results always visible in the detail column. The app picks
  /// it for a regular-width window, as on iPad or iPhone Duo's inner display.
  var isTwoColumnLayout: Bool { app.windows.firstMatch.horizontalSizeClass == .regular }

  /// The bars that hold the tab buttons. On iPhone Duo's outer display the tab bar is
  /// vertical, and its buttons sit in a toolbar rather than in the tab bar element.
  private var tabContainers: XCUIElementQuery {
    app.descendants(matching: .any).matching(
      NSPredicate(
        format: "elementType IN %@",
        [XCUIElement.ElementType.tabBar.rawValue, XCUIElement.ElementType.toolbar.rawValue]
      )
    )
  }

  private func tabButton(_ tab: Tab) -> XCUIElement {
    tabContainers.buttons[tab.rawValue].firstMatch
  }

  @discardableResult
  func goTo(tab: Tab) -> Self {
    let button = tabButton(tab)
    if !button.exists { reveal(tab) }
    guard button.wait(timeout: 3) else {
      XCTFail("No \(tab.rawValue) tab button")
      return self
    }
    button.tap()
    if !button.wait(for: \.isSelected, toEqual: true, timeout: 5) {
      XCTFail("The \(tab.rawValue) tab was not selected")
    }
    return self
  }

  /// Brings a hidden tab button back on screen.
  private func reveal(_ tab: Tab) {
    // iOS 26 tabBarMinimizeBehavior(.onScrollDown) collapses the iPhone tab bar after
    // scrolling a long form, hiding its individual buttons. Scrolling back to the top
    // restores it.
    if app.collectionViews.firstMatch.exists { scrollToTop() }

    // On iPad the sidebar holding the tabs might be hidden.
    if isTwoColumnLayout && tab != .results && !tabButton(tab).exists {
      showSidebar()
    }
  }

  func goToPilotProfile() -> PilotProfilePage {
    if isTwoColumnLayout {
      // Pilot is the default sidebar tab — check if already visible
      if !app.descendants(matching: .any)["ratingPicker"].exists {
        goTo(tab: .pilot)
      }
    } else {
      goTo(tab: .pilot)
    }
    _ = waitForElement("ratingPicker", timeout: 30)

    // iOS 26 Liquid Glass: nudge the form content down so top-of-form
    // pickers clear the translucent navigation bar overlay.
    app.scrollIntoSafeBand(app.buttons["ratingPicker"])

    return PilotProfilePage(app: app)
  }

  func goToQuestionnaire() -> QuestionnairePage {
    goTo(tab: .questions)
    // Confirm the tab switch by waiting for a questionnaire-specific element.
    // On iPad, stale picker menus from the Pilot Profile can block the tab switch.
    let firstToggle = app.switches["lessThan50InTypeToggle"]
    if !firstToggle.wait(timeout: 5) {
      // Dismiss any open menus/popovers, wait for the Questions tab to become
      // tappable again (the overlay blocks it), then retry.
      app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
      tabButton(.questions).waitUntilHittable()
      goTo(tab: .questions)
      _ = firstToggle.wait(timeout: 10)
    }
    _ = app.collectionViews.firstMatch.wait(timeout: 10)
    scrollToTop()
    return QuestionnairePage(app: app)
  }

  func goToResults() -> ResultsPage {
    if !isTwoColumnLayout {
      goTo(tab: .results)
    }
    _ = waitForElement("scoreText", timeout: 10)
    return ResultsPage(app: app)
  }

  func goToAbout() -> AboutPage {
    goTo(tab: .about)
    _ = waitForElement("aboutDescriptionText", timeout: 10)
    return AboutPage(app: app)
  }

  // MARK: - iPad Sidebar

  /// Show the NavigationSplitView sidebar on iPad if it's hidden.
  private func showSidebar() {
    // If tab bar already visible in sidebar, no action needed
    if app.tabBars.firstMatch.exists { return }

    // Try the standard sidebar toggle button in the navigation bar
    let navBar = app.navigationBars.firstMatch
    if navBar.exists {
      let backButton = navBar.buttons.firstMatch
      if backButton.exists {
        backButton.tap()
        _ = app.tabBars.firstMatch.wait(timeout: 3)
        return
      }
    }

    // Fallback: swipe from left edge to reveal sidebar
    let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0.5))
    let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.4, dy: 0.5))
    start.press(forDuration: 0.01, thenDragTo: end)
    _ = app.tabBars.firstMatch.wait(timeout: 3)
  }
}
