import SwiftUI

struct AboutView: View {
    @Environment(\.openURL) private var openURL

    private var moreInfoURL = URL(string: "https://www.faa.gov/news/safety_briefing/2016/media/SE_Topic_16-12.pdf")!
    private var sourceURL = URL(string: "https://github.com/RISCfuture/FART")!

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Flight Assessment of Risk Tool is developed using the FAA Safety Team’s Flight Risk Assessment Tool.")
                    .multilineTextAlignment(.leading)
                Button("More information about FAAST FRAT") {
                    openURL(moreInfoURL)
                }

                Text("Copyright ©2021 Tim Morgan. Source code is available under the MIT License.")
                Button("View source code") {
                    openURL(sourceURL)
                }

                Text("Icons in this application are from The Noun Project:")
                    .multilineTextAlignment(.leading)
                VStack(alignment: .leading, spacing: 0) {
                    Text("• Captain by Vectors Market")
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                    Text("• Captain’s Hat by David Brossard")
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                    Text("• Checklist by The Icon Z")
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                    Text("• Speedometer by Yash Gohel")
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
        }.padding(.top, 10)
    }
}

#Preview {
    AboutView()
}
