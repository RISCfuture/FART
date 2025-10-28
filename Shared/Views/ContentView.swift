import SwiftUI

struct ContentView: View {
  @State private var questionnaire = Questionnaire()

  @Environment(\.horizontalSizeClass)
  var horizontalSizeClass

  var body: some View {
    switch horizontalSizeClass {
      case .regular: twoColumnLayout
      default: oneColumnLayout
    }
  }

  private var oneColumnLayout: some View {
    TabView {
      NavigationView {
        PilotProfileView()
          .environment(questionnaire)
          .navigationTitle("Pilot Profile")
      }.tabItem { Label("Pilot", image: "Pilot") }
        #if !os(macOS)
          .navigationViewStyle(StackNavigationViewStyle())
        #endif
        .accessibilityIdentifier("pilotTab")

      NavigationView {
        QuestionnaireView()
          .environment(questionnaire)
          .navigationTitle("Questionnaire")
      }.tabItem { Label("Questions", systemImage: "checklist.checked") }
        #if !os(macOS)
          .navigationViewStyle(StackNavigationViewStyle())
        #endif
        .accessibilityIdentifier("questionsTab")

      NavigationView {
        ResultsView()
          .environment(questionnaire)
          .navigationTitle("Results")
      }.tabItem { Label("Results", systemImage: "gauge.with.dots.needle.bottom.0percent") }
        #if !os(macOS)
          .navigationViewStyle(StackNavigationViewStyle())
        #endif
        .accessibilityIdentifier("resultsTab")

      NavigationView {
        AboutView().navigationTitle("About")
      }.tabItem { Label("About", systemImage: "info.circle") }
        #if !os(macOS)
          .navigationViewStyle(StackNavigationViewStyle())
        #endif
        .accessibilityIdentifier("aboutTab")
    }
  }

  private var twoColumnLayout: some View {
    NavigationSplitView(preferredCompactColumn: .constant(.detail)) {
      TabView {
        PilotProfileView()
          .environment(questionnaire)
          .tabItem { Label("Pilot", image: "Pilot") }
          .accessibilityIdentifier("pilotTab")
        QuestionnaireView()
          .environment(questionnaire)
          .tabItem { Label("Questions", systemImage: "checklist.checked") }
          .accessibilityIdentifier("questionsTab")
      }
    } detail: {
      ResultsView()
        .environment(questionnaire)
    }
  }
}

#Preview {
  ContentView()
}
