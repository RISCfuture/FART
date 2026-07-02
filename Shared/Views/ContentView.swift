import SwiftUI

#if os(macOS)
  enum InputTab: String, CaseIterable, Identifiable {
    case profile = "Pilot Profile"
    case questionnaire = "Questionnaire"

    var id: String { rawValue }

    var systemImage: String {
      switch self {
        case .profile: "person.fill"
        case .questionnaire: "checklist.checked"
      }
    }

    var keyboardShortcut: KeyEquivalent {
      switch self {
        case .profile: "1"
        case .questionnaire: "2"
      }
    }
  }
#endif

struct ContentView: View {
  #if os(macOS)
    @State private var selectedInput: InputTab = .questionnaire
  #endif

  @State private var questionnaire = Questionnaire()

  #if !os(macOS)
    @State private var showingAbout = false
  #endif

  var body: some View {
    #if os(macOS)
      macOSLayout
    #else
      iOSLayout
    #endif
  }

  #if os(macOS)
    private var macOSLayout: some View {
      NavigationSplitView {
        TabView(selection: $selectedInput) {
          ScrollView {
            PilotProfileView()
              .environment(questionnaire)
              .formStyle(.grouped)
              .padding()
          }
          .tabItem { Label(InputTab.profile.rawValue, systemImage: InputTab.profile.systemImage) }
          .tag(InputTab.profile)
          .accessibilityIdentifier("pilotTab")

          ScrollView {
            QuestionnaireView()
              .environment(questionnaire)
              .formStyle(.grouped)
              .padding()
          }
          .tabItem {
            Label(InputTab.questionnaire.rawValue, systemImage: InputTab.questionnaire.systemImage)
          }
          .tag(InputTab.questionnaire)
          .accessibilityIdentifier("questionsTab")
        }
        .navigationSplitViewColumnWidth(min: 320, ideal: 380)
        .keyboardShortcut(for: .profile, selection: $selectedInput)
        .keyboardShortcut(for: .questionnaire, selection: $selectedInput)
      } detail: {
        ResultsView()
          .environment(questionnaire)
          .navigationTitle("Results")
      }
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
        NavigationStack {
          ResultsView()
            .environment(questionnaire)
            .toolbar {
              ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                  showingAbout = true
                } label: {
                  Label("About", systemImage: "info.circle")
                }
                .accessibilityIdentifier("aboutButton")
              }
            }
        }
        .sheet(isPresented: $showingAbout) {
          AboutSheet(isPresented: $showingAbout)
        }
      }
    }
  #endif
}

#if !os(macOS)
  private struct AboutSheet: View {
    @Binding var isPresented: Bool

    var body: some View {
      NavigationStack {
        AboutView()
          .navigationTitle("About")
          .toolbar {
            ToolbarItem(placement: .confirmationAction) {
              Button("Done") { isPresented = false }
            }
          }
      }
    }
  }
#endif

#if os(macOS)
  extension View {
    func keyboardShortcut(
      for tab: InputTab,
      selection: Binding<InputTab>
    ) -> some View {
      self.background(
        Button("") {
          selection.wrappedValue = tab
        }
        .keyboardShortcut(tab.keyboardShortcut, modifiers: .command)
        .hidden()
      )
    }
  }
#endif

#Preview {
  ContentView()
}
