import Sentry
import SwiftData
import SwiftUI

#if os(iOS)
  import UIKit
#endif

@main
struct Flight_Assessment_of_Risk_ToolApp: App {
  // MARK: - SwiftData Container

  let modelContainer: ModelContainer

  // MARK: - Body

  #if os(macOS)
    var body: some Scene {
      WindowGroup("Flight Assessment of Risk Tool") {
        NavigationStack {
          ContentView()
        }
        .frame(minWidth: 700, minHeight: 500)
        .frame(idealWidth: 900, idealHeight: 650)
      }
      .windowStyle(.titleBar)
      .windowToolbarStyle(.unified)
      .modelContainer(modelContainer)
    }

  #else
    var body: some Scene {
      WindowGroup("Flight Assessment of Risk Tool") {
        ContentView()
      }
      .modelContainer(modelContainer)
    }
  #endif

  init() {
    let isUITesting = ProcessInfo.processInfo.arguments.contains("UI-TESTING")
    let isUnitTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

    // MARK: - SwiftData Setup

    let schema = Schema([
      PilotProfile.self
    ])

    // Use an in-memory store while testing so each run starts from a clean slate
    // and never touches the user's data; CloudKit can't back an in-memory store,
    // so disable it there too.
    let isTesting = isUITesting || isUnitTesting
    let modelConfiguration = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: isTesting,
      cloudKitDatabase: isTesting ? .none : .automatic
    )

    do {
      modelContainer = try ModelContainer(
        for: schema,
        configurations: [modelConfiguration]
      )
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }

    // Skip Sentry initialization during UI testing or unit testing
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

    // MARK: - Sentry Setup

    SentrySDK.start { options in
      options.dsn =
        "https://ca34bdbb2d92e968036855adc9831fa1@o4510156629475328.ingest.us.sentry.io/4510160946200576"
      options.debug = true  // Enabled debug when first installing is always helpful

      // Adds IP for users.
      // For more information, visit: https://docs.sentry.io/platforms/apple/data-management/data-collected/
      options.sendDefaultPii = true

      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0

      // Configure profiling. Visit https://docs.sentry.io/platforms/apple/profiling/ to learn more.
      options.configureProfiling = {
        $0.sessionSampleRate = 1.0  // We recommend adjusting this value in production.
        $0.lifecycle = .trace
      }

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
