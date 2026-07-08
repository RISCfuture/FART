import SwiftUI

#if os(macOS)
  import Defaults

  /// Stable identifiers for the app's macOS scenes, used with `openWindow(id:)`.
  enum FARTWindowID {
    static let main = "main"
    static let about = "about"
    static let welcome = "welcome"
  }

  extension FocusedValues {
    /// The questionnaire belonging to the key window, so menu commands (Reset, Print,
    /// Export) act on the assessment the pilot is currently looking at.
    @Entry var questionnaire: Questionnaire?
  }
#endif

struct ContentView: View {
  #if os(macOS)
    @Environment(\.openWindow)
    private var openWindow

    @Default(.hasCompletedWelcome)
    private var hasCompletedWelcome
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
        InputColumn(questionnaire: questionnaire) { QuestionnaireView() }
          .navigationSplitViewColumnWidth(min: 320, ideal: 380)
          .navigationTitle("Questionnaire")
      } detail: {
        ResultsView()
          .environment(questionnaire)
          .navigationTitle("Results")
      }
      .focusedSceneValue(\.questionnaire, questionnaire)
      .task {
        if !hasCompletedWelcome { openWindow(id: FARTWindowID.welcome) }
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
        Tab("Pilot", image: "Pilot") {
          NavigationStack {
            PilotProfileView()
              .environment(questionnaire)
              .navigationTitle("Pilot Profile")
          }
        }

        Tab("Questions", systemImage: "checklist.checked") {
          NavigationStack {
            QuestionnaireView()
              .environment(questionnaire)
              .navigationTitle("Questionnaire")
          }
        }

        Tab("Results", systemImage: "gauge.with.dots.needle.bottom.0percent") {
          NavigationStack {
            ResultsView()
              .environment(questionnaire)
              .navigationTitle("Results")
          }
        }

        Tab("About", systemImage: "info.circle") {
          NavigationStack {
            AboutView().navigationTitle("About")
          }
        }
      }
      .tabBarMinimizeBehavior(.onScrollDown)
      .tabViewBottomAccessory {
        RiskScoreBadge()
          .environment(questionnaire)
      }
    }

    private var twoColumnLayout: some View {
      NavigationSplitView(preferredCompactColumn: .constant(.detail)) {
        TabView {
          Tab("Pilot", image: "Pilot") {
            PilotProfileView().environment(questionnaire)
          }
          Tab("Questions", systemImage: "checklist.checked") {
            QuestionnaireView().environment(questionnaire)
          }
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
            .presentationSizing(.form)
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
  /// A scrolling input form column for the master/detail sidebar, with a soft scroll-edge
  /// glass effect at the top so content fades under the toolbar rather than clipping hard.
  private struct InputColumn<Content: View>: View {
    let questionnaire: Questionnaire
    @ViewBuilder let content: () -> Content

    var body: some View {
      ScrollView {
        content()
          .environment(questionnaire)
          .formStyle(.grouped)
          .scrollContentBackground(.hidden)
          .padding()
      }
      .scrollEdgeEffectStyle(.soft, for: .top)
    }
  }
#endif

#if !os(macOS)
  /// A compact, live readout of the current FART score and risk level, shown in the tab
  /// bar's bottom accessory so the score stays visible across the Pilot and Questions tabs.
  private struct RiskScoreBadge: View {
    @Environment(Questionnaire.self)
    private var questionnaire

    // Text's `+` concatenation is deprecated in iOS 26, so the colored, heavy, rounded score
    // run is composed as an AttributedString instead.
    private var summary: AttributedString {
      var score = AttributedString(questionnaire.score.formatted(.number))
      score.foregroundColor = questionnaire.risk.color
      score.font = .system(.subheadline, design: .rounded, weight: .heavy)

      let remainder = AttributedString(localized: " pts., \(questionnaire.risk.inlineLabel)")

      return score + remainder
    }

    var body: some View {
      Text(summary)
        .font(.subheadline)
        .contentTransition(.numericText())
        .padding(.horizontal)
        .animation(.default, value: questionnaire.score)
        .animation(.default, value: questionnaire.risk)
        .accessibilityIdentifier("scoreBadge")
    }
  }
#endif

#Preview {
  ContentView()
}
