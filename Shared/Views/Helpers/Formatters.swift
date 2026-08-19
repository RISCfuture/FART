import Foundation

/// How a runway length is written in a field: whole feet, grouped, with the unit abbreviated.
let runwayLengthFormat: Measurement<UnitLength>.FormatStyle = .measurement(
  width: .abbreviated,
  usage: .asProvided,
  numberFormatStyle: .number.precision(.fractionLength(0))
)

/// How a wind speed is written in a field: whole knots with the unit abbreviated.
let windSpeedFormat: Measurement<UnitSpeed>.FormatStyle = .measurement(
  width: .abbreviated,
  usage: .asProvided,
  numberFormatStyle: .number.precision(.fractionLength(0))
)

/// Formats a wind speed as a localized knots phrase, e.g. “15 knots” or “1 knot”.
///
/// Aviation units are fixed worldwide, so the speed is converted to knots and
/// `usage: .asProvided` holds it there regardless of locale; Foundation still localizes the
/// unit word and its pluralization. Use via ``Foundation/FormatStyle/asKnots``:
/// `Text("… \(speed, format: .asKnots)")`.
struct KnotsFormatStyle: FormatStyle {
  func format(_ speed: Measurement<UnitSpeed>) -> String {
    speed.converted(to: .knots)
      .formatted(.measurement(width: .wide, usage: .asProvided))
  }
}

/// Formats a length as a localized feet phrase, e.g. “3,000 feet” or “1 foot”.
///
/// As with ``KnotsFormatStyle``, the length is converted to feet and held there while
/// Foundation localizes the word, grouping separator, and pluralization.
struct FeetFormatStyle: FormatStyle {
  func format(_ length: Measurement<UnitLength>) -> String {
    length.converted(to: .feet)
      .formatted(.measurement(width: .wide, usage: .asProvided))
  }
}

extension FormatStyle where Self == KnotsFormatStyle {
  /// A localized knots phrase for a speed, e.g. “15 knots”.
  static var asKnots: Self { .init() }
}

extension FormatStyle where Self == FeetFormatStyle {
  /// A localized feet phrase for a length, e.g. “3,000 feet”.
  static var asFeet: Self { .init() }
}
