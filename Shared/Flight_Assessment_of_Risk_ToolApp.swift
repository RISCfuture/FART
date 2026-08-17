import Sentry
import SwiftUI

#if os(iOS)
  import UIKit
#endif

@main
struct Flight_Assessment_of_Risk_ToolApp: App {
  #if os(macOS)
    var body: some Scene {
      WindowGroup("Flight Assessment of Risk Tool", id: FARTWindowID.main) {
        NavigationStack {
          ContentView()
        }
        .frame(minWidth: 700, minHeight: 500)
        .frame(idealWidth: 900, idealHeight: 650)
      }
      .windowStyle(.titleBar)
      .windowToolbarStyle(.unified)
      .commands { FARTCommands() }

      Settings {
        PilotProfileView()
          .formStyle(.grouped)
          .frame(width: 420)
      }

      Window("About Flight Assessment of Risk Tool", id: FARTWindowID.about) {
        AboutView()
          .frame(width: 420, height: 320)
      }
      .windowResizability(.contentSize)
      .windowBackgroundDragBehavior(.enabled)

      Window("Welcome to FART", id: FARTWindowID.welcome) {
        WelcomeView()
      }
      .windowResizability(.contentSize)
      .windowBackgroundDragBehavior(.enabled)
    }

  #else
    var body: some Scene {
      WindowGroup("Flight Assessment of Risk Tool") {
        ContentView()
      }
    }
  #endif

  init() {
    // Skip Sentry initialization during UI testing or unit testing
    let isUITesting = ProcessInfo.processInfo.arguments.contains("UI-TESTING")
    let isUnitTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

    if isUITesting {
      if let bundleID = Bundle.main.bundleIdentifier {
        UserDefaults.standard.removePersistentDomain(forName: bundleID)
      }
      #if os(iOS)
        UIView.setAnimationsEnabled(false)
      #endif
      return
    }

    if isUnitTesting {
      return
    }

    SentrySDK.start { options in
      options.dsn =
        "https://ca34bdbb2d92e968036855adc9831fa1@o4510156629475328.ingest.us.sentry.io/4510160946200576"
      // The SDK's own logging is for whoever is working on the app, not for a device in the field.
      #if DEBUG
        options.debug = true
      #endif

      // There are no accounts here, and the privacy manifest declares diagnostics as not linked to
      // identity — so never attach the user's IP address or other identifying context to an event.
      options.sendDefaultPii = false

      // A fifth of the traffic is enough to spot a performance regression in an app this size, and
      // it leaves the quota and the device's battery for the crashes that actually matter.
      options.tracesSampleRate = 0.2

      // Configure profiling. Visit https://docs.sentry.io/platforms/apple/profiling/ to learn more.
      // Sentry's profiling API is unavailable on visionOS.
      #if !os(visionOS)
        options.configureProfiling = {
          $0.sessionSampleRate = 0.2
          $0.lifecycle = .trace
        }
      #endif

      // Uncomment the following lines to add more data to your events
      // options.attachScreenshot = true // This adds a screenshot to the error events
      // options.attachViewHierarchy = true // This adds the view hierarchy to the error events

      // Enable logging features
      options.enableLogs = true

      // Discard all events when running on simulator
      options.beforeSend = { event in
        #if targetEnvironment(simulator)
          return nil
        #else
          return event
        #endif
      }
    }
  }
}

#if os(macOS)
  /// The app's menu-bar commands: opening windows, resetting the assessment, printing and
  /// exporting the report, and Help links. Reset/Print/Export act on the key window's
  /// questionnaire, exposed through `FocusedValues`.
  private struct FARTCommands: Commands {
    @Environment(\.openWindow)
    private var openWindow

    @FocusedValue(\.questionnaire)
    private var questionnaire

    var body: some Commands {
      CommandGroup(replacing: .appInfo) {
        Button("About Flight Assessment of Risk Tool") {
          openWindow(id: FARTWindowID.about)
        }
      }

      CommandGroup(replacing: .newItem) {
        Button("New FRAT") { openWindow(id: FARTWindowID.main) }
          .keyboardShortcut("n")
      }

      CommandGroup(after: .newItem) {
        Button("Reset FRAT") { questionnaire?.reset() }
          .keyboardShortcut(.delete, modifiers: [.command, .shift])
          .disabled(questionnaire == nil)
      }

      CommandGroup(replacing: .printItem) {
        Button("Print FRAT…", action: printReport)
          .keyboardShortcut("p")
          .disabled(questionnaire == nil)
        Button("Export FRAT as PDF…", action: exportPDF)
          .keyboardShortcut("e", modifiers: [.command, .shift])
          .disabled(questionnaire == nil)
      }

      CommandGroup(replacing: .help) {
        Link("FAA Flight Risk Assessment Guide", destination: ExternalLinks.faaFRAT)
        Link("FART on GitHub", destination: ExternalLinks.sourceCode)
      }
    }

    private func printReport() {
      guard let questionnaire else { return }
      FRATReportExporter.printReport(.init(questionnaire: questionnaire, generatedAt: Date()))
    }

    private func exportPDF() {
      guard let questionnaire else { return }
      FRATReportExporter.exportPDF(.init(questionnaire: questionnaire, generatedAt: Date()))
    }
  }
#endif
