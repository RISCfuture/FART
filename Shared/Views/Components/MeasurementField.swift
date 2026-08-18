import SwiftUI

/// A text field for editing a measurement, showing the unit on the side of the number that
/// the current locale puts it on.
///
/// The unit is placed by ``Foundation/Measurement/affixes(in:)`` rather than pinned to one
/// side, so a locale that leads with the unit, or runs it onto the number without a space,
/// reads correctly. Reading the arrangement from the value being edited also keeps it right
/// as that value changes, in languages that move or inflect the unit for particular numbers.
struct MeasurementField<UnitType: Dimension>: View {
  @Binding var value: Measurement<UnitType>

  let unit: UnitType
  let formatter: NumberFormatter

  var body: some View {
    let affixes = value.converted(to: unit).affixes()

    HStack(spacing: 0) {
      Text(verbatim: affixes.prefix).foregroundStyle(.secondary)
      IntegerField("", value: $value, in: unit, formatter: formatter)
        .multilineTextAlignment(.trailing)
      Text(verbatim: affixes.suffix).foregroundStyle(.secondary)
    }
  }

  init(value: Binding<Measurement<UnitType>>, in unit: UnitType, formatter: NumberFormatter) {
    self._value = value
    self.unit = unit
    self.formatter = formatter
  }
}

#Preview {
  @Previewable @State var runway = Measurement(value: 3000, unit: UnitLength.feet)
  @Previewable @State var wind = Measurement(value: 15, unit: UnitSpeed.knots)

  return Form {
    HStack {
      Text("Short runway")
      MeasurementField(value: $runway, in: .feet, formatter: runwayLengthFormatter)
    }
    HStack {
      Text("Strong winds")
      MeasurementField(value: $wind, in: .knots, formatter: windSpeedFormatter)
    }
  }
}
