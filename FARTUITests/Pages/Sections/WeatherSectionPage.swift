import XCTest

class WeatherSectionPage: BasePage {

  // MARK: - Field Accessors

  var vfrCeilingUnder3000Toggle: XCUIElement { app.switches["vfrCeilingUnder3000Toggle"] }
  var vfrVisibilityUnder5Toggle: XCUIElement { app.switches["vfrVisibilityUnder5Toggle"] }
  var vfrFlightPlanToggle: XCUIElement { app.switches["vfrFlightPlanToggle"] }
  var vfrFlightFollowingToggle: XCUIElement { app.switches["vfrFlightFollowingToggle"] }
  var ifrLowCeilingToggle: XCUIElement { app.switches["ifrLowCeilingToggle"] }
  var ifrLowVisibilityToggle: XCUIElement { app.switches["ifrLowVisibilityToggle"] }
  var ifrApproachTypePicker: XCUIElement { app.buttons["ifrApproachTypePicker"] }

  // MARK: - Flight Type

  @discardableResult
  func selectVFR() -> Self {
    selectPickerOption(picker: "flightTypePicker", option: "flightTypeVFR")
    // Wait for VFR-specific fields to render after flight type switch
    _ = app.switches["vfrCeilingUnder3000Toggle"].waitForExistence(timeout: 5)
    return self
  }

  @discardableResult
  func selectIFR() -> Self {
    selectPickerOption(picker: "flightTypePicker", option: "flightTypeIFR")
    // Wait for IFR-specific fields to render after flight type switch
    _ = app.switches["ifrLowCeilingToggle"].waitForExistence(timeout: 5)
    return self
  }

  // MARK: - VFR Toggles

  @discardableResult
  func setVFRCeilingUnder3000(_ value: Bool) -> Self {
    setToggle("vfrCeilingUnder3000Toggle", to: value)
  }

  @discardableResult
  func setVFRVisibilityUnder5(_ value: Bool) -> Self {
    setToggle("vfrVisibilityUnder5Toggle", to: value)
  }

  @discardableResult
  func setVFRFlightPlan(_ value: Bool) -> Self {
    setToggle("vfrFlightPlanToggle", to: value)
  }

  @discardableResult
  func setVFRFlightFollowing(_ value: Bool) -> Self {
    setToggle("vfrFlightFollowingToggle", to: value)
  }

  // MARK: - IFR Toggles

  @discardableResult
  func setIFRLowCeiling(_ value: Bool) -> Self {
    setToggle("ifrLowCeilingToggle", to: value)
  }

  @discardableResult
  func setIFRLowVisibility(_ value: Bool) -> Self {
    setToggle("ifrLowVisibilityToggle", to: value)
  }

  // MARK: - Shared

  @discardableResult
  func setNoDestWx(_ value: Bool) -> Self {
    setToggle("noDestWxToggle", to: value)
  }

  // MARK: - Approach Type

  @discardableResult
  func selectApproachPrecision() -> Self {
    selectPickerOption(
      picker: "ifrApproachTypePicker",
      option: "approachPrecision"
    )
  }

  @discardableResult
  func selectApproachNonprecision() -> Self {
    selectPickerOption(
      picker: "ifrApproachTypePicker",
      option: "approachNonprecision"
    )
  }

  @discardableResult
  func selectApproachCircling() -> Self {
    selectPickerOption(
      picker: "ifrApproachTypePicker",
      option: "approachCircling"
    )
  }

  @discardableResult
  func selectApproachNone() -> Self {
    selectPickerOption(
      picker: "ifrApproachTypePicker",
      option: "approachNone"
    )
  }

  // MARK: - Visibility Checks

  func isVFRToggleVisible() -> Bool {
    app.switches["vfrCeilingUnder3000Toggle"].waitForExistence(timeout: 2)
  }

  func isIFRToggleVisible() -> Bool {
    app.switches["ifrLowCeilingToggle"].waitForExistence(timeout: 2)
  }

  func isApproachPickerVisible() -> Bool {
    app.buttons["ifrApproachTypePicker"].waitForExistence(timeout: 2)
  }
}
