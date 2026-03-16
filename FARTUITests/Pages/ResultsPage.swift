import XCTest

class ResultsPage: BasePage {

  func scoreValue() -> String {
    let element = app.staticTexts["scoreText"]
    // swiftlint:disable:next prefer_nimble
    XCTAssertTrue(element.waitForExistence(timeout: 5), "Score text not found")
    return element.label
  }

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
    let scoreElement = app.staticTexts["scoreText"]
    // swiftlint:disable:next prefer_nimble
    XCTAssertTrue(scoreElement.waitForExistence(timeout: 5), "Score text not found")
    // swiftlint:disable:next prefer_nimble
    XCTAssertEqual(
      scoreElement.label,
      score,
      "Expected score \(score) but got \(scoreElement.label)"
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
