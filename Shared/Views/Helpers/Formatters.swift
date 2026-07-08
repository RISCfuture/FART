import Foundation

let runwayLengthFormatter: NumberFormatter = {
  let formatter = NumberFormatter()
  formatter.numberStyle = .decimal
  formatter.maximumFractionDigits = 0
  return formatter
}()

let windSpeedFormatter: NumberFormatter = {
  let formatter = NumberFormatter()
  formatter.numberStyle = .decimal
  formatter.maximumFractionDigits = 0
  return formatter
}()

/// Formats an integer wind speed as a localized knots phrase, e.g. “15 knots” or “1 knot”.
///
/// Aviation units are fixed worldwide, so `usage: .asProvided` holds the unit at knots
/// regardless of locale; Foundation still localizes the unit word and its pluralization.
/// Use via ``Foundation/FormatStyle/asKnots``: `Text("… \(speed, format: .asKnots)")`.
struct KnotsFormatStyle: FormatStyle {
  func format(_ speed: Int) -> String {
    Measurement(value: Double(speed), unit: UnitSpeed.knots)
      .formatted(.measurement(width: .wide, usage: .asProvided))
  }
}

/// Formats an integer length as a localized feet phrase, e.g. “3,000 feet” or “1 foot”.
///
/// As with ``KnotsFormatStyle``, `usage: .asProvided` holds the unit at feet while
/// Foundation localizes the word, grouping separator, and pluralization.
struct FeetFormatStyle: FormatStyle {
  func format(_ length: Int) -> String {
    Measurement(value: Double(length), unit: UnitLength.feet)
      .formatted(.measurement(width: .wide, usage: .asProvided))
  }
}

extension FormatStyle where Self == KnotsFormatStyle {
  /// A localized knots phrase for an integer speed, e.g. “15 knots”.
  static var asKnots: Self { .init() }
}

extension FormatStyle where Self == FeetFormatStyle {
  /// A localized feet phrase for an integer length, e.g. “3,000 feet”.
  static var asFeet: Self { .init() }
}
