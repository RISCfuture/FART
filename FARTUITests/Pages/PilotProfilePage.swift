import XCTest

class PilotProfilePage: BasePage {

  var lowCeilingPicker: XCUIElement { app.buttons["lowCeilingPicker"] }
  var lowVisibilityPicker: XCUIElement { app.buttons["lowVisibilityPicker"] }

  @discardableResult
  func selectVFR() -> Self {
    selectPickerOption(picker: "ratingPicker", option: "ratingVFR")
  }

  @discardableResult
  func selectIFR() -> Self {
    selectPickerOption(picker: "ratingPicker", option: "ratingIFR")
  }

  @discardableResult
  func selectUnder100Hours() -> Self {
    selectPickerOption(picker: "hoursPicker", option: "hoursUnder100")
  }

  @discardableResult
  func selectOver100Hours() -> Self {
    selectPickerOption(picker: "hoursPicker", option: "hoursOver100")
  }

  func isLowCeilingPickerVisible() -> Bool {
    lowCeilingPicker.waitForExistence(timeout: 2)
  }

  func isLowVisibilityPickerVisible() -> Bool {
    lowVisibilityPicker.waitForExistence(timeout: 2)
  }
}
