import SwiftData
import SwiftUI

struct PilotProfileView: View {
  @Query(
    filter: #Predicate<PilotProfile> { $0.isActive == true },
    sort: \PilotProfile.updatedAt,
    order: .reverse
  )
  private var profiles: [PilotProfile]

  @Environment(\.modelContext) private var modelContext
  @Environment(Questionnaire.self) private var questionnaire

  private var activeProfile: PilotProfile? {
    profiles.first
  }

  var body: some View {
    if let profile = activeProfile {
      ProfileForm(profile: profile, questionnaire: questionnaire)
    } else {
      Text("Loading profile...")
        .onAppear {
          createDefaultProfileIfNeeded()
        }
    }
  }

  private func createDefaultProfileIfNeeded() {
    if profiles.isEmpty {
      let newProfile = PilotProfile()
      modelContext.insert(newProfile)
      try? modelContext.save()
    }
  }
}

private struct ProfileForm: View {
  @Bindable var profile: PilotProfile
  var questionnaire: Questionnaire

  var body: some View {
    Form {
      List {
        Section {
          HStack {
            Text("Rating")
            Picker("", selection: $profile.rating) {
              Text("VFR").tag(Rating.VFR)
                .accessibilityIdentifier("ratingVFR")
              Text("IFR").tag(Rating.IFR)
            }
            .accessibilityIdentifier("ratingPicker")
            .onChange(of: profile.rating) {
              questionnaire.setProfile(profile)
            }
          }
          HStack {
            Text("Hours")
            Picker("", selection: $profile.hours) {
              Text("< 100").tag(Hours.under100)
              Text("> 100").tag(Hours.over100)
                .accessibilityIdentifier("hoursOver100")
            }
            .accessibilityIdentifier("hoursPicker")
            .onChange(of: profile.hours) {
              questionnaire.setProfile(profile)
            }
          }
        }

        Section {
          HStack {
            Text("Short runway")
            IntegerField("", value: $profile.shortRunway, formatter: runwayLengthFormatter)
              .multilineTextAlignment(.trailing)
              .accessibilityIdentifier("shortRunwayField")
            Text("ft. or less").foregroundColor(.secondary)
          }
        }

        Section {
          HStack {
            Text("Strong winds")
            IntegerField("", value: $profile.strongWinds, formatter: windSpeedFormatter)
              .multilineTextAlignment(.trailing)
              .accessibilityIdentifier("strongWindsField")
            Text("kts. or more").foregroundColor(.secondary)
          }
          HStack {
            Text("Strong crosswinds")
            IntegerField("", value: $profile.strongCrosswinds, formatter: windSpeedFormatter)
              .multilineTextAlignment(.trailing)
              .accessibilityIdentifier("strongCrosswindsField")
            Text("kts. or more").foregroundColor(.secondary)
          }

          if profile.rating == .IFR {
            HStack {
              Text("Low ceiling")
              Picker("", selection: $profile.lowCeiling) {
                ForEach(Ceiling.allCases, id: \.rawValue) { value in
                  Text("\(value.stringValue)′").tag(value)
                }
              }
              .accessibilityIdentifier("lowCeilingPicker")
            }

            HStack {
              Text("Low visibility")
              Picker("", selection: $profile.lowVisibility) {
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
