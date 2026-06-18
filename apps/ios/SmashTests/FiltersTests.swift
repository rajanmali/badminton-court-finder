import Testing
@testable import Smash

// MARK: - Fixture data
// Mirrors filters.test.ts fixtures exactly.

private let SYDNEY_CBD = UserCoords(latitude: -33.8688, longitude: 151.2093)
private let PARRAMATTA = UserCoords(latitude: -33.8150, longitude: 151.0011)

private func makeVenue(
    id: String = "v1",
    name: String = "Test Venue",
    suburb: String = "Test",
    lat: Double = -33.8688,
    lng: Double = 151.2093,
    courtCount: Int = 4,
    dedicatedBadminton: Bool = false,
    distanceKm: Double? = nil,
    priceFrom: Int? = 3000,
    hasLiveAvailability: Bool = false
) -> VenueListItem {
    VenueListItem(
        id: id, name: name, suburb: suburb,
        lat: lat, lng: lng,
        courtCount: courtCount,
        dedicatedBadminton: dedicatedBadminton,
        distanceKm: distanceKm,
        priceFrom: priceFrom,
        hasLiveAvailability: hasLiveAvailability
    )
}

private let NEAR = makeVenue(id: "near", name: "Near", lat: -33.8700, lng: 151.2100, priceFrom: 2900)
private let FAR  = makeVenue(id: "far",  name: "Far",  lat: -33.8150, lng: 151.0011, priceFrom: 3000)
private let DEDICATED = makeVenue(
    id: "ded", name: "Dedicated",
    lat: -33.86, lng: 151.20,
    dedicatedBadminton: true, priceFrom: 3500
)
private let NO_RATES = makeVenue(
    id: "norates", name: "No Rates",
    lat: -33.86, lng: 151.21,
    priceFrom: nil
)

private let ALL = [NEAR, FAR, DEDICATED, NO_RATES]

// MARK: - haversineKm tests

struct HaversineTests {
    @Test func samePointIsZero() {
        let d = haversineKm(-33.8688, 151.2093, -33.8688, 151.2093)
        #expect(abs(d) < 0.001)
    }

    @Test func cbdToParramattaIsAbout23km() {
        let d = haversineKm(SYDNEY_CBD.latitude, SYDNEY_CBD.longitude,
                            PARRAMATTA.latitude, PARRAMATTA.longitude)
        #expect(d > 20)
        #expect(d < 26)
    }

    @Test func isSymmetric() {
        let ab = haversineKm(-33.8688, 151.2093, -33.8150, 151.0011)
        let ba = haversineKm(-33.8150, 151.0011, -33.8688, 151.2093)
        #expect(abs(ab - ba) < 0.00001)
    }
}

// MARK: - withDistances tests

struct WithDistancesTests {
    @Test func setsDistanceKmWhenCoordsProvided() {
        let result = withDistances([NEAR], SYDNEY_CBD)
        #expect(result[0].distanceKm != nil)
        #expect(result[0].distanceKm! < 1)
    }

    @Test func setsDistanceKmToNilWhenNoCoordsProvided() {
        let result = withDistances([NEAR], nil)
        #expect(result[0].distanceKm == nil)
    }
}

// MARK: - applyFilters — no filters

struct ApplyFiltersNoFiltersTests {
    @Test func returnsAllVenuesSortedAlphabeticallyWhenNoLocation() {
        let result = applyFilters(ALL, FilterState.default, nil)
        #expect(result.map(\.id) == ["ded", "far", "near", "norates"])
    }

    @Test func sortsByDistanceWhenLocationAvailable() {
        let result = applyFilters([NEAR, FAR], FilterState.default, SYDNEY_CBD)
        #expect(result[0].id == "near")
        #expect(result[1].id == "far")
    }
}

// MARK: - applyFilters — dedicated toggle

struct ApplyFiltersDedicatedTests {
    @Test func filtersToDedicatedOnly() {
        let filters = FilterState(radiusKm: nil, maxPriceCents: nil, dedicatedOnly: true)
        let result = applyFilters(ALL, filters, nil)
        let allDedicated = result.allSatisfy { $0.dedicatedBadminton }
        #expect(allDedicated)
        #expect(result.count == 1)
        #expect(result[0].id == "ded")
    }
}

// MARK: - applyFilters — max price

struct ApplyFiltersMaxPriceTests {
    @Test func excludesVenuesAbovePriceLimit() {
        let filters = FilterState(radiusKm: nil, maxPriceCents: 3000, dedicatedOnly: false)
        let result = applyFilters(ALL, filters, nil)
        let ids = result.map(\.id)
        #expect(ids.contains("near"))    // 2900 ≤ 3000 ✓
        #expect(ids.contains("far"))     // 3000 ≤ 3000 ✓
        #expect(!ids.contains("ded"))    // 3500 > 3000 ✗
    }

    @Test func keepsVenuesWithNoRates() {
        let filters = FilterState(radiusKm: nil, maxPriceCents: 2000, dedicatedOnly: false)
        let result = applyFilters(ALL, filters, nil)
        #expect(result.map(\.id).contains("norates"))
    }
}

// MARK: - applyFilters — distance radius

struct ApplyFiltersRadiusTests {
    @Test func excludesVenuesOutsideRadius() {
        let filters = FilterState(radiusKm: 5, maxPriceCents: nil, dedicatedOnly: false)
        let result = applyFilters([NEAR, FAR], filters, SYDNEY_CBD)
        let ids = result.map(\.id)
        #expect(ids.contains("near"))
        #expect(!ids.contains("far"))
    }

    @Test func ignoresRadiusFilterWhenNoCoordsProvided() {
        let filters = FilterState(radiusKm: 5, maxPriceCents: nil, dedicatedOnly: false)
        let result = applyFilters([NEAR, FAR], filters, nil)
        #expect(result.count == 2)
    }
}

// MARK: - applyFilters — combined

struct ApplyFiltersCombinedTests {
    @Test func appliesAllThreeFiltersWithAndLogic() {
        let filters = FilterState(radiusKm: 5, maxPriceCents: 3000, dedicatedOnly: false)
        let result = applyFilters(ALL, filters, SYDNEY_CBD)
        let ids = result.map(\.id)
        #expect(ids.contains("near"))
        #expect(ids.contains("norates"))
        #expect(!ids.contains("far"))
        #expect(!ids.contains("ded"))
    }
}

// MARK: - sortVenues

struct SortVenuesTests {
    // Fixtures with explicit distance / price / court / name spreads so each
    // sort key produces a distinct, checkable order.
    private let a = makeVenue(id: "a", name: "Alpha",   courtCount: 6, distanceKm: 8.0,  priceFrom: 3500)
    private let b = makeVenue(id: "b", name: "Bravo",   courtCount: 12, distanceKm: 2.0, priceFrom: 4000)
    private let c = makeVenue(id: "c", name: "Charlie", courtCount: 4, distanceKm: 5.0,  priceFrom: 2900)

    private var sample: [VenueListItem] { [a, b, c] }

    // .nearest — distance ascending
    @Test func nearestOrdersByDistanceAscending() {
        let result = sortVenues(sample, by: .nearest)
        #expect(result.map(\.id) == ["b", "c", "a"])  // 2.0, 5.0, 8.0
    }

    @Test func nearestPutsNilDistancesLast() {
        let noDist = makeVenue(id: "z", name: "Zulu", distanceKm: nil)
        let result = sortVenues([a, noDist, b], by: .nearest)
        #expect(result.map(\.id) == ["b", "a", "z"])  // 2.0, 8.0, then nil
        #expect(result.last?.id == "z")
    }

    @Test func nearestFallsBackToAlphabeticalWhenNoVenueHasDistance() {
        let v1 = makeVenue(id: "v1", name: "Charlie", distanceKm: nil)
        let v2 = makeVenue(id: "v2", name: "Alpha",   distanceKm: nil)
        let v3 = makeVenue(id: "v3", name: "Bravo",   distanceKm: nil)
        let result = sortVenues([v1, v2, v3], by: .nearest)
        #expect(result.map(\.name) == ["Alpha", "Bravo", "Charlie"])
    }

    // .priceLowToHigh
    @Test func priceOrdersAscending() {
        let result = sortVenues(sample, by: .priceLowToHigh)
        #expect(result.map(\.id) == ["c", "a", "b"])  // 2900, 3500, 4000
    }

    @Test func pricePutsNilPricesLast() {
        let noPrice = makeVenue(id: "np", name: "No Price", priceFrom: nil)
        let result = sortVenues([a, noPrice, c], by: .priceLowToHigh)
        #expect(result.map(\.id) == ["c", "a", "np"])  // 2900, 3500, then nil
        #expect(result.last?.id == "np")
    }

    // .mostCourts
    @Test func mostCourtsOrdersDescending() {
        let result = sortVenues(sample, by: .mostCourts)
        #expect(result.map(\.id) == ["b", "a", "c"])  // 12, 6, 4
    }

    // .alphabetical
    @Test func alphabeticalOrdersByName() {
        let result = sortVenues(sample, by: .alphabetical)
        #expect(result.map(\.name) == ["Alpha", "Bravo", "Charlie"])
    }

    @Test func emptyInputReturnsEmpty() {
        #expect(sortVenues([], by: .nearest).isEmpty)
        #expect(sortVenues([], by: .priceLowToHigh).isEmpty)
        #expect(sortVenues([], by: .mostCourts).isEmpty)
        #expect(sortVenues([], by: .alphabetical).isEmpty)
    }
}

// MARK: - filtersAreActive (Map "active filters" red dot)

struct FiltersAreActiveTests {
    @Test func defaultIsInactive() {
        #expect(filtersAreActive(.default) == false)
    }

    @Test func radiusMakesActive() {
        #expect(filtersAreActive(FilterState(radiusKm: 5, maxPriceCents: nil, dedicatedOnly: false)))
    }

    @Test func maxPriceMakesActive() {
        #expect(filtersAreActive(FilterState(radiusKm: nil, maxPriceCents: 3000, dedicatedOnly: false)))
    }

    @Test func dedicatedOnlyMakesActive() {
        #expect(filtersAreActive(FilterState(radiusKm: nil, maxPriceCents: nil, dedicatedOnly: true)))
    }
}
