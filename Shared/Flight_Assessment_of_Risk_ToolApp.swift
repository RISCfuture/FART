import SwiftUI

@main
struct Flight_Assessment_of_Risk_ToolApp: App {
    var body: some Scene {
        WindowGroup {
            #if os(macOS)
            ContentView().environmentObject(Controller())
                .frame(minWidth: 600, minHeight: 600)
            #else
            ContentView().environmentObject(Controller())
            #endif
        }
    }
}
