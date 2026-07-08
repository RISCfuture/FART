import Defaults
import SwiftUI

struct ConditionsView: View {
  @Environment(Questionnaire.self)
  private var questionnaire

  @Default(.strongCrosswinds)
  private var strongCrosswinds

  @Default(.strongWinds)
  private var strongWinds

  var body: some View {
    @Bindable var questionnaire = questionnaire

    Section("Flight Conditions") {
      Toggle("Twilight or night", isOn: $questionnaire.night)
        .accessibilityIdentifier("nightToggle")
      Toggle(
        "Surface wind greater than \(strongWinds, format: .asKnots)",
        isOn: $questionnaire.strongWinds
      )
      .accessibilityIdentifier("strongWindsToggle")
      Toggle(
        "Crosswind greater than \(strongCrosswinds, format: .asKnots)",
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
    ConditionsView().environment(Questionnaire())
  }
}
