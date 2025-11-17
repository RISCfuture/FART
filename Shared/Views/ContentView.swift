import SwiftUI

#if os(macOS)
  enum ViewMode: String, CaseIterable, Identifiable {
    case profile = "Pilot Profile"
    case questionnaire = "Questionnaire"
    case results = "Results"
    case about = "About"

    var id: String { rawValue }

    var systemImage: String {
      switch self {
        case .profile: "person.fill"
        case .questionnaire: "checklist.checked"
        case .results: "gauge.with.dots.needle.bottom.0percent"
        case .about: "info.circle"
      }
    }

    var keyboardShortcut: KeyEquivalent {
      switch self {
        case .profile: "1"
        case .questionnaire: "2"
        case .results: "3"
        case .about: "4"
      }
    }
  }
#endif

struct ContentView: View {
  #if os(macOS)
    @State private var currentView: ViewMode = .questionnaire
  #endif

  @State private var questionnaire = Questionnaire()

  var body: some View {
    #if os(macOS)
      macOSLayout
    #else
      iOSLayout
    #endif
  }

  #if os(macOS)
    private var macOSLayout: some View {
      Group {
        switch currentView {
          case .profile:
            ScrollView {
              PilotProfileView()
                .environment(questionnaire)
                .formStyle(.grouped)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
                .padding()
            }
          case .questionnaire:
            ScrollView {
              QuestionnaireView()
                .environment(questionnaire)
                .formStyle(.grouped)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
                .padding()
            }
          case .results:
            ResultsView()
              .environment(questionnaire)
          case .about:
            AboutView()
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Picker("View", selection: $currentView) {
            ForEach(ViewMode.allCases) { mode in
              Label(mode.rawValue, systemImage: mode.systemImage)
                .tag(mode)
            }
          }
          .pickerStyle(.segmented)
          .fixedSize()
        }
      }
      .navigationTitle(currentView.rawValue)
      .keyboardShortcut(for: .profile, selection: $currentView)
      .keyboardShortcut(for: .questionnaire, selection: $currentView)
      .keyboardShortcut(for: .results, selection: $currentView)
      .keyboardShortcut(for: .about, selection: $currentView)
    }
  #endif

  #if !os(macOS)
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass

    @ViewBuilder private var iOSLayout: some View {
      if horizontalSizeClass == .regular {
        twoColumnLayout
      } else {
        oneColumnLayout
      }
    }

    private var oneColumnLayout: some View {
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
  #endif
}

#if os(macOS)
  extension View {
    func keyboardShortcut(
      for mode: ViewMode,
      selection: Binding<ViewMode>
    ) -> some View {
      self.background(
        Button("") {
          selection.wrappedValue = mode
        }
        .keyboardShortcut(mode.keyboardShortcut, modifiers: .command)
        .hidden()
      )
    }
  }
#endif

#Preview {
  ContentView()
}
