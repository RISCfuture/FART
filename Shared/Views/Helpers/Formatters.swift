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

extension Unit {
  /// This unit's abbreviation in `locale`, e.g. “ft” or “kn”.
  ///
  /// Labels a field whose value is edited as a bare number, where formatting the whole
  /// measurement would repeat the value the field already shows. `MeasurementFormatter` is
  /// what localizes a unit on its own, so the abbreviation is never spelled out here.
  func abbreviation(in locale: Locale = .current) -> String {
    let formatter = MeasurementFormatter()
    formatter.locale = locale
    formatter.unitOptions = .providedUnit
    formatter.unitStyle = .short
    return formatter.string(from: self)
  }
}

extension Measurement where UnitType: Dimension {
  /// The text `locale` writes before and after this measurement's number, spacing included,
  /// for placing a unit around a field that edits the number on its own.
  ///
  /// The arrangement is read back from how the locale actually writes *this* value rather
  /// than assumed, because both the unit and its position shift with the number: Sinhala and
  /// Swahili lead with the unit, Nepali runs it onto the number with no space, Faroese
  /// inflects it, and Hebrew moves it to the front for a value of one.
  func affixes(in locale: Locale = .current) -> (prefix: String, suffix: String) {
    let written = formatted(
      .measurement(width: .abbreviated, usage: .asProvided).locale(locale)
    )
    let number = value.formatted(.number.precision(.fractionLength(0)).locale(locale))

    guard let numberRange = written.range(of: number) else {
      return unit.arrangedAffixes(in: locale)
    }

    return (
      String(written[..<numberRange.lowerBound]),
      String(written[numberRange.upperBound...])
    )
  }
}

extension Unit {
  /// Where to put this unit when the locale writes a measurement with no number to read an
  /// arrangement from — Arabic writes one foot as “قدم” and two as “قدمان”, neither of which
  /// leaves a field anywhere to show the value being edited.
  ///
  /// The order lives in the string catalog so a translator can swap the placeholders for a
  /// language that writes the unit first.
  fileprivate func arrangedAffixes(in locale: Locale) -> (prefix: String, suffix: String) {
    let arrangement = String(
      localized: "unitArrangement",
      defaultValue: "%1$@ %2$@",
      locale: locale,
      comment: """
        Arranges an editable number and its unit beside each other, e.g. “30 ft”. The first \
        placeholder is the number and the second is the unit; swap them if this language writes \
        the unit first.
        """
    )
    let unitText = abbreviation(in: locale)
    let sides = arrangement.components(separatedBy: "%1$@")
    guard sides.count == 2 else { return ("", unitText) }

    return (
      sides[0].replacingOccurrences(of: "%2$@", with: unitText),
      sides[1].replacingOccurrences(of: "%2$@", with: unitText)
    )
  }
}
