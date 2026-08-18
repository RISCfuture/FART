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
          MeasurementField(value: $shortRunway, in: .feet, formatter: runwayLengthFormatter)
            .accessibilityIdentifier("shortRunwayField")
        }
      } footer: {
        Text("Runways this length or shorter count as a short runway.")
      }

      Section {
        HStack {
          Text("Strong winds")
          MeasurementField(value: $strongWinds, in: .knots, formatter: windSpeedFormatter)
            .accessibilityIdentifier("strongWindsField")
        }
        HStack {
          Text("Strong crosswinds")
          MeasurementField(value: $strongCrosswinds, in: .knots, formatter: windSpeedFormatter)
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
  }
}

#Preview {
  PilotProfileView()
}
