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
