// Pure scorer protocol with no dependencies
protocol QuestionScorer {
  associatedtype AnswerType
  func score(_ answer: AnswerType) -> Int
}

// Pure bool scorer implementation
class BoolScorer: QuestionScorer {
  let value: Int

  init(_ value: Int) {
    self.value = value
  }

  func score(_ answer: Bool) -> Int {
    return answer ? value : 0
  }
}

// Pure approach scorer implementation
class ApproachScorer: QuestionScorer {
  func score(_ answer: ApproachType) -> Int {
    switch answer {
      case .precision: return -2
      case .nonprecision: return 3
      case .none: return 4
      case .circling: return 7
      case .notApplicable: return 0
    }
  }
}

// Helper functions for mapping Questionnaire keypaths to scorers
@MainActor
func questionScorer(for keyPath: KeyPath<Questionnaire, Bool>) -> BoolScorer {
  if keyPath == \.lessThan50InType { return BoolScorer(5) }
  if keyPath == \.lessThan15InLast90 { return BoolScorer(3) }
  if keyPath == \.afterWork { return BoolScorer(4) }
  if keyPath == \.lessThan8HrSleep { return BoolScorer(5) }
  if keyPath == \.dualInLast90 { return BoolScorer(-1) }
  if keyPath == \.wingsInLast6Mo { return BoolScorer(-3) }
  if keyPath == \.IFRCurrent { return BoolScorer(-3) }
  if keyPath == \.night { return BoolScorer(5) }
  if keyPath == \.strongWinds { return BoolScorer(4) }
  if keyPath == \.strongCrosswinds { return BoolScorer(4) }
  if keyPath == \.mountainous { return BoolScorer(4) }
  if keyPath == \.nontowered { return BoolScorer(5) }
  if keyPath == \.shortRunway { return BoolScorer(3) }
  if keyPath == \.wetOrSoftFieldRunway { return BoolScorer(3) }
  if keyPath == \.runwayObstacles { return BoolScorer(3) }
  if keyPath == \.vfrCeilingUnder3000 { return BoolScorer(2) }
  if keyPath == \.vfrVisibilityUnder5 { return BoolScorer(2) }
  if keyPath == \.noDestWx { return BoolScorer(4) }
  if keyPath == \.vfrFlightPlan { return BoolScorer(-2) }
  if keyPath == \.vfrFlightFollowing { return BoolScorer(-3) }
  if keyPath == \.ifrLowCeiling { return BoolScorer(2) }
  if keyPath == \.ifrLowVisibility { return BoolScorer(2) }
  fatalError("Unknown Questionnaire keyPath \(keyPath)")
}

func questionScorer(for _: KeyPath<Questionnaire, ApproachType>) -> ApproachScorer {
  return ApproachScorer()
}
