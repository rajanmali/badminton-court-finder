import SwiftUI

// MARK: - AppPreferences

/// The app's persisted, observable user preferences and favourites.
///
/// Backed by `UserDefaults`. Every mutation writes through to the store
/// immediately (via `didSet`), and all values reload from the store on `init`,
/// so the in-memory object is always the single source of truth and the disk
/// copy is always current. The `UserDefaults` instance is injectable so tests
/// can run against an ephemeral, named suite instead of `.standard`.
///
/// This is plumbing for later PRs (onboarding, sort, the favourites/Saved
/// screen, and the "re-enable location" prompt). It has no UI of its own.
@Observable
@MainActor
final class AppPreferences {

    // MARK: Persisted properties

    /// Whether the user has completed the first-run onboarding flow.
    var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Key.hasSeenOnboarding) }
    }

    /// The filters applied when the venue list first opens. Persisted as JSON.
    var defaultFilters: FilterState {
        didSet { persistDefaultFilters() }
    }

    /// The default ordering for the venue list. Persisted as its `rawValue`.
    var defaultSort: SortOption {
        didSet { defaults.set(defaultSort.rawValue, forKey: Key.defaultSort) }
    }

    /// Whether the user dismissed the "re-enable location" prompt, so we don't
    /// nag them again after they've denied permission deliberately.
    var locationPromptDismissed: Bool {
        didSet { defaults.set(locationPromptDismissed, forKey: Key.locationPromptDismissed) }
    }

    /// The set of favourited venue IDs. Mutated only through ``toggleFavourite(_:)``
    /// so persistence stays in one place; exposed read-only for the Saved screen.
    private(set) var favouriteIDs: Set<String> {
        didSet { persistFavourites() }
    }

    // MARK: Dependencies

    private let defaults: UserDefaults

    // MARK: Init

    /// Loads all preferences from `defaults`, falling back to defaults for any
    /// key that is absent or unreadable.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        self.hasSeenOnboarding = defaults.bool(forKey: Key.hasSeenOnboarding)
        self.locationPromptDismissed = defaults.bool(forKey: Key.locationPromptDismissed)

        self.defaultSort = defaults.string(forKey: Key.defaultSort)
            .flatMap(SortOption.init(rawValue:)) ?? .nearest

        self.defaultFilters = defaults.data(forKey: Key.defaultFilters)
            .flatMap { try? JSONDecoder().decode(FilterState.self, from: $0) } ?? .default

        let storedFavourites = defaults.array(forKey: Key.favouriteIDs) as? [String] ?? []
        self.favouriteIDs = Set(storedFavourites)
    }

    // MARK: Favourites

    /// Whether `id` is currently favourited.
    func isFavourite(_ id: String) -> Bool {
        favouriteIDs.contains(id)
    }

    /// Adds `id` to favourites if absent, otherwise removes it. Persists immediately.
    func toggleFavourite(_ id: String) {
        if favouriteIDs.contains(id) {
            favouriteIDs.remove(id)
        } else {
            favouriteIDs.insert(id)
        }
    }

    // MARK: Persistence helpers

    private func persistDefaultFilters() {
        guard let data = try? JSONEncoder().encode(defaultFilters) else { return }
        defaults.set(data, forKey: Key.defaultFilters)
    }

    private func persistFavourites() {
        // Stored as an array; Set is not a property-list type.
        defaults.set(Array(favouriteIDs), forKey: Key.favouriteIDs)
    }

    // MARK: Storage keys

    /// Namespaced `UserDefaults` keys. Keep these stable — they are the on-disk contract.
    private enum Key {
        static let hasSeenOnboarding = "smash.hasSeenOnboarding"
        static let defaultFilters = "smash.defaultFilters"
        static let defaultSort = "smash.defaultSort"
        static let locationPromptDismissed = "smash.locationPromptDismissed"
        static let favouriteIDs = "smash.favouriteIDs"
    }

    // MARK: Shared instance

    /// The app-wide preferences store. Tests construct their own instance with
    /// an ephemeral suite instead of using this.
    static let shared = AppPreferences()
}

// MARK: - Environment plumbing

extension EnvironmentValues {
    /// The app-wide preferences store. Defaults to ``AppPreferences/shared``.
    ///
    /// This lives outside the `Sendable` ``AppEnvironment`` struct on purpose:
    /// `AppPreferences` is a mutable `@Observable` class, so views read it via
    /// `@Environment(\.preferences)` and observe its changes directly, while
    /// `AppEnvironment` stays a stateless container of services.
    @Entry var preferences: AppPreferences = .shared
}
