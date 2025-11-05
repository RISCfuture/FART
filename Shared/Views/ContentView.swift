import SwiftData
import SwiftUI

struct ContentView: View {
  @State private var questionnaire = Questionnaire()
  @State private var profileManager: PilotProfileManager?

  @Environment(\.horizontalSizeClass)
  var horizontalSizeClass

  @Environment(\.modelContext) private var modelContext

  var body: some View {
    Group {
      switch horizontalSizeClass {
        case .regular: twoColumnLayout
        default: oneColumnLayout
      }
    }
    .task {
      await initializeData()
    }
  }

  /// Initializes SwiftData migration and profile manager
  private func initializeData() async {
    // Perform migration from UserDefaults
    let migration = PilotProfileMigration(modelContext: modelContext)
    migration.migrateIfNeeded()

    // Initialize profile manager
    let manager = PilotProfileManager(modelContext: modelContext)
    manager.loadActiveProfile()
    profileManager = manager

    // Pass the profile to the questionnaire
    if let profile = manager.activeProfile {
      questionnaire.setProfile(profile)
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
