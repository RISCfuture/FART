import SwiftUI

struct PilotProfileView: View {
    @EnvironmentObject var pilot: Pilot
    
    var body: some View {
        Form {
            List {
                Section {
                    HStack {
                        Text("Rating")
                        Picker("", selection: $pilot.rating) {
                            Text("VFR").tag(Rating.VFR)
                            Text("IFR").tag(Rating.IFR)
                        }
                    }
                    HStack {
                        Text("Hours")
                        Picker("", selection: $pilot.hours) {
                            Text("< 100").tag(Hours.under100)
                            Text("> 100").tag(Hours.over100)
                        }
                    }
                }
                
                Section {
                    HStack {
                        Text("Short runway")
                        IntegerField("", value: $pilot.shortRunway, formatter: runwayLengthFormatter)
                            .multilineTextAlignment(.trailing)
                        Text("ft. or less").foregroundColor(.secondary)
                    }
                }
                
                Section {
                    HStack {
                        Text("Strong winds")
                        IntegerField("", value: $pilot.strongWinds, formatter: windSpeedFormatter)
                            .multilineTextAlignment(.trailing)
                        Text("kts. or more").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Strong crosswinds")
                        IntegerField("", value: $pilot.strongCrosswinds, formatter: windSpeedFormatter)
                            .multilineTextAlignment(.trailing)
                        Text("kts. or more").foregroundColor(.secondary)
                    }
                    
                    if pilot.rating == .IFR {
                        HStack {
                            Text("Low ceiling")
                            Picker("", selection: $pilot.lowCeiling) {
                                ForEach(Ceiling.allCases, id: \.rawValue) { value in
                                    Text("\(value.stringValue)′").tag(value)
                                }
                            }
                        }
                        
                        HStack {
                            Text("Low visibility")
                            Picker("", selection: $pilot.lowVisibility) {
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

struct PilotProfileView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            List {
                PilotProfileView().environmentObject(Pilot())
            }
        }
    }
}
