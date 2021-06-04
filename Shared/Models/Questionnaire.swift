import Combine
import Foundation

enum ApproachType: String {
    case precision
    case nonprecision
    case none
    case circling
    case notApplicable // for VFR flights
}

class Questionnaire: ObservableObject {
    @Published var lessThan50InType = false
    @Published var lessThan15InLast90 = false
    @Published var afterWork = false
    @Published var lessThan8HrSleep = false
    @Published var dualInLast90 = false
    @Published var wingsInLast6Mo = false
    @Published var IFRCurrent = false
    
    @Published var night = false
    @Published var strongWinds = false
    @Published var strongCrosswinds = false
    @Published var mountainous = false
    
    @Published var nontowered = false
    @Published var shortRunway = false
    @Published var wetOrSoftFieldRunway = false
    @Published var runwayObstacles = false
    
    @Published var vfrCeilingUnder3000 = false
    @Published var vfrVisibilityUnder5 = false
    @Published var noDestWx = false
    @Published var vfrFlightPlan = false
    @Published var vfrFlightFollowing = false
    @Published var ifrLowCeiling = false
    @Published var ifrLowVisibility = false
    @Published var ifrApproachType = ApproachType.notApplicable
    
    @Published var score = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $lessThan50InType.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $lessThan15InLast90.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $afterWork.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $lessThan8HrSleep.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $dualInLast90.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $wingsInLast6Mo.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $IFRCurrent.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $night.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $strongWinds.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $strongCrosswinds.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $mountainous.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $nontowered.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $shortRunway.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $wetOrSoftFieldRunway.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $runwayObstacles.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $vfrCeilingUnder3000.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $vfrVisibilityUnder5.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $noDestWx.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $vfrFlightPlan.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $vfrFlightFollowing.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $ifrLowCeiling.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $ifrLowVisibility.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
        $ifrApproachType.receive(on: RunLoop.main)
            .sink { _ in self.score = self.calculateScore() }
            .store(in: &cancellables)
    }
    
    deinit {
        for cancellable in cancellables { cancellable.cancel() }
    }
    
    func calculateScore() -> Int {
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
}
