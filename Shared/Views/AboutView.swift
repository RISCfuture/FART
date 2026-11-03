import SwiftUI
import WebKit

#if os(macOS)
  import AppKit
#else
  import UIKit
#endif

struct AboutView: View {
  #if os(macOS)
    @Environment(\.openURL)
    private var openURL
  #else
    @Binding var webLink: WebLink?
  #endif

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
          open(ExternalLinks.faaFRAT, title: "FAAST FRAT")
        }
        .glassButtonStyle()
        .accessibilityIdentifier("moreInfoButton")

        Text("Copyright ©2021 Tim Morgan. Source code is available under the MIT License.")
          .accessibilityIdentifier("aboutCopyrightText")
        Button("View source code") {
          open(ExternalLinks.sourceCode, title: "Source Code")
        }
        .glassButtonStyle()
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

  private func open(_ url: URL, title: LocalizedStringKey) {
    #if os(macOS)
      openURL(url)
    #else
      webLink = WebLink(title: title, url: url)
    #endif
  }
}

#if !os(macOS)
  /// A web destination presented in-app rather than kicking the pilot out to the browser.
  struct WebLink: Identifiable {
    var id: URL { url }

    let title: LocalizedStringKey
    let url: URL
  }

  struct WebLinkSheet: View {
    let link: WebLink
    let onDone: () -> Void

    var body: some View {
      NavigationStack {
        WebView(url: link.url)
          .navigationTitle(link.title)
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .cancellationAction) {
              Button(role: .close, action: onDone)
            }
          }
          .horizontalToolbar()
      }
    }
  }
#endif

private extension View {
  /// Keeps the toolbar horizontal where iPhone Duo's outer display would otherwise make it a
  /// vertical bar, which would take width from the content for a single button.
  @ViewBuilder
  func horizontalToolbar() -> some View {
    #if os(iOS)
      if #available(iOS 27.1, *) {
        toolbarVerticalBehavior(.disabled)
      } else {
        self
      }
    #else
      self
    #endif
  }

  /// Applies the glass button style, which is unavailable on visionOS — there the platform's
  /// default (already glass-like) button style is used instead.
  @ViewBuilder
  func glassButtonStyle() -> some View {
    #if os(visionOS)
      self
    #else
      buttonStyle(.glass)
    #endif
  }
}

/// Displays the running application's own icon, resolved from the bundle.
private struct AppIconView: View {
  private static let side = 72.0

  var body: some View {
    #if os(macOS)
      Image(nsImage: NSApplication.shared.applicationIconImage)
        .resizable()
        .scaledToFit()
        .frame(width: Self.side, height: Self.side)
        .accessibilityLabel("Application icon")
        .accessibilityIdentifier("appIconImage")
    #else
      if let icon = bundleIcon {
        Image(uiImage: icon)
          .resizable()
          .scaledToFit()
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

/// External web destinations referenced across the app.
enum ExternalLinks {
  /// The FAA Safety Team's page for its Flight Risk Assessment Tool.
  static let faaFRAT = URL(
    string: "https://www.faa.gov/general/flight-risk-assessment-tool-frat-faa-safety-team"
  )!

  /// The app's open-source repository.
  static let sourceCode = URL(string: "https://github.com/RISCfuture/FART")!
}

#Preview {
  #if os(macOS)
    AboutView()
  #else
    AboutView(webLink: .constant(nil))
  #endif
}
