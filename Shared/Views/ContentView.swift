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
    @State private var selectedTab = AppTab.pilot
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
      TabView(selection: $selectedTab) {
        Tab("Pilot", image: "Pilot", value: AppTab.pilot) {
          NavigationStack {
            PilotProfileView()
              .environment(questionnaire)
              .navigationTitle("Pilot Profile")
          }
        }

        Tab("Questions", systemImage: "checklist.checked", value: AppTab.questions) {
          NavigationStack {
            QuestionnaireView()
              .environment(questionnaire)
              .navigationTitle("Questionnaire")
          }
        }

        Tab("Results", systemImage: "gauge.with.dots.needle.bottom.0percent", value: AppTab.results)
        {
          NavigationStack {
            ResultsView()
              .environment(questionnaire)
              .navigationTitle("Results")
          }
        }

        Tab("About", systemImage: "info.circle", value: AppTab.about) {
          NavigationStack {
            AboutView().navigationTitle("About")
          }
        }
      }
      // Drop the accessory entirely on Results, where the gauge already shows the score and
      // risk; an empty accessory would still leave a stray capsule behind.
      .iPhoneTabBarChrome(questionnaire, hideScoreBadge: selectedTab == .results)
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
  /// The selectable tabs in the single-column iPhone layout.
  private enum AppTab {
    case pilot, questions, results, about
  }

  private extension View {
    /// Applies the iPhone tab bar's chrome: auto-minimizing on scroll and the score-badge
    /// bottom accessory (hidden when `hideScoreBadge`). Both APIs exist only on iOS, so on
    /// visionOS the tab bar is shown without them.
    @ViewBuilder
    func iPhoneTabBarChrome(_ questionnaire: Questionnaire, hideScoreBadge: Bool) -> some View {
      #if os(iOS)
        tabBarMinimizeBehavior(.onScrollDown)
          .scoreBadgeAccessory(questionnaire, hidden: hideScoreBadge)
      #else
        self
      #endif
    }

    #if os(iOS)
      /// Attaches the risk-score badge as the tab bar's bottom accessory, hiding it when
      /// `hidden`. The modifier stays applied either way so the `TabView` keeps its identity —
      /// conditionally applying it would rebuild the tab bar and snap the selection highlight
      /// back to the first tab on every crossing.
      @ViewBuilder
      func scoreBadgeAccessory(_ questionnaire: Questionnaire, hidden: Bool) -> some View {
        if #available(iOS 26.1, *) {
          // `isEnabled:` collapses the accessory cleanly, leaving no vacant capsule.
          tabViewBottomAccessory(isEnabled: !hidden) {
            RiskScoreBadge()
              .environment(questionnaire)
          }
        } else {
          // Pre-26.1 has no `isEnabled:`, and emptying the content leaves a stray capsule, so
          // just keep the badge visible on every tab.
          tabViewBottomAccessory {
            RiskScoreBadge()
              .environment(questionnaire)
          }
        }
      }
    #endif
  }

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

#if os(iOS)
  /// A compact, live readout of the current FART score and risk level, shown in the tab
  /// bar's bottom accessory so the score stays visible across the Pilot and Questions tabs.
  private struct RiskScoreBadge: View {
    @Environment(Questionnaire.self)
    private var questionnaire

    // The score keeps its own colored, heavy, rounded styling by interpolating a pre-styled
    // AttributedString run into the localized phrase, so translators control the word order
    // (and right-to-left layout) around both the score and the risk descriptor.
    private var summary: AttributedString {
      var score = AttributedString(questionnaire.score.formatted(.number))
      score.foregroundColor = questionnaire.risk.color
      score.font = .system(.subheadline, design: .rounded, weight: .heavy)

      return AttributedString(localized: "\(score) pts., \(questionnaire.risk.inlineLabel)")
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
