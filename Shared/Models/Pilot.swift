import Combine
import Foundation
import Defaults

enum Rating: String, DefaultsSerializable {
    case VFR
    case IFR
}

enum Hours: String, DefaultsSerializable {
    case under100
    case over100
}

enum Ceiling: Int, CaseIterable, DefaultsSerializable {
    case threeThousandFeet = 3000
    case oneThousandFeet = 1000
    case fiveHundredFeet = 500
    case twoHundredFeet = 200
    
    var stringValue: String {
        return ceilingFormatter.string(for: rawValue)!
    }
}

enum Visibility: Float, CaseIterable, DefaultsSerializable {
    case threeSM = 3.0
    case oneSM = 1.0
    case oneHalfSM = 0.5
    case oneQuarterSM = 0.25
    
    var stringValue: String {
        switch self {
        case .threeSM: return "3"
        case .oneSM: return "1"
        case .oneHalfSM: return "½"
        case .oneQuarterSM: return "¼"
        }
    }
}

class Pilot: ObservableObject {
    @Published var rating = Rating.VFR
    @Published var hours = Hours.under100
    
    @Published var shortRunway = 3000 // feet
    
    @Published var strongWinds = 15 // knots
    @Published var strongCrosswinds = 7 // knots
    @Published var lowCeiling = Ceiling.oneThousandFeet
    @Published var lowVisibility = Visibility.threeSM
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        rating = Defaults[.rating]
        hours = Defaults[.hours]
        shortRunway = Defaults[.shortRunway]
        strongWinds = Defaults[.strongWinds]
        strongCrosswinds = Defaults[.strongCrosswinds]
        lowCeiling = Defaults[.lowCeiling]
        lowVisibility = Defaults[.lowVisibility]
        
        $rating.sink { Defaults[.rating] = $0 }.store(in: &cancellables)
        $hours.sink { Defaults[.hours] = $0 }.store(in: &cancellables)
        $shortRunway.sink { Defaults[.shortRunway] = $0 }.store(in: &cancellables)
        $strongWinds.sink { Defaults[.strongWinds] = $0 }.store(in: &cancellables)
        $strongCrosswinds.sink { Defaults[.strongCrosswinds] = $0 }.store(in: &cancellables)
        $lowCeiling.sink { Defaults[.lowCeiling] = $0 }.store(in: &cancellables)
        $lowVisibility.sink { Defaults[.lowVisibility] = $0 }.store(in: &cancellables)
        
        $rating.sink { _ in self.objectWillChange.send() }.store(in: &cancellables)
        $hours.sink { _ in self.objectWillChange.send() }.store(in: &cancellables)
        $shortRunway.sink { _ in self.objectWillChange.send() }.store(in: &cancellables)
        $strongWinds.sink { _ in self.objectWillChange.send() }.store(in: &cancellables)
        $strongCrosswinds.sink { _ in self.objectWillChange.send() }.store(in: &cancellables)
        $lowCeiling.sink { _ in self.objectWillChange.send() }.store(in: &cancellables)
        $lowVisibility.sink { _ in self.objectWillChange.send() }.store(in: &cancellables)
    }
    
    deinit {
        for cancellable in cancellables { cancellable.cancel() }
    }
}
