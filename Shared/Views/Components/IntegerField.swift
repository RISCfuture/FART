import SwiftUI

struct IntegerField: View {
    @Binding var value: Int
    @State private var lastValidValue = 0

    var formatter: NumberFormatter
    var titleKey = ""

    private var stringValue: Binding<String> {
        Binding<String>(get: {
            formatter.string(from: NSNumber(value: value))!
        }, set: { newValue in
            let strippedValue = newValue.removingCharacters(in: CharacterSet.decimalDigits.inverted)
            if let newNum = formatter.number(from: strippedValue) {
                value = newNum.intValue
                lastValidValue = value
            } else {
                value = lastValidValue
            }
        })
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
}

#Preview {
    @Previewable @State var value = 0

    return Form {
        IntegerField("Value", value: $value, formatter: windSpeedFormatter)
    }
}
