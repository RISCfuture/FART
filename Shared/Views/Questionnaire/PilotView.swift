import SwiftUI

struct PilotView: View {
    @Environment(Questionnaire.self) private var questionnaire
    
    var body: some View {
        @Bindable var questionnaire = questionnaire
        
        Section(header: Text("Pilot")) {
            Toggle("Fewer than 50 hours in aircraft or avionics type", isOn: $questionnaire.lessThan50InType)
            Toggle("Fewer than 15 hours in last 90 days", isOn: $questionnaire.lessThan15InLast90)
            Toggle("Flight will occur after work", isOn: $questionnaire.afterWork)
            Toggle("Fewer than 8 hours’ sleep prior to flight", isOn: $questionnaire.lessThan8HrSleep)
            Toggle("Dual instruction received in last 90 days", isOn: $questionnaire.dualInLast90)
            Toggle("WINGS phase completion in last 6 months", isOn: $questionnaire.wingsInLast6Mo)
            Toggle("Instrument rated, current, and proficient", isOn: $questionnaire.IFRCurrent)
        }
    }
}

#Preview {
    Form {
        List {
            PilotView().environment(Questionnaire())
        }
    }
}
