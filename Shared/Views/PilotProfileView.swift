import Defaults
import MeasurementKitUI
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
      Section {
        HStack {
          Text("Rating")
          Picker("", selection: $rating) {
            Text("VFR").tag(Rating.VFR)
              .accessibilityIdentifier("ratingVFR")
            Text("IFR").tag(Rating.IFR)
              .accessibilityIdentifier("ratingIFR")
          }
          .accessibilityIdentifier("ratingPicker")
        }
        HStack {
          Text("Hours")
          Picker("", selection: $hours) {
            Text("< 100").tag(Hours.under100)
              .accessibilityIdentifier("hoursUnder100")
            Text("> 100").tag(Hours.over100)
              .accessibilityIdentifier("hoursOver100")
          }
          .accessibilityIdentifier("hoursPicker")
        }
      }

      Section {
        HStack {
          Text("Short runway")
          MeasurementField(
            "Short runway",
            value: $shortRunway,
            in: .feet,
            format: runwayLengthFormat,
            keypad: .whole
          )
          .accessibilityIdentifier("shortRunwayField")
        }
      } footer: {
        Text("Runways this length or shorter count as a short runway.")
      }

      Section {
        HStack {
          Text("Strong winds")
          MeasurementField(
            "Strong winds",
            value: $strongWinds,
            in: .knots,
            format: windSpeedFormat,
            keypad: .whole
          )
          .accessibilityIdentifier("strongWindsField")
        }
        HStack {
          Text("Strong crosswinds")
          MeasurementField(
            "Strong crosswinds",
            value: $strongCrosswinds,
            in: .knots,
            format: windSpeedFormat,
            keypad: .whole
          )
          .accessibilityIdentifier("strongCrosswindsField")
        }
      } footer: {
        Text("Winds or crosswinds at this speed or faster count as strong.")
      }

      if rating == .IFR {
        Section {
          HStack {
            Text("Low ceiling")
            Picker("", selection: $lowCeiling) {
              ForEach(Ceiling.allCases, id: \.rawValue) { value in
                Text(value.height, format: .asFeet).tag(value)
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
    // The threshold fields sit inline beside their labels, where the platform's bordered field
    // would box the digits and leave the unit outside the box. iOS draws them unadorned already.
    #if !os(iOS)
      .textFieldStyle(.plain)
    #endif
  }
}

#Preview {
  PilotProfileView()
}
