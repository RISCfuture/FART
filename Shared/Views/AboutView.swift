import SwiftUI

struct AboutView: View {
  @Environment(\.openURL)
  private var openURL

  private var moreInfoURL = URL(
    string: "https://www.faa.gov/news/safety_briefing/2016/media/SE_Topic_16-12.pdf"
  )!
  private var sourceURL = URL(string: "https://github.com/RISCfuture/FART")!

  var body: some View {
    ScrollView {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 10) {
          Text(
            "Flight Assessment of Risk Tool is developed using the FAA Safety Team’s Flight Risk Assessment Tool."
          )
          .multilineTextAlignment(.leading)
          .accessibilityIdentifier("aboutDescriptionText")
          Button("More information about FAAST FRAT") {
            openURL(moreInfoURL)
          }
          .accessibilityIdentifier("moreInfoButton")

          Text("Copyright ©2021 Tim Morgan. Source code is available under the MIT License.")
            .accessibilityIdentifier("aboutCopyrightText")
          Button("View source code") {
            openURL(sourceURL)
          }
          .accessibilityIdentifier("viewSourceCodeButton")

          Text("Icons in this application are from The Noun Project:")
            .accessibilityIdentifier("aboutIconCreditsText")
            .multilineTextAlignment(.leading)
          VStack(alignment: .leading, spacing: 0) {
            Text("• Captain by Vectors Market")
              .font(.caption)
              .multilineTextAlignment(.leading)
            Text("• Captain’s Hat by David Brossard")
              .font(.caption)
              .multilineTextAlignment(.leading)
          }
          Spacer()
        }
      }.padding()
    }
  }
}

#Preview {
  AboutView()
}
