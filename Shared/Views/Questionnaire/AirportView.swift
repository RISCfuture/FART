import SwiftUI

struct AirportView: View {
    @EnvironmentObject var questions: Questionnaire
    @ObservedObject var pilot: Pilot
    
    private var shortRunway: String { runwayLengthFormatter.string(from: NSNumber(integerLiteral: pilot.shortRunway))! }
    
    var body: some View {
        Section(header: Text("Departure and Destination Airport")) {
            Toggle("Nontowered airport (or tower closed)", isOn: $questions.nontowered)
            Toggle("Runway length less than \(shortRunway)′", isOn: $questions.shortRunway)
            Toggle("Wet or soft-field runway", isOn: $questions.wetOrSoftFieldRunway)
            Toggle("Obstacles on departure/approach", isOn: $questions.runwayObstacles)
        }
    }
}

struct AirportView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            List {
                AirportView(pilot: Pilot()).environmentObject(Questionnaire())
            }
        }
    }
}
