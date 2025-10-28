import Sentry
import SwiftUI

@main
struct Flight_Assessment_of_Risk_ToolApp: App {
  init() {
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

      // Enable experimental logging features
      options.experimental.enableLogs = true

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

  #if os(macOS)
    var body: some Scene {
      WindowGroup("Flight Assessment of Risk Tool") {
        ContentView()
          .frame(minWidth: 600, minHeight: 600)
      }
    }

  #else
    var body: some Scene {
      WindowGroup("Flight Assessment of Risk Tool") {
        ContentView()
      }
    }
  #endif
}
