import Foundation

// MARK: - Onboarding pure logic

/// The default ``SortOption`` to preselect on the onboarding sort step, given
/// whether the user ended up with a usable location.
///
/// Sorting by **nearest** only makes sense when we actually have coordinates, so
/// without a location we fall back to **price (low→high)** — a sensible,
/// location-independent default. Kept as a free function so it is trivially
/// unit-testable in isolation, with no view or model dependencies.
///
/// - Parameter forLocationAvailable: `true` when the location request resolved
///   to ``LocationOutcome/located(_:)``; `false` for denied, unavailable, or
///   skipped.
/// - Returns: `.nearest` when location is available, otherwise `.priceLowToHigh`.
func defaultSort(forLocationAvailable locationAvailable: Bool) -> SortOption {
    locationAvailable ? .nearest : .priceLowToHigh
}
