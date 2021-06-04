import SwiftUI

struct QuestionnaireView: View {
    @EnvironmentObject var questionnaire: Questionnaire
    @ObservedObject var pilot: Pilot
    
    var body: some View {
        Form {
            List {
                PilotView().environmentObject(questionnaire)
                ConditionsView(pilot: pilot).environmentObject(questionnaire)
                AirportView(pilot: pilot).environmentObject(questionnaire)
                WeatherView(pilot: pilot).environmentObject(questionnaire)
            }
        }
    }
}

struct QuestionnaireView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionnaireView(pilot: Pilot()).environmentObject(Questionnaire())
    }
}
