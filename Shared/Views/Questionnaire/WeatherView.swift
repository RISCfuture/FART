import SwiftUI
import Defaults

struct WeatherView: View {
    @EnvironmentObject var questions: Questionnaire
    @ObservedObject var pilot: Pilot
    @State var flightType = Rating.VFR
    
    private var lowCeiling: String { ceilingFormatter.string(from: NSNumber(integerLiteral: pilot.lowCeiling.rawValue))! }
    
    var body: some View {
        Section(header: Text("Weather")) {
            Picker("Flight Type", selection: $flightType) {
                Text("VFR").tag(Rating.VFR)
                Text("IFR").tag(Rating.IFR)
            }.onChange(of: flightType) { flightType in
                switch flightType {
                case .VFR:
                    questions.ifrLowCeiling = false
                    questions.ifrLowVisibility = false
                    questions.ifrApproachType = .notApplicable
                case .IFR:
                    questions.vfrFlightPlan = false
                    questions.vfrFlightFollowing = false
                    questions.vfrCeilingUnder3000 = false
                    questions.vfrVisibilityUnder5 = false
                    questions.ifrApproachType = .none
                }
            }
            
            if flightType == .VFR {
                Toggle("Ceiling less than 3,000′ AGL", isOn: $questions.vfrCeilingUnder3000)
                Toggle("Visibility less than 5 SM", isOn: $questions.vfrVisibilityUnder5)
                Toggle("Flight plan filed and activated", isOn: $questions.vfrFlightPlan)
                Toggle("ATC flight following used", isOn: $questions.vfrFlightFollowing)
            } else {
                Toggle("Ceiling less than \(lowCeiling)′ AGL", isOn: $questions.ifrLowCeiling)
                Toggle("Visibility less than \(pilot.lowVisibility.stringValue) SM", isOn: $questions.ifrLowVisibility)
                Picker("Best available approach", selection: $questions.ifrApproachType) {
                    Text("Precision").tag(ApproachType.precision)
                    Text("Non-precision").tag(ApproachType.nonprecision)
                    Text("Circling only").tag(ApproachType.circling)
                    Text("No IFR approaches").tag(ApproachType.none)
                }
            }
            Toggle("No weather reporting at destination ", isOn: $questions.noDestWx)
        }
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            List {
                WeatherView(pilot: Pilot()).environmentObject(Questionnaire())
            }
        }
    }
}
