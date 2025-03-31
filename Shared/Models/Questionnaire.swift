import Defaults
import Foundation

enum Risk {
    case low
    case moderate
    case high
}

enum ApproachType: String {
    case precision
    case nonprecision
    case none
    case circling
    case notApplicable // for VFR flights
}

@MainActor
@Observable
class Questionnaire {
    // MARK: Inputs
    var lessThan50InType = false {
        didSet { update() }
    }
    var lessThan15InLast90 = false {
        didSet { update() }
    }
    var afterWork = false {
        didSet { update() }
    }
    var lessThan8HrSleep = false {
        didSet { update() }
    }
    var dualInLast90 = false {
        didSet { update() }
    }
    var wingsInLast6Mo = false {
        didSet { update() }
    }
    var IFRCurrent = false {
        didSet { update() }
    }

    var night = false {
        didSet { update() }
    }
    var strongWinds = false {
        didSet { update() }
    }
    var strongCrosswinds = false {
        didSet { update() }
    }
    var mountainous = false {
        didSet { update() }
    }

    var nontowered = false {
        didSet { update() }
    }
    var shortRunway = false {
        didSet { update() }
    }
    var wetOrSoftFieldRunway = false {
        didSet { update() }
    }
    var runwayObstacles = false {
        didSet { update() }
    }

    var vfrCeilingUnder3000 = false {
        didSet { update() }
    }
    var vfrVisibilityUnder5 = false {
        didSet { update() }
    }
    var noDestWx = false {
        didSet { update() }
    }
    var vfrFlightPlan = false {
        didSet { update() }
    }
    var vfrFlightFollowing = false {
        didSet { update() }
    }
    var ifrLowCeiling = false {
        didSet { update() }
    }
    var ifrLowVisibility = false {
        didSet { update() }
    }
    var ifrApproachType = ApproachType.notApplicable {
        didSet { update() }
    }

    // MARK: Outputs
    var score = 0
    var risk = Risk.low

    init() {
        Task {
            for await _ in Defaults.updates([.hours, .rating]) {
                update()
            }
        }
    }

    func update() {
        score = calculateScore()
        risk = categorize()
    }

    private func calculateScore() -> Int {
        let score = questionScorer(for: \.lessThan50InType).score(lessThan50InType) +
        questionScorer(for: \.lessThan15InLast90).score(lessThan15InLast90) +
        questionScorer(for: \.afterWork).score(afterWork) +
        questionScorer(for: \.lessThan8HrSleep).score(lessThan8HrSleep) +
        questionScorer(for: \.dualInLast90).score(dualInLast90) +
        questionScorer(for: \.wingsInLast6Mo).score(wingsInLast6Mo) +
        questionScorer(for: \.IFRCurrent).score(IFRCurrent) +
        questionScorer(for: \.night).score(night) +
        questionScorer(for: \.strongWinds).score(strongWinds) +
        questionScorer(for: \.strongCrosswinds).score(strongCrosswinds) +
        questionScorer(for: \.mountainous).score(mountainous) +
        questionScorer(for: \.nontowered).score(nontowered) +
        questionScorer(for: \.shortRunway).score(shortRunway) +
        questionScorer(for: \.wetOrSoftFieldRunway).score(wetOrSoftFieldRunway) +
        questionScorer(for: \.runwayObstacles).score(runwayObstacles) +
        questionScorer(for: \.vfrCeilingUnder3000).score(vfrCeilingUnder3000) +
        questionScorer(for: \.vfrVisibilityUnder5).score(vfrVisibilityUnder5) +
        questionScorer(for: \.noDestWx).score(noDestWx) +
        questionScorer(for: \.vfrFlightPlan).score(vfrFlightPlan) +
        questionScorer(for: \.vfrFlightFollowing).score(vfrFlightFollowing) +
        questionScorer(for: \.ifrLowCeiling).score(ifrLowCeiling) +
        questionScorer(for: \.ifrLowVisibility).score(ifrLowVisibility) +
        questionScorer(for: \.ifrApproachType).score(ifrApproachType)
        return max(0, score)
    }

    private func categorize() -> Risk {
        switch Defaults[.rating] {
            case .VFR:
                switch Defaults[.hours] {
                    case .under100:
                        if score > 20 { return .high }
                        if score > 14 { return .moderate }
                        return .low
                    case .over100:
                        if score > 25 { return .high }
                        if score > 20 { return .moderate }
                        return .low
                }
            case .IFR:
                switch Defaults[.hours] {
                    case .under100:
                        if score > 30 { return .high }
                        if score > 20 { return .moderate }
                        return .low
                    case .over100:
                        if score > 35 { return .high }
                        if score > 30 { return .moderate }
                        return .low
                }
        }
    }
}
