import SwiftUI

#if os(macOS)
  import AppKit
#else
  import UIKit
#endif

struct AboutView: View {
  @Environment(\.openURL)
  private var openURL

  private var moreInfoURL = URL(
    string: "https://www.faa.gov/news/safety_briefing/2016/media/SE_Topic_16-12.pdf"
  )!
  private var sourceURL = URL(string: "https://github.com/RISCfuture/FART")!

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 10) {
        HStack(alignment: .top, spacing: 16) {
          AppIconView()
          Text(
            "Flight Assessment of Risk Tool is developed using the FAA Safety Team’s Flight Risk Assessment Tool."
          )
          .multilineTextAlignment(.leading)
          .accessibilityIdentifier("aboutDescriptionText")
        }
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
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()
    }
  }
}

/// Displays the running application's own icon, resolved from the bundle.
private struct AppIconView: View {
  private static let side = 72.0

  var body: some View {
    #if os(macOS)
      Image(nsImage: NSApplication.shared.applicationIconImage)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: Self.side, height: Self.side)
        .accessibilityLabel("Application icon")
        .accessibilityIdentifier("appIconImage")
    #else
      if let icon = bundleIcon {
        Image(uiImage: icon)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: Self.side, height: Self.side)
          .clipShape(RoundedRectangle(cornerRadius: Self.side * 0.2237, style: .continuous))
          .accessibilityLabel("Application icon")
          .accessibilityIdentifier("appIconImage")
      }
    #endif
  }

  #if !os(macOS)
    private var bundleIcon: UIImage? {
      guard
        let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
        let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
        let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
        let baseName = iconFiles.last
      else { return nil }

      if let image = UIImage(named: baseName) { return image }

      // Packaged app-icon PNGs may only ship a single scale, which
      // `UIImage(named:)` won't match on other-scale devices; load the file directly.
      return ["@3x", "@2x", "@1x", ""]
        .lazy
        .compactMap { Bundle.main.path(forResource: baseName + $0, ofType: "png") }
        .compactMap(UIImage.init(contentsOfFile:))
        .first
    }
  #endif
}

#Preview {
  AboutView()
}
