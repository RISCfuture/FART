import SwiftUI

@main
struct Flight_Assessment_of_Risk_ToolApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(Controller())
        }
    }
}
