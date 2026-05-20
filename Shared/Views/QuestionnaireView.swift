import SwiftUI

struct QuestionnaireView: View {
  // Observed at this level so the parent re-evaluates when any answer
  // mutates; without it certain child writes don't propagate in time
  // for the score to refresh, breaking UI tests like testIFROver100*.
  // periphery:ignore
  @Environment(Questionnaire.self)
  private var questionnaire

  var body: some View {
    Form {
      PilotView()
      ConditionsView()
      AirportView()
      WeatherView()
    }
    .accessibilityIdentifier("questionnaireForm")
  }
}

#Preview {
  QuestionnaireView().environment(Questionnaire())
}
