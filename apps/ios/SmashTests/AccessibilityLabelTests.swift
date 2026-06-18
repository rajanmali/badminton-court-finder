import Testing
@testable import Smash

/// Unit tests for the venue card accessibility label builder.
/// The function is a pure helper; no UI dependencies needed.
struct AccessibilityLabelTests {

    // MARK: - Helpers

    private func makeVenue(
        name: String = "Test Venue",
        suburb: String = "Suburb",
        courtCount: Int = 4,
        dedicatedBadminton: Bool = false,
        distanceKm: Double? = nil,
        priceFrom: Int? = nil
    ) -> VenueListItem {
        VenueListItem(
            id: "test-id",
            name: name,
            suburb: suburb,
            lat: -33.0, lng: 151.0,
            courtCount: courtCount,
            dedicatedBadminton: dedicatedBadminton,
            distanceKm: distanceKm,
            priceFrom: priceFrom,
            hasLiveAvailability: false
        )
    }

    // MARK: - Tests

    @Test("Label includes venue name")
    func labelIncludesName() {
        let venue = makeVenue(name: "Olympic Park Badminton")
        let label = venueCardAccessibilityLabel(venue: venue)
        #expect(label.contains("Olympic Park Badminton"))
    }

    @Test("Dedicated venue includes 'Dedicated badminton venue'")
    func dedicatedVenueIncludesDedicatedLabel() {
        let venue = makeVenue(dedicatedBadminton: true)
        let label = venueCardAccessibilityLabel(venue: venue)
        #expect(label.contains("Dedicated badminton venue"))
    }

    @Test("Non-dedicated venue omits 'Dedicated badminton venue'")
    func nonDedicatedVenueOmitsDedicatedLabel() {
        let venue = makeVenue(dedicatedBadminton: false)
        let label = venueCardAccessibilityLabel(venue: venue)
        #expect(!label.contains("Dedicated badminton venue"))
    }

    @Test("Label includes suburb")
    func labelIncludesSuburb() {
        let venue = makeVenue(suburb: "Parramatta")
        let label = venueCardAccessibilityLabel(venue: venue)
        #expect(label.contains("Parramatta"))
    }

    @Test("Label includes price when available")
    func labelIncludesPrice() {
        let venue = makeVenue(priceFrom: 2900)
        let label = venueCardAccessibilityLabel(venue: venue)
        #expect(label.contains("$29"))
        #expect(label.contains("per hour"))
    }

    @Test("Label omits price when nil")
    func labelOmitsPriceWhenNil() {
        let venue = makeVenue(priceFrom: nil)
        let label = venueCardAccessibilityLabel(venue: venue)
        #expect(!label.contains("per hour"))
    }

    @Test("Label includes court count (plural)")
    func labelIncludesCourtCountPlural() {
        let venue = makeVenue(courtCount: 4)
        let label = venueCardAccessibilityLabel(venue: venue)
        #expect(label.contains("4 courts"))
    }

    @Test("Label includes court count (singular)")
    func labelIncludesCourtCountSingular() {
        let venue = makeVenue(courtCount: 1)
        let label = venueCardAccessibilityLabel(venue: venue)
        #expect(label.contains("1 court"))
        #expect(!label.contains("1 courts"))
    }

    @Test("Label includes distance when available")
    func labelIncludesDistance() {
        let venue = makeVenue(distanceKm: 3.4)
        let label = venueCardAccessibilityLabel(venue: venue)
        #expect(label.contains("kilometres away"))
    }

    @Test("Label omits distance when nil")
    func labelOmitsDistanceWhenNil() {
        let venue = makeVenue(distanceKm: nil)
        let label = venueCardAccessibilityLabel(venue: venue)
        #expect(!label.contains("kilometres"))
    }

    @Test("Full label for dedicated venue with all fields")
    func fullDedicatedLabel() {
        let venue = makeVenue(
            name: "Sydney Olympic Park Badminton Centre",
            suburb: "Olympic Park",
            courtCount: 12,
            dedicatedBadminton: true,
            distanceKm: 3.4,
            priceFrom: 2900
        )
        let label = venueCardAccessibilityLabel(venue: venue)
        #expect(label.contains("Sydney Olympic Park Badminton Centre"))
        #expect(label.contains("Dedicated badminton venue"))
        #expect(label.contains("Olympic Park"))
        #expect(label.contains("$29 per hour"))
        #expect(label.contains("12 courts"))
        #expect(label.contains("kilometres away"))
    }
}
