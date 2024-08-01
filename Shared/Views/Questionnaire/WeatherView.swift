import SwiftUI
import Defaults

struct WeatherView: View {
    @Environment(Questionnaire.self) private var questionnaire
    @State private var flightType = Rating.VFR
    @Default(.lowCeiling) private var lowCeiling
    @Default(.lowVisibility) private var lowVisibility

    private var lowCeilingStr: String { ceilingFormatter.string(from: NSNumber(integerLiteral: lowCeiling.rawValue))! }

    var body: some View {
        @Bindable var questionnaire = questionnaire

        Section(header: Text("Weather")) {
            Picker("Flight Type", selection: $flightType) {
                Text("VFR").tag(Rating.VFR)
                Text("IFR").tag(Rating.IFR)
            }.onChange(of: flightType) {
                switch flightType {
                    case .VFR:
                        questionnaire.ifrLowCeiling = false
                        questionnaire.ifrLowVisibility = false
                        questionnaire.ifrApproachType = .notApplicable
                    case .IFR:
                        questionnaire.vfrFlightPlan = false
                        questionnaire.vfrFlightFollowing = false
                        questionnaire.vfrCeilingUnder3000 = false
                        questionnaire.vfrVisibilityUnder5 = false
                        questionnaire.ifrApproachType = .none
                }
            }

            if flightType == .VFR {
                Toggle("Ceiling less than 3,000′ AGL", isOn: $questionnaire.vfrCeilingUnder3000)
                Toggle("Visibility less than 5 SM", isOn: $questionnaire.vfrVisibilityUnder5)
                Toggle("Flight plan filed and activated", isOn: $questionnaire.vfrFlightPlan)
                Toggle("ATC flight following used", isOn: $questionnaire.vfrFlightFollowing)
            } else {
                Toggle("Ceiling less than \(lowCeilingStr)′ AGL", isOn: $questionnaire.ifrLowCeiling)
                Toggle("Visibility less than \(lowVisibility.stringValue) SM", isOn: $questionnaire.ifrLowVisibility)
                Picker("Best available approach", selection: $questionnaire.ifrApproachType) {
                    Text("Precision").tag(ApproachType.precision)
                    Text("Non-precision").tag(ApproachType.nonprecision)
                    Text("Circling only").tag(ApproachType.circling)
                    Text("No IFR approaches").tag(ApproachType.none)
                }
            }
            Toggle("No weather reporting at destination ", isOn: $questionnaire.noDestWx)
        }
    }
}

#Preview {
    Form {
        List {
            WeatherView().environment(Questionnaire())
        }
    }
}
