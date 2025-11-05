import Defaults
import Foundation
import SwiftData

/// Handles migration of pilot profile data from UserDefaults to SwiftData
@MainActor
class PilotProfileMigration {
  private let modelContext: ModelContext
  private static let migrationCompletedKey = "pilotProfileMigrationCompleted"

  init(modelContext: ModelContext) {
    self.modelContext = modelContext
  }

  /// Checks if migration has already been completed
  var isMigrationCompleted: Bool {
    UserDefaults.standard.bool(forKey: Self.migrationCompletedKey)
  }

  /// Performs migration from UserDefaults to SwiftData if needed
  func migrateIfNeeded() {
    guard !isMigrationCompleted else {
      print("Migration already completed, skipping...")
      return
    }

    print("Starting pilot profile migration from UserDefaults to SwiftData...")

    // Check if there's already a profile in SwiftData
    let descriptor = FetchDescriptor<PilotProfile>()
    let existingProfiles = (try? modelContext.fetch(descriptor)) ?? []

    if !existingProfiles.isEmpty {
      print("Found existing profiles in SwiftData, skipping migration")
      markMigrationCompleted()
      return
    }

    // Create new profile from UserDefaults
    let profile = PilotProfile(
      rating: Defaults[.rating],
      hours: Defaults[.hours],
      shortRunway: Defaults[.shortRunway],
      strongWinds: Defaults[.strongWinds],
      strongCrosswinds: Defaults[.strongCrosswinds],
      lowCeiling: Defaults[.lowCeiling],
      lowVisibility: Defaults[.lowVisibility],
      name: "Default Profile",
      isActive: true
    )

    modelContext.insert(profile)

    do {
      try modelContext.save()
      print("Successfully migrated pilot profile to SwiftData")
      markMigrationCompleted()
    } catch {
      print("Failed to save migrated profile: \(error)")
    }
  }

  /// Marks migration as completed
  private func markMigrationCompleted() {
    UserDefaults.standard.set(true, forKey: Self.migrationCompletedKey)
  }

  /// Resets migration flag (for testing purposes)
  static func resetMigration() {
    UserDefaults.standard.removeObject(forKey: migrationCompletedKey)
  }
}
