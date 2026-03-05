import XCTest

class ResultsPage: BasePage {

  func scoreValue() -> String {
    let element = app.staticTexts["scoreText"]
    XCTAssertTrue(element.waitForExistence(timeout: 5), "Score text not found")
    return element.label
  }

  func riskLevel() -> String {
    let element = app.staticTexts["riskLevelText"]
    XCTAssertTrue(element.waitForExistence(timeout: 5), "Risk level text not found")
    return element.label
  }

  func riskDescription() -> String {
    let element = app.staticTexts["riskDescriptionText"]
    XCTAssertTrue(element.waitForExistence(timeout: 5), "Risk description text not found")
    return element.label
  }

  func assertResults(score: String, riskLevel expectedRisk: String) {
    let scoreElement = app.staticTexts["scoreText"]
    XCTAssertTrue(scoreElement.waitForExistence(timeout: 5), "Score text not found")
    XCTAssertEqual(scoreElement.label, score, "Expected score \(score) but got \(scoreElement.label)")

    let riskElement = app.staticTexts["riskLevelText"]
    XCTAssertTrue(riskElement.waitForExistence(timeout: 5), "Risk level text not found")
    XCTAssertEqual(
      riskElement.label, expectedRisk,
      "Expected \(expectedRisk) but got \(riskElement.label)"
    )
  }
}
