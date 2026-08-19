import XCTest

class AirportSectionPage: BasePage {

  /// The runway length the short-runway question asks about, which is the pilot's own threshold
  /// written into the question.
  func shortRunwayThreshold() -> String {
    guard let toggle = scrollTo(app.switches["shortRunwayToggle"]) else { return "" }
    return digits(in: toggle.label)
  }

  @discardableResult
  func setNontowered(_ value: Bool) -> Self {
    setToggle("nontoweredToggle", to: value)
  }

  @discardableResult
  func setShortRunway(_ value: Bool) -> Self {
    setToggle("shortRunwayToggle", to: value)
  }

  @discardableResult
  func setWetOrSoftField(_ value: Bool) -> Self {
    setToggle("wetOrSoftFieldToggle", to: value)
  }

  @discardableResult
  func setRunwayObstacles(_ value: Bool) -> Self {
    setToggle("runwayObstaclesToggle", to: value)
  }

  @discardableResult
  func setAllToggles(
    nontowered: Bool = false,
    shortRunway: Bool = false,
    wetOrSoftField: Bool = false,
    runwayObstacles: Bool = false
  ) -> Self {
    self
      .setNontowered(nontowered)
      .setShortRunway(shortRunway)
      .setWetOrSoftField(wetOrSoftField)
      .setRunwayObstacles(runwayObstacles)
  }
}
