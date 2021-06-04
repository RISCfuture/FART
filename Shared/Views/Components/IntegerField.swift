import SwiftUI

struct IntegerField: View {
    @Binding var value: Int
    @State var lastValidValue = 0
    
    var formatter: NumberFormatter
    var titleKey = ""
    
    init(_ titleKey: String, value: Binding<Int>, formatter: NumberFormatter) {
        self._value = value
        self.formatter = formatter
        lastValidValue = value.wrappedValue
    }
    
    private var stringValue: Binding<String> {
        Binding<String>(get: {
            self.formatter.string(from: NSNumber(integerLiteral: self.value))!
        }, set: { newValue in
            let strippedValue = newValue.removingCharacters(in: CharacterSet.decimalDigits.inverted)
            if let newNum = self.formatter.number(from: strippedValue) {
                self.value = newNum.intValue
                self.lastValidValue = self.value
            } else {
                self.value = self.lastValidValue
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
}

struct IntegerField_Previews: PreviewProvider {
    @State static var value = 0
    
    static var previews: some View {
        IntegerField("Value", value: $value, formatter: windSpeedFormatter)
    }
}
