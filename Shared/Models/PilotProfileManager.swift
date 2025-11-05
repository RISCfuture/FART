import Foundation
import SwiftData

/// Manages pilot profile operations and provides easy access to the active profile
@MainActor
@Observable
class PilotProfileManager {
  private let modelContext: ModelContext

  /// The currently active pilot profile
  var activeProfile: PilotProfile?

  init(modelContext: ModelContext) {
    self.modelContext = modelContext
  }

  /// Loads the active profile from SwiftData
  func loadActiveProfile() {
    let descriptor = FetchDescriptor<PilotProfile>(
      predicate: #Predicate { $0.isActive == true },
      sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
    )

    do {
      let profiles = try modelContext.fetch(descriptor)
      activeProfile = profiles.first

      // If no active profile exists, create a default one
      if activeProfile == nil {
        createDefaultProfile()
      }
    } catch {
      print("Failed to load active profile: \(error)")
    }
  }

  /// Creates a default pilot profile
  func createDefaultProfile() {
    let profile = PilotProfile()
    modelContext.insert(profile)

    do {
      try modelContext.save()
      activeProfile = profile
      print("Created default pilot profile")
    } catch {
      print("Failed to create default profile: \(error)")
    }
  }

  /// Saves changes to the current profile
  func saveProfile() {
    activeProfile?.markAsUpdated()

    do {
      try modelContext.save()
      print("Profile saved successfully")
    } catch {
      print("Failed to save profile: \(error)")
    }
  }
}
