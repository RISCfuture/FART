import SwiftUI
import Defaults

struct PilotProfileView: View {
    @Default(.rating) private var rating
    @Default(.hours) private var hours
    @Default(.shortRunway) private var shortRunway
    @Default(.strongWinds) private var strongWinds
    @Default(.strongCrosswinds) private var strongCrosswinds
    @Default(.lowCeiling) private var lowCeiling
    @Default(.lowVisibility) private var lowVisibility

    var body: some View {
        Form {
            List {
                Section {
                    HStack {
                        Text("Rating")
                        Picker("", selection: $rating) {
                            Text("VFR").tag(Rating.VFR)
                            Text("IFR").tag(Rating.IFR)
                        }
                    }
                    HStack {
                        Text("Hours")
                        Picker("", selection: $hours) {
                            Text("< 100").tag(Hours.under100)
                            Text("> 100").tag(Hours.over100)
                        }
                    }
                }

                Section {
                    HStack {
                        Text("Short runway")
                        IntegerField("", value: $shortRunway, formatter: runwayLengthFormatter)
                            .multilineTextAlignment(.trailing)
                        Text("ft. or less").foregroundColor(.secondary)
                    }
                }

                Section {
                    HStack {
                        Text("Strong winds")
                        IntegerField("", value: $strongWinds, formatter: windSpeedFormatter)
                            .multilineTextAlignment(.trailing)
                        Text("kts. or more").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Strong crosswinds")
                        IntegerField("", value: $strongCrosswinds, formatter: windSpeedFormatter)
                            .multilineTextAlignment(.trailing)
                        Text("kts. or more").foregroundColor(.secondary)
                    }

                    if rating == .IFR {
                        HStack {
                            Text("Low ceiling")
                            Picker("", selection: $lowCeiling) {
                                ForEach(Ceiling.allCases, id: \.rawValue) { value in
                                    Text("\(value.stringValue)′").tag(value)
                                }
                            }
                        }

                        HStack {
                            Text("Low visibility")
                            Picker("", selection: $lowVisibility) {
                                ForEach(Visibility.allCases, id: \.rawValue) { value in
                                    Text("\(value.stringValue) SM").tag(value)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    Form {
        List {
            PilotProfileView()
        }
    }
}
