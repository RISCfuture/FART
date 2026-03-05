import XCTest

class PilotSectionPage: BasePage {

  @discardableResult
  func setLessThan50InType(_ value: Bool) -> Self {
    setToggle("lessThan50InTypeToggle", to: value)
  }

  @discardableResult
  func setLessThan15InLast90(_ value: Bool) -> Self {
    setToggle("lessThan15InLast90Toggle", to: value)
  }

  @discardableResult
  func setAfterWork(_ value: Bool) -> Self {
    setToggle("afterWorkToggle", to: value)
  }

  @discardableResult
  func setLessThan8HrSleep(_ value: Bool) -> Self {
    setToggle("lessThan8HrSleepToggle", to: value)
  }

  @discardableResult
  func setDualInLast90(_ value: Bool) -> Self {
    setToggle("dualInLast90Toggle", to: value)
  }

  @discardableResult
  func setWingsInLast6Mo(_ value: Bool) -> Self {
    setToggle("wingsInLast6MoToggle", to: value)
  }

  @discardableResult
  func setIFRCurrent(_ value: Bool) -> Self {
    setToggle("ifrCurrentToggle", to: value)
  }

  @discardableResult
  func setAllToggles(
    lessThan50InType: Bool = false,
    lessThan15InLast90: Bool = false,
    afterWork: Bool = false,
    lessThan8HrSleep: Bool = false,
    dualInLast90: Bool = false,
    wingsInLast6Mo: Bool = false,
    ifrCurrent: Bool = false
  ) -> Self {
    self
      .setLessThan50InType(lessThan50InType)
      .setLessThan15InLast90(lessThan15InLast90)
      .setAfterWork(afterWork)
      .setLessThan8HrSleep(lessThan8HrSleep)
      .setDualInLast90(dualInLast90)
      .setWingsInLast6Mo(wingsInLast6Mo)
      .setIFRCurrent(ifrCurrent)
  }
}
