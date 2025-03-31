import Defaults
import SwiftUI

struct ConditionsView: View {
    @Environment(Questionnaire.self)
    private var questionnaire

    @Default(.strongCrosswinds)
    private var strongCrosswinds

    @Default(.strongWinds)
    private var strongWinds

    private var strongWindsStr: String { windSpeedFormatter.string(from: NSNumber(value: strongWinds))! }
    private var strongCrosswindsStr: String { windSpeedFormatter.string(from: NSNumber(value: strongCrosswinds))! }

    var body: some View {
        @Bindable var questionnaire = questionnaire

        Section(header: Text("Flight Conditions")) {
            Toggle("Twilight or night", isOn: $questionnaire.night)
            Toggle("Surface wind greater than \(strongWindsStr) knots", isOn: $questionnaire.strongWinds)
            Toggle("Crosswind greater than \(strongCrosswindsStr) knots", isOn: $questionnaire.strongCrosswinds)
            Toggle("Mountainous terrain", isOn: $questionnaire.mountainous)
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
