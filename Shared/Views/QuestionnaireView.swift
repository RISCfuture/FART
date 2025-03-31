import SwiftUI

struct QuestionnaireView: View {
    @Environment(Questionnaire.self)
    private var questionnaire

    var body: some View {
        Form {
            List {
                PilotView()
                ConditionsView()
                AirportView()
                WeatherView()
            }
        }
    }
}

#Preview {
        QuestionnaireView().environment(Questionnaire())
    }
