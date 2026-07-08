#if os(macOS)
  import AppKit
  import Defaults
  import SwiftUI

  /// First-launch onboarding that invites the pilot to set up their profile before assessing
  /// a flight. Shown once, gated by ``Defaults/Keys/hasCompletedWelcome``.
  struct WelcomeView: View {
    @Default(.hasCompletedWelcome)
    private var hasCompletedWelcome

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
      VStack(spacing: 0) {
        WelcomeHeader()
        Divider()
        PilotProfileView()
          .formStyle(.grouped)
        Divider()
        WelcomeFooter(onGetStarted: finish)
      }
      .frame(width: 460, height: 560)
    }

    private func finish() {
      hasCompletedWelcome = true
      dismiss()
    }
  }

  private struct WelcomeHeader: View {
    var body: some View {
      VStack(spacing: 8) {
        Image(nsImage: NSApplication.shared.applicationIconImage)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 64, height: 64)
          .accessibilityLabel("Application icon")
        Text("Welcome to FART")
          .font(.title)
          .bold()
        Text(
          "Set up your pilot profile so your personal risk thresholds match how you fly. You can change this anytime in Settings."
        )
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
      }
      .padding()
    }
  }

  private struct WelcomeFooter: View {
    let onGetStarted: () -> Void

    var body: some View {
      HStack {
        Spacer()
        Button("Get Started", action: onGetStarted)
          .keyboardShortcut(.defaultAction)
          .controlSize(.large)
      }
      .padding()
    }
  }

  #Preview {
    WelcomeView()
  }
#endif
