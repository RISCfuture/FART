import XCTest

class PilotProfilePage: BasePage {

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
    app.buttons["lowCeilingPicker"].waitForExistence(timeout: 2)
  }

  func isLowVisibilityPickerVisible() -> Bool {
    app.buttons["lowVisibilityPicker"].waitForExistence(timeout: 2)
  }
}
