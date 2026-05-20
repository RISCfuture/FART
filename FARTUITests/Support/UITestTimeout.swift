import Foundation
import XCTest

/// Centralized timeouts for UI tests. Multiplier is set via the
/// `FART_UI_TIMEOUT_MULTIPLIER` environment variable (see `UI Tests.xctestplan`),
/// so CI machines can run with longer waits without touching test code.
@MainActor
enum UITestTimeout {
  static let multiplier: Double = {
    if let raw = ProcessInfo.processInfo.environment["FART_UI_TIMEOUT_MULTIPLIER"],
      let value = Double(raw), value > 0
    {
      return value
    }
    return 1.0
  }()

  /// Default wait for an element to appear (CI-scaled).
  static var element: TimeInterval { scaled(10) }

  /// Short interaction wait — picker menus opening, transient overlays (CI-scaled).
  static var short: TimeInterval { scaled(3) }

  /// Long wait — app launch, cross-screen navigation (CI-scaled).
  static var long: TimeInterval { scaled(30) }

  static func scaled(_ base: TimeInterval) -> TimeInterval { base * multiplier }
}
