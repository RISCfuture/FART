import XCTest

class ResultsPage: BasePage {

  /// The score readout is one merged accessibility element, so its number is the element's
  /// value rather than its label.
  private var scoreElement: XCUIElement { app.descendants(matching: .any)["scoreText"] }

  func riskLevel() -> String {
    let element = app.staticTexts["riskLevelText"]
    // swiftlint:disable:next prefer_nimble
    XCTAssertTrue(element.waitForExistence(timeout: 5), "Risk level text not found")
    return element.label
  }

  func riskDescription() -> String {
    let element = app.staticTexts["riskDescriptionText"]
    // swiftlint:disable:next prefer_nimble
    XCTAssertTrue(element.waitForExistence(timeout: 5), "Risk description text not found")
    return element.label
  }

  func assertResults(score: String, riskLevel expectedRisk: String) {
    // swiftlint:disable:next prefer_nimble
    XCTAssertTrue(scoreElement.waitForExistence(timeout: 5), "Score gauge not found")
    let spokenScore = scoreElement.value as? String ?? ""
    // swiftlint:disable:next prefer_nimble
    XCTAssertEqual(
      digits(in: spokenScore),
      score,
      "Expected score \(score) but got \(spokenScore)"
    )

    let riskElement = app.staticTexts["riskLevelText"]
    // swiftlint:disable:next prefer_nimble
    XCTAssertTrue(riskElement.waitForExistence(timeout: 5), "Risk level text not found")
    // swiftlint:disable:next prefer_nimble
    XCTAssertEqual(
      riskElement.label,
      expectedRisk,
      "Expected \(expectedRisk) but got \(riskElement.label)"
    )
  }
}
