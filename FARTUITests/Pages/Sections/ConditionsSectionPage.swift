import XCTest

class ConditionsSectionPage: BasePage {

  @discardableResult
  func setNight(_ value: Bool) -> Self {
    setToggle("nightToggle", to: value)
  }

  @discardableResult
  func setStrongWinds(_ value: Bool) -> Self {
    setToggle("strongWindsToggle", to: value)
  }

  @discardableResult
  func setStrongCrosswinds(_ value: Bool) -> Self {
    setToggle("strongCrosswindsToggle", to: value)
  }

  @discardableResult
  func setMountainous(_ value: Bool) -> Self {
    setToggle("mountainousToggle", to: value)
  }

  @discardableResult
  func setAllToggles(
    night: Bool = false,
    strongWinds: Bool = false,
    strongCrosswinds: Bool = false,
    mountainous: Bool = false
  ) -> Self {
    self
      .setNight(night)
      .setStrongWinds(strongWinds)
      .setStrongCrosswinds(strongCrosswinds)
      .setMountainous(mountainous)
  }
}
