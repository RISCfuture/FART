import SwiftUI

struct ConditionsView: View {
  @Environment(Questionnaire.self)
  private var questionnaire

  private var strongWindsStr: String {
    guard let strongWinds = questionnaire.profile?.strongWinds else { return "0" }
    return windSpeedFormatter.string(from: NSNumber(value: strongWinds))!
  }

  private var strongCrosswindsStr: String {
    guard let strongCrosswinds = questionnaire.profile?.strongCrosswinds else { return "0" }
    return windSpeedFormatter.string(from: NSNumber(value: strongCrosswinds))!
  }

  var body: some View {
    @Bindable var questionnaire = questionnaire

    Section(header: Text("Flight Conditions")) {
      Toggle("Twilight or night", isOn: $questionnaire.night)
        .accessibilityIdentifier("nightToggle")
      Toggle("Surface wind greater than \(strongWindsStr) knots", isOn: $questionnaire.strongWinds)
        .accessibilityIdentifier("strongWindsToggle")
      Toggle(
        "Crosswind greater than \(strongCrosswindsStr) knots",
        isOn: $questionnaire.strongCrosswinds
      )
      .accessibilityIdentifier("strongCrosswindsToggle")
      Toggle("Mountainous terrain", isOn: $questionnaire.mountainous)
        .accessibilityIdentifier("mountainousToggle")
    }
  }
}

#Preview {
  Form {
    List {
      ConditionsView().environment(Questionnaire())
    }
  }
}
