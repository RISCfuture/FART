import XCTest

final class IntegrationTests: FARTUITestCase {

  // MARK: - VFR >100h (low ≤20, moderate 21-25, high >25)

  @MainActor
  func testVFROver100LowRisk() throws {
    // Score 11: lessThan50InType(5)+afterWork(4)+lessThan8HrSleep(5)+wingsInLast6Mo(-3)
    tabBar.goToPilotProfile()
      .selectVFR()
      .selectOver100Hours()

    let q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setLessThan50InType(true)
      .setAfterWork(true)
      .setLessThan8HrSleep(true)
      .setWingsInLast6Mo(true)

    tabBar.goToResults()
      .assertResults(score: "11", riskLevel: "LOW RISK")
  }

  @MainActor
  func testVFROver100ModerateRisk() throws {
    // Score 24: lessThan50InType(5)+afterWork(4)+lessThan8HrSleep(5)+ifrCurrent(-3)
    //          +night(5)+strongWinds(4)+strongCrosswinds(4)
    tabBar.goToPilotProfile()
      .selectVFR()
      .selectOver100Hours()

    let q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setLessThan50InType(true)
      .setAfterWork(true)
      .setLessThan8HrSleep(true)
      .setIFRCurrent(true)
    q.conditionsSection
      .setNight(true)
      .setStrongWinds(true)
      .setStrongCrosswinds(true)

    tabBar.goToResults()
      .assertResults(score: "24", riskLevel: "MODERATE RISK")
  }

  @MainActor
  func testVFROver100HighRisk() throws {
    // Score 40: lessThan50InType(5)+afterWork(4)+lessThan8HrSleep(5)
    //          +night(5)+strongWinds(4)+strongCrosswinds(4)+mountainous(4)
    //          +nontowered(5)+noDestWx(4)
    tabBar.goToPilotProfile()
      .selectVFR()
      .selectOver100Hours()

    let q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setLessThan50InType(true)
      .setAfterWork(true)
      .setLessThan8HrSleep(true)
    q.conditionsSection
      .setNight(true)
      .setStrongWinds(true)
      .setStrongCrosswinds(true)
      .setMountainous(true)
    q.airportSection.setNontowered(true)
    q.weatherSection.setNoDestWx(true)

    tabBar.goToResults()
      .assertResults(score: "40", riskLevel: "HIGH RISK")
  }

  // MARK: - VFR <100h (low ≤14, moderate 15-20, high >20)

  @MainActor
  func testVFRUnder100LowRisk() throws {
    // Score 0: dualInLast90(-1)+wingsInLast6Mo(-3)+ifrCurrent(-3) = -7, floored to 0
    let q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setDualInLast90(true)
      .setWingsInLast6Mo(true)
      .setIFRCurrent(true)

    tabBar.goToResults()
      .assertResults(score: "0", riskLevel: "LOW RISK")
  }

  @MainActor
  func testVFRUnder100ModerateRisk() throws {
    // Score 18: lessThan50InType(5)+afterWork(4)+lessThan8HrSleep(5)+noDestWx(4)
    let q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setLessThan50InType(true)
      .setAfterWork(true)
      .setLessThan8HrSleep(true)
    q.weatherSection.setNoDestWx(true)

    tabBar.goToResults()
      .assertResults(score: "18", riskLevel: "MODERATE RISK")
  }

  @MainActor
  func testVFRUnder100HighRisk() throws {
    // Score 27: lessThan50InType(5)+afterWork(4)+lessThan8HrSleep(5)
    //          +night(5)+strongWinds(4)+noDestWx(4)
    let q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setLessThan50InType(true)
      .setAfterWork(true)
      .setLessThan8HrSleep(true)
    q.conditionsSection
      .setNight(true)
      .setStrongWinds(true)
    q.weatherSection.setNoDestWx(true)

    tabBar.goToResults()
      .assertResults(score: "27", riskLevel: "HIGH RISK")
  }

  // MARK: - IFR >100h (low ≤30, moderate 31-35, high >35)

  @MainActor
  func testIFROver100LowRisk() throws {
    // Score 12: lessThan50InType(5)+afterWork(4)+lessThan8HrSleep(5)+precision(-2)
    tabBar.goToPilotProfile()
      .selectIFR()
      .selectOver100Hours()

    let q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setLessThan50InType(true)
      .setAfterWork(true)
      .setLessThan8HrSleep(true)
    q.weatherSection.selectIFR()
    q.weatherSection.selectApproachPrecision()

    tabBar.goToResults()
      .assertResults(score: "12", riskLevel: "LOW RISK")
  }

  @MainActor
  func testIFROver100ModerateRisk() throws {
    // Score 34: lessThan50InType(5)+lessThan15InLast90(3)+afterWork(4)+lessThan8HrSleep(5)
    //          +night(5)+strongWinds(4)+strongCrosswinds(4)+none(4)
    tabBar.goToPilotProfile()
      .selectIFR()
      .selectOver100Hours()

    let q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setLessThan50InType(true)
      .setLessThan15InLast90(true)
      .setAfterWork(true)
      .setLessThan8HrSleep(true)
    q.conditionsSection
      .setNight(true)
      .setStrongWinds(true)
      .setStrongCrosswinds(true)
    q.weatherSection.selectIFR()

    tabBar.goToResults()
      .assertResults(score: "34", riskLevel: "MODERATE RISK")
  }

  @MainActor
  func testIFROver100HighRisk() throws {
    // Score 38: same as moderate + noDestWx(4)
    tabBar.goToPilotProfile()
      .selectIFR()
      .selectOver100Hours()

    let q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setLessThan50InType(true)
      .setLessThan15InLast90(true)
      .setAfterWork(true)
      .setLessThan8HrSleep(true)
    q.conditionsSection
      .setNight(true)
      .setStrongWinds(true)
      .setStrongCrosswinds(true)
    q.weatherSection.selectIFR()
    q.weatherSection.setNoDestWx(true)

    tabBar.goToResults()
      .assertResults(score: "38", riskLevel: "HIGH RISK")
  }

  // MARK: - IFR <100h (low ≤20, moderate 21-30, high >30)

  @MainActor
  func testIFRUnder100LowRisk() throws {
    // Score 4: lessThan50InType(5)+afterWork(4)+ifrCurrent(-3)+precision(-2)
    tabBar.goToPilotProfile()
      .selectIFR()

    let q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setLessThan50InType(true)
      .setAfterWork(true)
      .setIFRCurrent(true)
    q.weatherSection.selectIFR()
    q.weatherSection.selectApproachPrecision()

    tabBar.goToResults()
      .assertResults(score: "4", riskLevel: "LOW RISK")
  }

  @MainActor
  func testIFRUnder100ModerateRisk() throws {
    // Score 30: lessThan50InType(5)+lessThan15InLast90(3)+afterWork(4)+lessThan8HrSleep(5)
    //          +night(5)+strongWinds(4)+none(4)
    tabBar.goToPilotProfile()
      .selectIFR()

    let q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setLessThan50InType(true)
      .setLessThan15InLast90(true)
      .setAfterWork(true)
      .setLessThan8HrSleep(true)
    q.conditionsSection
      .setNight(true)
      .setStrongWinds(true)
    q.weatherSection.selectIFR()

    tabBar.goToResults()
      .assertResults(score: "30", riskLevel: "MODERATE RISK")
  }

  @MainActor
  func testIFRUnder100HighRisk() throws {
    // Score 34: same as moderate + strongCrosswinds(4)
    tabBar.goToPilotProfile()
      .selectIFR()

    let q = tabBar.goToQuestionnaire()
    q.pilotSection
      .setLessThan50InType(true)
      .setLessThan15InLast90(true)
      .setAfterWork(true)
      .setLessThan8HrSleep(true)
    q.conditionsSection
      .setNight(true)
      .setStrongWinds(true)
      .setStrongCrosswinds(true)
    q.weatherSection.selectIFR()

    tabBar.goToResults()
      .assertResults(score: "34", riskLevel: "HIGH RISK")
  }
}
