# ``Flight_Assessment_of_Risk_Tool``

The FAASafety Team's Flight Risk Assessment Tool, as a SwiftUI app for iOS, macOS, and visionOS.

## Overview

Answer a short questionnaire before a flight — recent experience, conditions, airports, weather —
and each answer adds or subtracts points. The total is weighed against thresholds that depend on
the pilot's rating and total time, and comes back as low, moderate, or high risk. It is a tool for
thinking through the hazards of a flight, not for making the go/no-go decision.

## Topics

### Answering the questionnaire

- ``Questionnaire``
- ``QuestionnaireData``
- ``Rating``

### Scoring

- ``FARTScoreCalculator``
- ``RiskCategorizer``
- ``Risk``
- ``RegulatoryThresholds``
