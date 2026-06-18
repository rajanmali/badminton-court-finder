import Foundation
import Testing
@testable import Smash

// MARK: - AppPreferences tests

/// Each test runs against its own ephemeral `UserDefaults` suite so they stay
/// isolated from `.standard` and from each other.
@MainActor
struct AppPreferencesTests {

    /// A unique suite name + a fresh, empty `UserDefaults` for a single test.
    private func makeSuite() -> (name: String, defaults: UserDefaults) {
        let name = "test-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return (name, defaults)
    }

    // MARK: Defaults

    @Test func startsWithDefaults() {
        let (name, defaults) = makeSuite()
        defer { defaults.removePersistentDomain(forName: name) }

        let prefs = AppPreferences(defaults: defaults)

        #expect(prefs.hasSeenOnboarding == false)
        #expect(prefs.defaultSort == .nearest)
        #expect(prefs.defaultFilters == .default)
        #expect(prefs.locationPromptDismissed == false)
        #expect(prefs.favouriteIDs.isEmpty)
    }

    // MARK: Round-trip persistence

    @Test func persistsAndReloadsAcrossInstances() {
        let (name, defaults) = makeSuite()
        defer { defaults.removePersistentDomain(forName: name) }

        let custom = FilterState(radiusKm: 10, maxPriceCents: 3000, dedicatedOnly: true)

        // First instance: mutate everything.
        let first = AppPreferences(defaults: defaults)
        first.hasSeenOnboarding = true
        first.defaultSort = .priceLowToHigh
        first.defaultFilters = custom
        first.locationPromptDismissed = true
        first.toggleFavourite("venue-1")

        // Second instance over the SAME suite: values must have persisted.
        let second = AppPreferences(defaults: defaults)
        #expect(second.hasSeenOnboarding == true)
        #expect(second.defaultSort == .priceLowToHigh)
        #expect(second.defaultFilters == custom)
        #expect(second.locationPromptDismissed == true)
        #expect(second.favouriteIDs == ["venue-1"])
        #expect(second.isFavourite("venue-1"))
    }

    // MARK: Favourites

    @Test func toggleFavouriteAddsThenRemoves() {
        let (name, defaults) = makeSuite()
        defer { defaults.removePersistentDomain(forName: name) }

        let prefs = AppPreferences(defaults: defaults)
        #expect(prefs.isFavourite("v1") == false)

        prefs.toggleFavourite("v1")
        #expect(prefs.isFavourite("v1") == true)
        #expect(prefs.favouriteIDs.contains("v1"))

        prefs.toggleFavourite("v1")
        #expect(prefs.isFavourite("v1") == false)
        #expect(prefs.favouriteIDs.isEmpty)
    }

    @Test func favouritesPersistRemovalAcrossInstances() {
        let (name, defaults) = makeSuite()
        defer { defaults.removePersistentDomain(forName: name) }

        let first = AppPreferences(defaults: defaults)
        first.toggleFavourite("a")
        first.toggleFavourite("b")
        first.toggleFavourite("a") // remove "a"

        let second = AppPreferences(defaults: defaults)
        #expect(second.favouriteIDs == ["b"])
    }

    // MARK: SortOption

    @Test func sortOptionHasFourCasesWithLabels() {
        #expect(SortOption.allCases.count == 4)
        for option in SortOption.allCases {
            #expect(!option.label.isEmpty)
            #expect(!option.systemImage.isEmpty)
        }
    }
}
