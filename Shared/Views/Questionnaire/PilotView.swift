import SwiftUI

struct PilotView: View {
    @EnvironmentObject var questions: Questionnaire
    
    var body: some View {
        Section(header: Text("Pilot")) {
            Toggle("Fewer than 50 hours in aircraft or avionics type", isOn: $questions.lessThan50InType)
            Toggle("Fewer than 15 hours in last 90 days", isOn: $questions.lessThan15InLast90)
            Toggle("Flight will occur after work", isOn: $questions.afterWork)
            Toggle("Fewer than 8 hours’ sleep prior to flight", isOn: $questions.lessThan8HrSleep)
            Toggle("Dual instruction received in last 90 days", isOn: $questions.dualInLast90)
            Toggle("WINGS phase completion in last 6 months", isOn: $questions.wingsInLast6Mo)
            Toggle("Instrument rated, current, and proficient", isOn: $questions.IFRCurrent)
        }
    }
}

struct PilotView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            List {
                PilotView().environmentObject(Questionnaire())
            }
        }
    }
}
