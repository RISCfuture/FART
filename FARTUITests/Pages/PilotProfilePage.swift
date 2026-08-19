import XCTest
import XCUITestKit

class PilotProfilePage: BasePage {

  var lowCeilingPicker: XCUIElement { app.buttons["lowCeilingPicker"] }
  var lowVisibilityPicker: XCUIElement { app.buttons["lowVisibilityPicker"] }

  var shortRunwayField: XCUIElement { app.textFields["shortRunwayField"] }
  var strongWindsField: XCUIElement { app.textFields["strongWindsField"] }
  var strongCrosswindsField: XCUIElement { app.textFields["strongCrosswindsField"] }

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

  /// Types `number` over whatever a threshold field holds, then ends editing so the field hands
  /// the say back to the stored value.
  ///
  /// The field selects its value when it takes focus, so the digits replace it rather than
  /// joining it. Editing is ended with a newline because nothing else here does: the whole-number
  /// pad carries no return key of its own to press, it covers the tab bar, and the form dismisses
  /// it on neither a scroll nor a tap away.
  @discardableResult
  func enter(_ number: String, into field: XCUIElement) -> Self {
    guard let visible = scrollTo(field) else {
      XCTFail("Could not scroll to the threshold field")
      return self
    }

    visible.forceTap()
    // swiftlint:disable:next prefer_nimble
    XCTAssertTrue(
      app.keyboards.firstMatch.waitForExistence(timeout: 5),
      "Keypad never surfaced for the threshold field"
    )
    visible.typeText(number)
    visible.typeText("\n")
    return self
  }

  /// The number a threshold field shows, as its digits alone: the unit sits beside the field
  /// rather than in it, and the grouping separator is the locale's business.
  func enteredNumber(in field: XCUIElement) -> String {
    guard field.waitForExistence(timeout: 5) else { return "" }
    return digits(in: field.value as? String ?? "")
  }

  func isLowCeilingPickerVisible() -> Bool {
    lowCeilingPicker.waitForExistence(timeout: 2)
  }

  func isLowVisibilityPickerVisible() -> Bool {
    lowVisibilityPicker.waitForExistence(timeout: 2)
  }
}
