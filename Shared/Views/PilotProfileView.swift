import Defaults
import SwiftUI

struct PilotProfileView: View {
  @Default(.rating)
  private var rating

  @Default(.hours)
  private var hours

  @Default(.shortRunway)
  private var shortRunway

  @Default(.strongWinds)
  private var strongWinds

  @Default(.strongCrosswinds)
  private var strongCrosswinds

  @Default(.lowCeiling)
  private var lowCeiling

  @Default(.lowVisibility)
  private var lowVisibility

  var body: some View {
    Form {
      List {
        Section {
          HStack {
            Text("Rating")
            Picker("", selection: $rating) {
              Text("VFR").tag(Rating.VFR)
                .accessibilityIdentifier("ratingVFR")
              Text("IFR").tag(Rating.IFR)
            }
            .accessibilityIdentifier("ratingPicker")
          }
          HStack {
            Text("Hours")
            Picker("", selection: $hours) {
              Text("< 100").tag(Hours.under100)
              Text("> 100").tag(Hours.over100)
                .accessibilityIdentifier("hoursOver100")
            }
            .accessibilityIdentifier("hoursPicker")
          }
        }

        Section {
          HStack {
            Text("Short runway")
            IntegerField("", value: $shortRunway, formatter: runwayLengthFormatter)
              .multilineTextAlignment(.trailing)
              .accessibilityIdentifier("shortRunwayField")
            Text("ft. or less").foregroundColor(.secondary)
          }
        }

        Section {
          HStack {
            Text("Strong winds")
            IntegerField("", value: $strongWinds, formatter: windSpeedFormatter)
              .multilineTextAlignment(.trailing)
              .accessibilityIdentifier("strongWindsField")
            Text("kts. or more").foregroundColor(.secondary)
          }
          HStack {
            Text("Strong crosswinds")
            IntegerField("", value: $strongCrosswinds, formatter: windSpeedFormatter)
              .multilineTextAlignment(.trailing)
              .accessibilityIdentifier("strongCrosswindsField")
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
              .accessibilityIdentifier("lowCeilingPicker")
            }

            HStack {
              Text("Low visibility")
              Picker("", selection: $lowVisibility) {
                ForEach(Visibility.allCases, id: \.rawValue) { value in
                  Text("\(value.stringValue) SM").tag(value)
                }
              }
              .accessibilityIdentifier("lowVisibilityPicker")
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
