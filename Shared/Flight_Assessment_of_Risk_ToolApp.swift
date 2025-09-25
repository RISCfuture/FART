import SwiftUI

@main
struct Flight_Assessment_of_Risk_ToolApp: App {

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
