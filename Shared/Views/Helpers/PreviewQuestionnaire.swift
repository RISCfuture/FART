/// Questionnaires for previews that need to show every risk band.
///
/// A questionnaire only scores itself while a scene is observing it, so one built for a
/// preview stays at zero no matter which answers are set. These fill in both halves: real
/// answers, so a report lists real factors, and the score those answers actually add up to.
extension Questionnaire {
  /// A questionnaire answered into `risk`.
  ///
  /// The risk is assigned rather than categorized. The answers below do land in `risk` for
  /// the default VFR, under-100-hours profile, but categorizing would read the previewing
  /// machine's saved pilot profile and could put the variant in a band other than the one it
  /// is named for.
  static func previewing(_ risk: Risk) -> Questionnaire {
    let questionnaire = Questionnaire()
    questionnaire.answerFactors(reaching: risk)
    questionnaire.score = FARTScoreCalculator.calculateScore(from: questionnaire.answers)
    questionnaire.risk = risk
    return questionnaire
  }

  /// Answers yes to as many factors as `risk` takes, each band building on the one below it.
  private func answerFactors(reaching risk: Risk) {
    lessThan50InType = true
    night = true
    guard risk != .low else { return }

    lessThan8HrSleep = true
    shortRunway = true
    guard risk != .moderate else { return }

    nontowered = true
    strongWinds = true
  }
}
