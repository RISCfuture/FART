import Combine
import Foundation

class Controller: ObservableObject {
    @Published var questionnaire = Questionnaire()
    @Published var pilot = Pilot()
    
    @Published var risk = Risk.low
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        questionnaire.$score.receive(on: RunLoop.main).sink { _ in
            self.risk = categorize(pilot: self.pilot, questionnaire: self.questionnaire)
        }.store(in: &cancellables)
        pilot.objectWillChange.receive(on: RunLoop.main).sink { change in
            self.risk = categorize(pilot: self.pilot, questionnaire: self.questionnaire)
        }.store(in: &cancellables)
    }
    
    deinit {
        for cancellable in cancellables { cancellable.cancel() }
    }
}
