import Defaults
import SwiftUI

struct AirportView: View {
  @Environment(Questionnaire.self)
  private var questionnaire

  @Default(.shortRunway)
  private var shortRunway

  private var shortRunwayStr: String {
    runwayLengthFormatter.string(from: NSNumber(value: shortRunway))!
  }

  var body: some View {
    @Bindable var questionnaire = questionnaire

    Section("Departure and Destination Airport") {
      Toggle("Nontowered airport (or tower closed)", isOn: $questionnaire.nontowered)
        .accessibilityIdentifier("nontoweredToggle")
      Toggle("Runway length less than \(shortRunwayStr)′", isOn: $questionnaire.shortRunway)
        .accessibilityIdentifier("shortRunwayToggle")
      Toggle("Wet or soft-field runway", isOn: $questionnaire.wetOrSoftFieldRunway)
        .accessibilityIdentifier("wetOrSoftFieldToggle")
      Toggle("Obstacles on departure/approach", isOn: $questionnaire.runwayObstacles)
        .accessibilityIdentifier("runwayObstaclesToggle")
    }
  }
}

#Preview {
  Form {
    AirportView().environment(Questionnaire())
  }
}
