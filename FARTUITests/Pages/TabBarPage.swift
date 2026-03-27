import XCTest

class TabBarPage: BasePage {
  // swiftlint:disable:next type_contents_order
  enum Tab: String {
    case pilot = "Pilot"
    case questions = "Questions"
    case results = "Results"
    case about = "About"
  }

  /// iPad uses a two-column NavigationSplitView with Pilot, Questions, and About tabs
  /// in the sidebar. Results is always visible in the detail column.
  lazy var isIPad: Bool = {
    !app.tabBars.buttons["Results"].waitForExistence(timeout: 3)
  }()

  @discardableResult
  func goTo(tab: Tab) -> Self {
    // Try standard tab bar button by name (works on iPhone)
    let tabBarButton = app.tabBars.buttons[tab.rawValue]
    if tabBarButton.waitForExistence(timeout: 2) {
      tabBarButton.tap()
      return self
    }

    if isIPad && (tab == .pilot || tab == .questions) {
      // Sidebar might be hidden — try showing it
      showSidebar()

      let tabBar = app.tabBars.firstMatch
      if tabBar.waitForExistence(timeout: 3) {
        let sidebarButton = tabBar.buttons[tab.rawValue]
        if sidebarButton.waitForExistence(timeout: 2) {
          sidebarButton.tap()
          return self
        }
      }
    }

    // Fallback: try any button matching the tab name
    let button = app.buttons[tab.rawValue]
    if button.waitForExistence(timeout: 2) {
      button.firstMatch.tap()
    }

    return self
  }

  func goToPilotProfile() -> PilotProfilePage {
    if isIPad {
      // Pilot is the default sidebar tab — check if already visible
      if !app.descendants(matching: .any)["ratingPicker"].waitForExistence(timeout: 3) {
        goTo(tab: .pilot)
      }
    } else {
      goTo(tab: .pilot)
    }
    _ = waitForElement("ratingPicker", timeout: 30)

    // iOS 26 Liquid Glass: nudge the form content down so top-of-form
    // pickers clear the translucent navigation bar overlay.
    let collectionView = app.collectionViews.firstMatch
    if collectionView.waitForExistence(timeout: 5) {
      let ratingPicker = app.buttons["ratingPicker"]
      if ratingPicker.exists {
        ensureHittable(ratingPicker, in: collectionView)
      }
    }

    return PilotProfilePage(app: app)
  }

  func goToQuestionnaire() -> QuestionnairePage {
    goTo(tab: .questions)
    // Confirm the tab switch by waiting for a questionnaire-specific element.
    // On iPad, stale picker menus from the Pilot Profile can block the tab switch.
    let firstToggle = app.switches["lessThan50InTypeToggle"]
    if !firstToggle.waitForExistence(timeout: 5) {
      // Dismiss any open menus/popovers and retry
      app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
      sleep(1)
      goTo(tab: .questions)
      _ = firstToggle.waitForExistence(timeout: 10)
    }
    _ = app.collectionViews.firstMatch.waitForExistence(timeout: 10)
    scrollToTop()
    return QuestionnairePage(app: app)
  }

  func goToResults() -> ResultsPage {
    if !isIPad {
      goTo(tab: .results)
    }
    _ = waitForElement("scoreText", timeout: 10)
    return ResultsPage(app: app)
  }

  func goToAbout() -> AboutPage {
    if isIPad {
      // iPad shows About via toolbar button → sheet
      let aboutButton = app.buttons["aboutButton"]
      if !aboutButton.waitForExistence(timeout: 5) {
        // Button might be in the navigation bar — try the detail column's nav bar
        let navBarButton = app.navigationBars.buttons["aboutButton"]
        if navBarButton.waitForExistence(timeout: 3) {
          navBarButton.tap()
        }
      } else {
        aboutButton.tap()
      }
    } else {
      goTo(tab: .about)
    }
    _ = waitForElement("aboutDescriptionText", timeout: 10)
    return AboutPage(app: app)
  }

  // MARK: - iPad Sidebar

  /// Show the NavigationSplitView sidebar on iPad if it's hidden.
  private func showSidebar() {
    // If tab bar already visible in sidebar, no action needed
    if app.tabBars.firstMatch.waitForExistence(timeout: 1) { return }

    // Try the standard sidebar toggle button in the navigation bar
    let navBar = app.navigationBars.firstMatch
    if navBar.exists {
      let backButton = navBar.buttons.firstMatch
      if backButton.exists {
        backButton.tap()
        _ = app.tabBars.firstMatch.waitForExistence(timeout: 3)
        return
      }
    }

    // Fallback: swipe from left edge to reveal sidebar
    let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0.5))
    let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.4, dy: 0.5))
    start.press(forDuration: 0.01, thenDragTo: end)
    _ = app.tabBars.firstMatch.waitForExistence(timeout: 3)
  }
}
