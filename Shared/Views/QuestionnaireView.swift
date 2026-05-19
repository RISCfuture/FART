import SwiftUI

struct QuestionnaireView: View {
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
