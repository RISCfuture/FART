import SwiftUI

struct ResultsView: View {
  @Environment(Questionnaire.self)
  private var questionnaire

  private var score: String {
    scoreFormatter.string(from: NSNumber(value: questionnaire.score))!
  }

  private var normalizedScore: Float {
    Float(questionnaire.score) / 64.0
  }

  private var riskColor: Color {
    switch questionnaire.risk {
      case .low: return Color("LowRisk")
      case .moderate: return Color("ModerateRisk")
      case .high: return Color("HighRisk")
    }
  }

  private var riskText: String {
    switch questionnaire.risk {
      case .low: return "Low Risk"
      case .moderate: return "Moderate Risk"
      case .high: return "High Risk"
    }
  }

  private var riskDescription: String {
    switch questionnaire.risk {
      case .low:
        return
          "With a clear in-the-green score, you might be tempted to blast off with unabated zeal. Not so fast. A FART is not meant to make your go/no-go decision for you. It is merely a tool to help you plan your flight and think through a more complete range of hazards and risks. When using a FART, it’s a good idea to create numerical thresholds that trigger additional levels of scrutiny prior to a go/no-go decision for the flight. For example, a score that’s on the high end of the green scale may still warrant further analysis. The pilot should discuss what the highest scoring risks are and attempt to mitigate those risks."
      case .moderate:
        return
          "If your score falls in the yellow, try to mitigate some of the higher scoring items. That might entail waiting for the weather to improve or switching to an aircraft you have more experience with. If the score is still in the yellow, bring in the opinion of a designated “contact” person such as a flight instructor or an FAASTeam Representative. They may be able to help think of ways to further mitigate some of the risks for your flight."
      case .high:
        return
          "If your score falls in the red zone, you should seriously consider cancelling the flight unless the risks involved can be safely mitigated. It’s important to not allow the external pressures involved with carrying on with the flight (e.g., attending your son’s graduation ceremony) interfere with your go/no-go decision. You (and your passengers) may be disappointed, but it’s always better to be wishing you were in the air than wishing you were on the ground!"
    }
  }

  private var gauge: some View {
    Gauge(value: normalizedScore) {
      HStack(alignment: .firstTextBaseline) {
        Text(score)
          .font(.system(size: 75))
          .bold()
          .foregroundColor(riskColor)
          .contentTransition(.numericText())
          .accessibilityIdentifier("scoreText")
        Text("PTS.")
          .bold()
          .foregroundColor(riskColor)
      }.offset(x: 0, y: -30)
    }.padding(.top, 10)
      .frame(maxWidth: 500, maxHeight: 500)
  }

  private var riskTitle: some View {
    VStack {
      Text(riskText.uppercased())
        .bold()
        .font(.title)
        .accessibilityIdentifier("riskLevelText")
    }
  }

  var body: some View {
    VStack {
      Spacer()
      gauge
      Spacer()
      riskTitle
        .foregroundColor(riskColor)
      Text(riskDescription).font(.caption)
        .accessibilityIdentifier("riskDescriptionText")
      Spacer()
    }.padding()
  }
}

#Preview {
  ResultsView().environment(Questionnaire())
}
