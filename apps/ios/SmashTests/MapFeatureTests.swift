import Testing
@preconcurrency import MapLibre
@testable import Smash

// MARK: - Fixtures

private func makeVenue(
    id: String,
    name: String,
    lat: Double = -33.8688,
    lng: Double = 151.2093,
    dedicated: Bool = false
) -> VenueListItem {
    VenueListItem(
        id: id, name: name, suburb: "Test",
        lat: lat, lng: lng,
        courtCount: 4, dedicatedBadminton: dedicated,
        distanceKm: nil, priceFrom: 3000,
        hasLiveAvailability: false
    )
}

// MARK: - Tests

/// Pins the pure feature-building logic the MapLibre style layers depend on:
/// `dedicated` as an integer 0/1 (data-driven dot colour) and the uppercased
/// first letter (symbol label text). The layers/tap are verified at the parity
/// gate (real key + simulator); here we only assert the testable mapping.
struct MapFeatureTests {

    @Test func attributesEncodeDedicatedAsOne() {
        let attrs = pinAttributes(for: makeVenue(id: "a", name: "Alpha", dedicated: true))
        #expect(attrs["dedicated"] as? Int == 1)
    }

    @Test func attributesEncodeNonDedicatedAsZero() {
        let attrs = pinAttributes(for: makeVenue(id: "b", name: "Bravo", dedicated: false))
        #expect(attrs["dedicated"] as? Int == 0)
    }

    @Test func attributesUppercaseFirstLetter() {
        let attrs = pinAttributes(for: makeVenue(id: "c", name: "courtyard", dedicated: false))
        #expect(attrs["letter"] as? String == "C")
    }

    @Test func attributesCarryIdAndName() {
        let attrs = pinAttributes(for: makeVenue(id: "xyz", name: "Smash Central"))
        #expect(attrs["id"] as? String == "xyz")
        #expect(attrs["name"] as? String == "Smash Central")
    }

    @Test func emptyNameProducesEmptyLetter() {
        let attrs = pinAttributes(for: makeVenue(id: "d", name: ""))
        #expect(attrs["letter"] as? String == "")
    }

    @Test func selectedAttributeIsOneForMatchingID() {
        let attrs = pinAttributes(for: makeVenue(id: "sel", name: "Selected"), selectedID: "sel")
        #expect(attrs["selected"] as? Int == 1)
    }

    @Test func selectedAttributeIsZeroForNonMatchingID() {
        let attrs = pinAttributes(for: makeVenue(id: "a", name: "Alpha"), selectedID: "sel")
        #expect(attrs["selected"] as? Int == 0)
    }

    @Test func selectedAttributeIsZeroWhenNothingSelected() {
        let attrs = pinAttributes(for: makeVenue(id: "a", name: "Alpha"), selectedID: nil)
        #expect(attrs["selected"] as? Int == 0)
    }

    @Test func makePointFeaturesProducesOnePerVenueWithCoordinate() {
        let venues = [
            makeVenue(id: "a", name: "Alpha", lat: -33.5, lng: 151.1, dedicated: true),
            makeVenue(id: "b", name: "Bravo", lat: -34.0, lng: 150.9, dedicated: false),
        ]

        let features = makePointFeatures(venues)

        #expect(features.count == 2)

        #expect(features[0].coordinate.latitude == -33.5)
        #expect(features[0].coordinate.longitude == 151.1)
        #expect(features[0].attribute(forKey: "id") as? String == "a")
        #expect(features[0].attribute(forKey: "dedicated") as? Int == 1)
        #expect(features[0].attribute(forKey: "letter") as? String == "A")

        #expect(features[1].coordinate.latitude == -34.0)
        #expect(features[1].attribute(forKey: "dedicated") as? Int == 0)
    }

    @Test func makePointFeaturesEmptyForEmptyInput() {
        #expect(makePointFeatures([]).isEmpty)
    }
}
