import SwiftUI

struct ResultsView: View {
  @Environment(Questionnaire.self)
  private var questionnaire

  // Displayed values track the model only while the view is on screen. This keeps the
  // gauge/score/risk from queuing an animation per change while the tab is hidden (which
  // would all replay on switch); instead the view animates once to the current value on
  // appear.
  @State private var displayedScore = 0
  @State private var displayedRisk = Risk.low
  @State private var onScreen = false

  private var normalizedScore: Float {
    Float(displayedScore) / 64.0
  }

  private var riskDescription: String {
    switch displayedRisk {
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
        Text(displayedScore, format: .number)
          .font(.system(size: 75, weight: .bold, design: .rounded))
          .foregroundStyle(displayedRisk.color)
          .contentTransition(.numericText())
          .accessibilityIdentifier("scoreText")
        Text("PTS.")
          .bold()
          .foregroundStyle(displayedRisk.color)
      }.offset(x: 0, y: -30)
    }.padding(.top, 10)
      .frame(maxWidth: 500, maxHeight: 500)
  }

  private var riskTitle: some View {
    VStack {
      Text(displayedRisk.label.uppercased())
        .bold()
        .font(.title)
        .contentTransition(.interpolate)
        .accessibilityIdentifier("riskLevelText")
    }
  }

  var body: some View {
    VStack {
      Spacer()
      gauge
      Spacer()
      riskTitle
        .foregroundStyle(displayedRisk.color)
      Text(riskDescription).font(.caption)
        .contentTransition(.opacity)
        .accessibilityIdentifier("riskDescriptionText")
      Spacer()
    }
    .padding()
    .background(RiskMeshBackground(risk: displayedRisk))
    .onAppear {
      onScreen = true
      withAnimation { syncToModel() }
    }
    .onDisappear { onScreen = false }
    .onChange(of: questionnaire.score) { animateToModel() }
    .onChange(of: questionnaire.risk) { animateToModel() }
  }

  private func syncToModel() {
    displayedScore = questionnaire.score
    displayedRisk = questionnaire.risk
  }

  /// Ignore changes that arrive while off screen; they'll be applied in one animation on
  /// the next appear rather than queued to replay.
  private func animateToModel() {
    guard onScreen else { return }
    withAnimation { syncToModel() }
  }
}

/// A subtle, risk-tinted mesh gradient that sits behind the results as a soft backdrop.
/// Animation is driven by the enclosing view's transaction, not its own, so it doesn't
/// animate while off screen.
private struct RiskMeshBackground: View {
  var risk: Risk

  var body: some View {
    MeshGradient(
      width: 2,
      height: 2,
      points: [
        SIMD2<Float>(0, 0), SIMD2<Float>(1, 0),
        SIMD2<Float>(0, 1), SIMD2<Float>(1, 1)
      ],
      colors: [
        risk.color.opacity(0.12), risk.color.opacity(0.04),
        risk.color.opacity(0.05), risk.color.opacity(0.14)
      ]
    )
    .ignoresSafeArea()
  }
}

extension Risk {
  /// The band color used for risk-level labels and accents.
  var color: Color {
    switch self {
      case .low: Color(.lowRisk)
      case .moderate: Color(.moderateRisk)
      case .high: Color(.highRisk)
    }
  }

  /// The localized risk-level title, e.g. “Low Risk”.
  var label: String {
    switch self {
      case .low: String(localized: "Low Risk")
      case .moderate: String(localized: "Moderate Risk")
      case .high: String(localized: "High Risk")
    }
  }

  /// A lowercase risk descriptor for inline use, e.g. “moderate risk”.
  var inlineLabel: String {
    switch self {
      case .low: String(localized: "low risk")
      case .moderate: String(localized: "moderate risk")
      case .high: String(localized: "high risk")
    }
  }
}

#Preview {
  ResultsView().environment(Questionnaire())
}
