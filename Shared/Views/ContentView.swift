import SwiftUI

struct ContentView: View {
  @State private var questionnaire = Questionnaire()

  #if os(macOS)
    var body: some View {
      HStack {
        TabView {
          PilotProfileView()
            .environment(questionnaire)
            .tabItem { Text("Pilot") }
          QuestionnaireView()
            .environment(questionnaire)
            .tabItem { Text("Questions") }
        }.padding()
        ResultsView()
          .environment(questionnaire)
          .padding(.top, 20)
          .tabItem { Text("Results") }
      }
    }

  #else
    var body: some View {
      TabView {
        NavigationView {
          PilotProfileView()
            .environment(questionnaire)
            .navigationTitle("Pilot Profile")
        }.tabItem { Label("Pilot", image: "Pilot") }
          .navigationViewStyle(StackNavigationViewStyle())
          .accessibilityIdentifier("pilotTab")

        NavigationView {
          QuestionnaireView()
            .environment(questionnaire)
            .navigationTitle("Questionnaire")
        }.tabItem { Label("Questions", systemImage: "checklist.checked") }
          .navigationViewStyle(StackNavigationViewStyle())
          .accessibilityIdentifier("questionsTab")

        NavigationView {
          ResultsView()
            .environment(questionnaire)
            .navigationTitle("Results")
        }.tabItem { Label("Results", systemImage: "gauge.with.dots.needle.bottom.0percent") }
          .navigationViewStyle(StackNavigationViewStyle())
          .accessibilityIdentifier("resultsTab")

        NavigationView {
          AboutView().navigationTitle("About")
        }.tabItem { Label("About", systemImage: "info.circle") }
          .navigationViewStyle(StackNavigationViewStyle())
          .accessibilityIdentifier("aboutTab")
      }
    }
  #endif
}

#Preview {
  ContentView()
}
