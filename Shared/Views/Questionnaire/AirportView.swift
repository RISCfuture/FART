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

    Section(header: Text("Departure and Destination Airport")) {
      Toggle("Nontowered airport (or tower closed)", isOn: $questionnaire.nontowered)
      Toggle("Runway length less than \(shortRunwayStr)′", isOn: $questionnaire.shortRunway)
      Toggle("Wet or soft-field runway", isOn: $questionnaire.wetOrSoftFieldRunway)
      Toggle("Obstacles on departure/approach", isOn: $questionnaire.runwayObstacles)
    }
  }
}

#Preview {
  Form {
    List {
      AirportView().environment(Questionnaire())
    }
  }
}
