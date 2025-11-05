import Foundation
import SwiftData

@Model
final class PilotProfile {
  // MARK: - Properties

  /// Pilot certification level
  var rating: Rating

  /// Flight hours category
  var hours: Hours

  /// Threshold for considering a runway "short" (in feet)
  var shortRunway: Int

  /// Wind speed threshold for "strong winds" (in knots)
  var strongWinds: Int

  /// Crosswind speed threshold (in knots)
  var strongCrosswinds: Int

  /// IFR ceiling threshold for "low ceiling" (in feet)
  var lowCeiling: Ceiling

  /// IFR visibility threshold for "low visibility" (in statute miles)
  var lowVisibility: Visibility

  /// Profile name (for future multiple profiles support)
  var name: String

  /// Whether this is the active profile
  var isActive: Bool

  /// Creation timestamp
  var createdAt: Date

  /// Last modified timestamp
  var updatedAt: Date

  // MARK: - Initialization

  init(
    rating: Rating = .VFR,
    hours: Hours = .under100,
    shortRunway: Int = 3000,
    strongWinds: Int = 15,
    strongCrosswinds: Int = 7,
    lowCeiling: Ceiling = .oneThousandFeet,
    lowVisibility: Visibility = .threeSM,
    name: String = "Default Profile",
    isActive: Bool = true
  ) {
    self.rating = rating
    self.hours = hours
    self.shortRunway = shortRunway
    self.strongWinds = strongWinds
    self.strongCrosswinds = strongCrosswinds
    self.lowCeiling = lowCeiling
    self.lowVisibility = lowVisibility
    self.name = name
    self.isActive = isActive
    self.createdAt = Date()
    self.updatedAt = Date()
  }

  // MARK: - Helper Methods

  /// Updates the timestamp when profile is modified
  func markAsUpdated() {
    updatedAt = Date()
  }
}
