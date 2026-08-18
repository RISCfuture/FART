import SwiftUI

struct IntegerField: View {
  @Binding var value: Int
  @State private var lastValidValue = 0

  var formatter: NumberFormatter
  var titleKey = ""

  private var stringValue: Binding<String> {
    Binding<String>(
      get: {
        formatter.string(from: NSNumber(value: value))!
      },
      set: { newValue in
        let strippedValue = newValue.removingCharacters(in: CharacterSet.decimalDigits.inverted)
        if let newNum = formatter.number(from: strippedValue) {
          value = newNum.intValue
          lastValidValue = value
        } else {
          value = lastValidValue
        }
      }
    )
  }

  var body: some View {
    #if os(iOS)
      TextField(titleKey, text: stringValue)
        .keyboardType(.numberPad)
    #else
      TextField(titleKey, text: stringValue)
        .textFieldStyle(PlainTextFieldStyle())
    #endif
  }

  init(_: String, value: Binding<Int>, formatter: NumberFormatter) {
    self._value = value
    self.formatter = formatter
    lastValidValue = value.wrappedValue
  }

  /// Edits a measurement as a whole number of `unit`.
  ///
  /// A text field is one of the few places a measurement has to become a primitive: the
  /// value is converted to `unit` on the way into the field and reconstituted in that same
  /// unit on the way out, so the dimension never leaves this initializer.
  init<UnitType: Dimension>(
    _ titleKey: String,
    value: Binding<Measurement<UnitType>>,
    in unit: UnitType,
    formatter: NumberFormatter
  ) {
    self.init(
      titleKey,
      value: Binding(
        get: { Int(value.wrappedValue.converted(to: unit).value.rounded()) },
        set: { value.wrappedValue = Measurement(value: Double($0), unit: unit) }
      ),
      formatter: formatter
    )
  }
}

#Preview {
  @Previewable @State var value = 0

  return Form {
    IntegerField("Value", value: $value, formatter: windSpeedFormatter)
  }
}
