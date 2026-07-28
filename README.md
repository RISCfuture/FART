# Flight Assessment of Risk Tool

[![CI](https://github.com/RISCfuture/FART/actions/workflows/ci.yml/badge.svg)](https://github.com/RISCfuture/FART/actions/workflows/ci.yml)
[![Lint](https://github.com/RISCfuture/FART/actions/workflows/lint.yml/badge.svg)](https://github.com/RISCfuture/FART/actions/workflows/lint.yml)
[![App Store](https://img.shields.io/itunes/v/1570992859.svg)](https://apps.apple.com/app/id1570992859)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20visionOS-lightgrey.svg)](https://developer.apple.com/)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A SwiftUI app implementing the FAASafety Team's
[Flight Risk Assessment Tool](https://www.faa.gov/news/safety_briefing/2016/media/SE_Topic_16-12.pdf).
More at [riscfuture.github.io/FART](https://riscfuture.github.io/FART/).

## What it does

Answer a short questionnaire before a flight — recent experience, conditions,
airports, weather — and each answer adds or subtracts points. The total is
weighed against thresholds that depend on your rating and total time, and comes
back as low, moderate, or high risk. It is a tool for thinking through the
hazards of a flight, not for making the go/no-go decision.

## Architecture

- `Shared/Models` — `Questionnaire`, an `@Observable` holding every answer, and
  the `Pilot` profile, persisted with
  [Defaults](https://github.com/sindresorhus/Defaults).
- `Shared/Behaivor` — `FARTScoreCalculator` and `RiskCategorizer`, pure functions
  over a `QuestionnaireData` snapshot. This is where the scoring rules live and
  what the unit tests cover.
- `Shared/Views` — `ContentView` chooses a `TabView` in the compact size class
  and a `NavigationSplitView` in the regular one, so iPad and Mac show the
  questionnaire and the score side by side.
- `macOS/` — menu-bar commands, and printing and PDF export of the report.

Sentry reports crashes and performance data, and is disabled under test and on
the simulator.

## Development

Xcode 26.6 or newer, for Swift 6.3; every platform deploys to 26.0. Dependencies
resolve through Swift Package Manager, so the project builds and tests straight
from a checkout.

There are three test plans: **Unit Tests** for the scoring rules, **UI Tests**
for the major flows, and **Generate Screenshots**, which drives the App Store
and marketing captures.

fastlane handles those screenshots and App Store releases. Its Ruby comes from
RVM by way of `.ruby-version` and `.ruby-gemset`; run `bundle install` once,
then `fastlane snapshot`.
