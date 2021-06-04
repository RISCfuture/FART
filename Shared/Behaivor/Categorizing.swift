enum Risk {
    case low
    case moderate
    case high
}

func categorize(pilot: Pilot, questionnaire: Questionnaire) -> Risk {
    switch pilot.rating {
    case .VFR:
        switch pilot.hours {
        case .under100:
            if questionnaire.score > 20 { return .high }
            if questionnaire.score > 14 { return .moderate }
            return .low
        case .over100:
            if questionnaire.score > 25 { return .high }
            if questionnaire.score > 20 { return .moderate }
            return .low
        }
    case .IFR:
        switch pilot.hours {
        case .under100:
            if questionnaire.score > 30 { return .high }
            if questionnaire.score > 20 { return .moderate }
            return .low
        case .over100:
            if questionnaire.score > 35 { return .high }
            if questionnaire.score > 30 { return .moderate }
            return .low
        }
    }
}
