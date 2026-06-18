import Foundation

// MARK: - Domain types

struct UserCoords: Sendable, Equatable {
    let latitude: Double
    let longitude: Double
}

struct FilterState: Sendable, Equatable, Codable {
    var radiusKm: Double?
    var maxPriceCents: Int?
    var dedicatedOnly: Bool

    static let `default` = FilterState(radiusKm: nil, maxPriceCents: nil, dedicatedOnly: false)
}

/// Whether any filter is engaged (distance, max price, or dedicated-only).
/// Drives the red "active filters" dot on the Map tab's Filters pill.
/// Equivalent to `filters != .default`, expressed component-wise so the intent
/// reads directly and so it is unit-testable in isolation.
func filtersAreActive(_ filters: FilterState) -> Bool {
    filters.radiusKm != nil || filters.maxPriceCents != nil || filters.dedicatedOnly
}

// MARK: - VenueListItem immutable rebuild helper

extension VenueListItem {
    func withDistanceKm(_ km: Double?) -> VenueListItem {
        VenueListItem(
            id: id, name: name, suburb: suburb,
            lat: lat, lng: lng,
            courtCount: courtCount,
            dedicatedBadminton: dedicatedBadminton,
            distanceKm: km,
            priceFrom: priceFrom,
            hasLiveAvailability: hasLiveAvailability
        )
    }
}

// MARK: - Haversine

/// Great-circle distance in km using the Haversine formula. R = 6371 km.
func haversineKm(_ lat1: Double, _ lng1: Double, _ lat2: Double, _ lng2: Double) -> Double {
    let R = 6371.0
    let dLat = (lat2 - lat1) * .pi / 180
    let dLng = (lng2 - lng1) * .pi / 180
    let a = sin(dLat / 2) * sin(dLat / 2)
        + cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180)
        * sin(dLng / 2) * sin(dLng / 2)
    return R * 2 * atan2(sqrt(a), sqrt(1 - a))
}

// MARK: - Filter helpers

/// Enrich every venue with its distance from userCoords (or nil when no coords).
func withDistances(_ venues: [VenueListItem], _ userCoords: UserCoords?) -> [VenueListItem] {
    guard let userCoords else {
        return venues.map { $0.withDistanceKm(nil) }
    }
    return venues.map { v in
        v.withDistanceKm(haversineKm(userCoords.latitude, userCoords.longitude, v.lat, v.lng))
    }
}

/// Apply AND-logic filters then sort: by distance (ascending) when available, else alphabetically.
func applyFilters(
    _ venues: [VenueListItem],
    _ filters: FilterState,
    _ userCoords: UserCoords?
) -> [VenueListItem] {
    let enriched = withDistances(venues, userCoords)

    let filtered = enriched.filter { v in
        if filters.dedicatedOnly && !v.dedicatedBadminton { return false }

        if let limit = filters.maxPriceCents {
            // Venues with nil priceFrom are kept — user can't filter out unknown prices.
            if let price = v.priceFrom, price > limit { return false }
        }

        if let radius = filters.radiusKm, userCoords != nil {
            guard let d = v.distanceKm, d <= radius else { return false }
        }

        return true
    }

    return filtered.sorted { a, b in
        if let da = a.distanceKm, let db = b.distanceKm {
            return da < db
        }
        return a.name.localizedCompare(b.name) == .orderedAscending
    }
}

// MARK: - Sort

/// Order venues by the user-chosen ``SortOption``.
///
/// This is the authoritative sort applied after ``applyFilters`` — it is run
/// over the already-filtered (and distance-enriched) list, so `distanceKm` is
/// populated when the user's location is known.
///
/// Tie-breaks and `nil` handling are deliberate:
/// - `.nearest`: distance ascending, `nil` distances last. When **no** venue
///   has a distance (location unknown), falls back to alphabetical so the order
///   is still stable and sensible.
/// - `.priceLowToHigh`: `priceFrom` ascending, `nil` prices last.
/// - `.mostCourts`: `courtCount` descending.
/// - `.alphabetical`: `name` via `localizedCompare`.
func sortVenues(_ venues: [VenueListItem], by option: SortOption) -> [VenueListItem] {
    switch option {
    case .nearest:
        // If nothing has a distance, distance can't order anything — fall back
        // to alphabetical rather than leaving the input order untouched.
        let anyDistance = venues.contains { $0.distanceKm != nil }
        guard anyDistance else {
            return sortVenues(venues, by: .alphabetical)
        }
        return venues.sorted { a, b in
            switch (a.distanceKm, b.distanceKm) {
            case let (da?, db?): return da < db
            case (_?, nil):      return true   // a has distance, b doesn't → a first
            case (nil, _?):      return false  // b has distance, a doesn't → b first
            case (nil, nil):     return a.name.localizedCompare(b.name) == .orderedAscending
            }
        }

    case .priceLowToHigh:
        return venues.sorted { a, b in
            switch (a.priceFrom, b.priceFrom) {
            case let (pa?, pb?): return pa < pb
            case (_?, nil):      return true   // a has a price, b doesn't → a first
            case (nil, _?):      return false  // b has a price, a doesn't → b first
            case (nil, nil):     return a.name.localizedCompare(b.name) == .orderedAscending
            }
        }

    case .mostCourts:
        return venues.sorted { a, b in
            if a.courtCount != b.courtCount { return a.courtCount > b.courtCount }
            return a.name.localizedCompare(b.name) == .orderedAscending
        }

    case .alphabetical:
        return venues.sorted { a, b in
            a.name.localizedCompare(b.name) == .orderedAscending
        }
    }
}
