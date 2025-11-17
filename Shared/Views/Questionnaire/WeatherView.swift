import Defaults
import SwiftUI

struct WeatherView: View {
  @Environment(Questionnaire.self)
  private var questionnaire

  @State private var flightType = Rating.VFR

  @Default(.lowCeiling)
  private var lowCeiling

  @Default(.lowVisibility)
  private var lowVisibility

  private var lowCeilingStr: String {
    ceilingFormatter.string(from: NSNumber(value: lowCeiling.rawValue))!
  }

  var body: some View {
    @Bindable var questionnaire = questionnaire

    Section("Weather") {
      Picker("Flight Type", selection: $flightType) {
        Text("VFR").tag(Rating.VFR)
          .accessibilityIdentifier("flightTypeVFR")
        Text("IFR").tag(Rating.IFR)
      }
      .accessibilityIdentifier("flightTypePicker").onChange(of: flightType) {
        questionnaire.batchUpdates {
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
      }

      if flightType == .VFR {
        Toggle("Ceiling less than 3,000′ AGL", isOn: $questionnaire.vfrCeilingUnder3000)
          .accessibilityIdentifier("vfrCeilingUnder3000Toggle")
        Toggle("Visibility less than 5 SM", isOn: $questionnaire.vfrVisibilityUnder5)
          .accessibilityIdentifier("vfrVisibilityUnder5Toggle")
        Toggle("Flight plan filed and activated", isOn: $questionnaire.vfrFlightPlan)
          .accessibilityIdentifier("vfrFlightPlanToggle")
        Toggle("ATC flight following used", isOn: $questionnaire.vfrFlightFollowing)
          .accessibilityIdentifier("vfrFlightFollowingToggle")
      } else {
        Toggle("Ceiling less than \(lowCeilingStr)′ AGL", isOn: $questionnaire.ifrLowCeiling)
          .accessibilityIdentifier("ifrLowCeilingToggle")
        Toggle(
          "Visibility less than \(lowVisibility.stringValue) SM",
          isOn: $questionnaire.ifrLowVisibility
        )
        .accessibilityIdentifier("ifrLowVisibilityToggle")
        Picker("Best available approach", selection: $questionnaire.ifrApproachType) {
          Text("Precision").tag(ApproachType.precision)
          Text("Non-precision").tag(ApproachType.nonprecision)
          Text("Circling only").tag(ApproachType.circling)
          Text("No IFR approaches").tag(ApproachType.none)
        }
        .accessibilityIdentifier("ifrApproachTypePicker")
      }
      Toggle("No weather reporting at destination ", isOn: $questionnaire.noDestWx)
        .accessibilityIdentifier("noDestWxToggle")
    }
  }
}

#Preview {
  Form {
    WeatherView().environment(Questionnaire())
  }
}
