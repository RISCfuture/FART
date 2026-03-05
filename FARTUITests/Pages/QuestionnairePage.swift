import XCTest

class QuestionnairePage: BasePage {
  lazy var pilotSection = PilotSectionPage(app: app)
  lazy var conditionsSection = ConditionsSectionPage(app: app)
  lazy var airportSection = AirportSectionPage(app: app)
  lazy var weatherSection = WeatherSectionPage(app: app)
}
