import SwiftUI

struct ConditionsView: View {
    @EnvironmentObject var questions: Questionnaire
    @ObservedObject var pilot: Pilot
    
    private var strongWinds: String { windSpeedFormatter.string(from: NSNumber(integerLiteral: pilot.strongWinds))! }
    private var strongCrosswinds: String { windSpeedFormatter.string(from: NSNumber(integerLiteral: pilot.strongCrosswinds))! }

    var body: some View {
        Section(header: Text("Flight Conditions")) {
            Toggle("Twilight or night", isOn: $questions.night)
            Toggle("Surface wind greater than \(strongWinds) knots", isOn: $questions.strongWinds)
            Toggle("Crosswind greater than \(strongCrosswinds) knots", isOn: $questions.strongCrosswinds)
            Toggle("Mountainous terrain", isOn: $questions.mountainous)
        }
    }
}

struct ConditionsView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            List {
                ConditionsView(pilot: Pilot()).environmentObject(Questionnaire())
            }
        }
    }
}
