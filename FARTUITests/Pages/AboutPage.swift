import XCTest

class AboutPage: BasePage {

  func descriptionText() -> String {
    let element = app.descendants(matching: .any)["aboutDescriptionText"]
    // swiftlint:disable:next prefer_nimble
    XCTAssertTrue(element.waitForExistence(timeout: 10), "Description text not found")
    return element.label
  }

  func copyrightText() -> String {
    let element = app.descendants(matching: .any)["aboutCopyrightText"]
    // swiftlint:disable:next prefer_nimble
    XCTAssertTrue(element.waitForExistence(timeout: 10), "Copyright text not found")
    return element.label
  }

  func iconCreditsText() -> String {
    let element = app.descendants(matching: .any)["aboutIconCreditsText"]
    // swiftlint:disable:next prefer_nimble
    XCTAssertTrue(element.waitForExistence(timeout: 10), "Icon credits text not found")
    return element.label
  }

  func moreInfoButtonLabel() -> String {
    let element = app.descendants(matching: .any)["moreInfoButton"]
    // swiftlint:disable:next prefer_nimble
    XCTAssertTrue(element.waitForExistence(timeout: 10), "More info button not found")
    return element.label
  }

  func viewSourceCodeButtonLabel() -> String {
    let element = app.descendants(matching: .any)["viewSourceCodeButton"]
    // swiftlint:disable:next prefer_nimble
    XCTAssertTrue(element.waitForExistence(timeout: 10), "View source code button not found")
    return element.label
  }
}
