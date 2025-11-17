import SwiftUI

struct PilotView: View {
  @Environment(Questionnaire.self)
  private var questionnaire

  var body: some View {
    @Bindable var questionnaire = questionnaire

    Section("Pilot") {
      Toggle(
        "Fewer than 50 hours in aircraft or avionics type",
        isOn: $questionnaire.lessThan50InType
      )
      .accessibilityIdentifier("lessThan50InTypeToggle")
      Toggle("Fewer than 15 hours in last 90 days", isOn: $questionnaire.lessThan15InLast90)
        .accessibilityIdentifier("lessThan15InLast90Toggle")
      Toggle("Flight will occur after work", isOn: $questionnaire.afterWork)
        .accessibilityIdentifier("afterWorkToggle")
      Toggle("Fewer than 8 hours' sleep prior to flight", isOn: $questionnaire.lessThan8HrSleep)
        .accessibilityIdentifier("lessThan8HrSleepToggle")
      Toggle("Dual instruction received in last 90 days", isOn: $questionnaire.dualInLast90)
        .accessibilityIdentifier("dualInLast90Toggle")
      Toggle("WINGS phase completion in last 6 months", isOn: $questionnaire.wingsInLast6Mo)
        .accessibilityIdentifier("wingsInLast6MoToggle")
      Toggle("Instrument rated, current, and proficient", isOn: $questionnaire.IFRCurrent)
        .accessibilityIdentifier("ifrCurrentToggle")
    }
  }
}

#Preview {
  Form {
    PilotView().environment(Questionnaire())
  }
}
