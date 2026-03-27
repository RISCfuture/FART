import XCTest

class PilotProfilePage: BasePage {

  @discardableResult
  func selectVFR() -> Self {
    selectPickerOption(picker: "ratingPicker", option: "ratingVFR", optionLabel: "VFR")
  }

  @discardableResult
  func selectIFR() -> Self {
    selectPickerOption(picker: "ratingPicker", option: "ratingIFR", optionLabel: "IFR")
  }

  @discardableResult
  func selectUnder100Hours() -> Self {
    selectPickerOption(picker: "hoursPicker", option: "hoursUnder100", optionLabel: "< 100")
  }

  @discardableResult
  func selectOver100Hours() -> Self {
    selectPickerOption(picker: "hoursPicker", option: "hoursOver100", optionLabel: "> 100")
  }

  func isLowCeilingPickerVisible() -> Bool {
    app.buttons["lowCeilingPicker"].waitForExistence(timeout: 2)
  }

  func isLowVisibilityPickerVisible() -> Bool {
    app.buttons["lowVisibilityPicker"].waitForExistence(timeout: 2)
  }
}
