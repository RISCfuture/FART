import XCTest

// swiftlint:disable prefer_nimble
final class AboutTests: FARTUITestCase {

  @MainActor
  func testAboutViewDisplaysCorrectContent() throws {
    let about = tabBar.goToAbout()

    let description = about.descriptionText()
    XCTAssertTrue(
      description.contains("FAA Safety Team"),
      "Expected description to mention FAA Safety Team"
    )
    XCTAssertTrue(
      description.contains("Flight Risk Assessment Tool"),
      "Expected description to mention Flight Risk Assessment Tool"
    )

    let copyright = about.copyrightText()
    XCTAssertTrue(
      copyright.contains("Tim Morgan"),
      "Expected copyright to mention Tim Morgan"
    )
    XCTAssertTrue(
      copyright.contains("MIT License"),
      "Expected copyright to mention MIT License"
    )

    let iconCredits = about.iconCreditsText()
    XCTAssertTrue(
      iconCredits.contains("Noun Project"),
      "Expected icon credits to mention Noun Project"
    )

    let moreInfo = about.moreInfoButtonLabel()
    XCTAssertTrue(
      moreInfo.contains("FAAST FRAT"),
      "Expected more info button to mention FAAST FRAT"
    )

    let sourceCode = about.viewSourceCodeButtonLabel()
    XCTAssertTrue(
      sourceCode.contains("source code"),
      "Expected source code button to mention source code"
    )
  }
}
// swiftlint:enable prefer_nimble
