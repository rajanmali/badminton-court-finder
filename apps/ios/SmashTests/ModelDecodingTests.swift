import Foundation
import Testing
@testable import Smash

// MARK: - JSON Fixtures

private let venueListJSON = """
{
    "venues": [
        {
            "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
            "name": "Dunc Gray Velodrome Badminton",
            "suburb": "Bass Hill",
            "lat": -33.8996,
            "lng": 150.9997,
            "courtCount": 8,
            "dedicatedBadminton": true,
            "distanceKm": null,
            "priceFrom": 1200,
            "hasLiveAvailability": false
        },
        {
            "id": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
            "name": "Shuttle Zone Indoor",
            "suburb": "Chatswood",
            "lat": -33.7969,
            "lng": 151.1824,
            "courtCount": 4,
            "dedicatedBadminton": true,
            "distanceKm": null,
            "priceFrom": null,
            "hasLiveAvailability": false
        }
    ]
}
"""

private let venueDetailJSON = """
{
    "venue": {
        "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
        "name": "Dunc Gray Velodrome Badminton",
        "suburb": "Bass Hill",
        "lat": -33.8996,
        "lng": 150.9997,
        "courtCount": 8,
        "dedicatedBadminton": true,
        "distanceKm": null,
        "priceFrom": 1200,
        "hasLiveAvailability": false,
        "slug": "dunc-gray-velodrome-badminton",
        "address": "Velodrome Rd, Bass Hill NSW 2197",
        "phone": "+61 2 9644 0400",
        "email": "info@duncgray.com.au",
        "bookingUrl": "https://www.duncgray.com.au/book",
        "platform": "skedda",
        "rateCards": [
            {
                "id": "rc-001",
                "label": "Peak",
                "priceCents": 1400,
                "daysApply": ["mon", "tue", "wed", "thu", "fri"],
                "timeRangeStart": "17:00:00",
                "timeRangeEnd": "21:00:00",
                "notes": "Per court per hour"
            },
            {
                "id": "rc-002",
                "label": "Off-Peak",
                "priceCents": 1000,
                "daysApply": ["sat", "sun"],
                "timeRangeStart": null,
                "timeRangeEnd": null,
                "notes": null
            }
        ],
        "openingHours": [
            {
                "dayOfWeek": 1,
                "openTime": "06:00:00",
                "closeTime": "22:00:00",
                "isClosed": false
            },
            {
                "dayOfWeek": 0,
                "openTime": null,
                "closeTime": null,
                "isClosed": true
            }
        ]
    }
}
"""

private let venueDetailNullContactJSON = """
{
    "venue": {
        "id": "c3d4e5f6-a7b8-9012-cdef-123456789012",
        "name": "Council Courts Parramatta",
        "suburb": "Parramatta",
        "lat": -33.8136,
        "lng": 151.0034,
        "courtCount": 3,
        "dedicatedBadminton": false,
        "distanceKm": null,
        "priceFrom": null,
        "hasLiveAvailability": false,
        "slug": "council-courts-parramatta",
        "address": "1 Council Way, Parramatta NSW 2150",
        "phone": null,
        "email": null,
        "bookingUrl": "",
        "platform": "council",
        "rateCards": [],
        "openingHours": []
    }
}
"""

private let errorStringJSON = """
{"message":"Venue x not found","error":"Not Found","statusCode":404}
"""

private let errorArrayJSON = """
{"message":["a","b"],"error":"Bad Request","statusCode":400}
"""

// MARK: - Tests

@Suite("Model Decoding")
struct ModelDecodingTests {

    private let decoder = JSONDecoder()

    // MARK: VenueListResponse

    @Test("Decodes VenueListResponse with two venues")
    func decodeVenueList() throws {
        let data = try #require(venueListJSON.data(using: .utf8))
        let response = try decoder.decode(VenueListResponse.self, from: data)

        #expect(response.venues.count == 2)

        let first = response.venues[0]
        #expect(first.id == "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
        #expect(first.name == "Dunc Gray Velodrome Badminton")
        #expect(first.suburb == "Bass Hill")
        #expect(first.lat == -33.8996)
        #expect(first.lng == 150.9997)
        #expect(first.courtCount == 8)
        #expect(first.dedicatedBadminton == true)
        #expect(first.distanceKm == nil)
        #expect(first.priceFrom == 1200)
        #expect(first.hasLiveAvailability == false)

        let second = response.venues[1]
        #expect(second.id == "b2c3d4e5-f6a7-8901-bcde-f12345678901")
        #expect(second.priceFrom == nil)
        #expect(second.distanceKm == nil)
    }

    // MARK: VenueDetailResponse

    @Test("Decodes VenueDetailResponse with rate cards and opening hours")
    func decodeVenueDetail() throws {
        let data = try #require(venueDetailJSON.data(using: .utf8))
        let response = try decoder.decode(VenueDetailResponse.self, from: data)
        let venue = response.venue

        #expect(venue.id == "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
        #expect(venue.slug == "dunc-gray-velodrome-badminton")
        #expect(venue.address == "Velodrome Rd, Bass Hill NSW 2197")
        #expect(venue.phone == "+61 2 9644 0400")
        #expect(venue.email == "info@duncgray.com.au")
        #expect(venue.bookingUrl == "https://www.duncgray.com.au/book")
        #expect(venue.platform == .skedda)

        // Rate cards
        #expect(venue.rateCards.count == 2)

        let peak = venue.rateCards[0]
        #expect(peak.id == "rc-001")
        #expect(peak.label == "Peak")
        #expect(peak.priceCents == 1400)
        #expect(peak.daysApply == ["mon", "tue", "wed", "thu", "fri"])
        #expect(peak.timeRangeStart == "17:00:00")
        #expect(peak.timeRangeEnd == "21:00:00")
        #expect(peak.notes == "Per court per hour")

        let offPeak = venue.rateCards[1]
        #expect(offPeak.timeRangeStart == nil)
        #expect(offPeak.timeRangeEnd == nil)
        #expect(offPeak.notes == nil)

        // Opening hours
        #expect(venue.openingHours.count == 2)

        let monday = venue.openingHours[0]
        #expect(monday.dayOfWeek == 1)
        #expect(monday.openTime == "06:00:00")
        #expect(monday.closeTime == "22:00:00")
        #expect(monday.isClosed == false)

        let sunday = venue.openingHours[1]
        #expect(sunday.dayOfWeek == 0)
        #expect(sunday.openTime == nil)
        #expect(sunday.closeTime == nil)
        #expect(sunday.isClosed == true)
    }

    @Test("Decodes VenueDetail with null phone and email")
    func decodeVenueDetailNullContact() throws {
        let data = try #require(venueDetailNullContactJSON.data(using: .utf8))
        let response = try decoder.decode(VenueDetailResponse.self, from: data)
        let venue = response.venue

        #expect(venue.phone == nil)
        #expect(venue.email == nil)
        #expect(venue.bookingUrl == "")
        #expect(venue.platform == .council)
        #expect(venue.rateCards.isEmpty)
        #expect(venue.openingHours.isEmpty)
    }

    // MARK: BookingPlatform

    @Test("Decodes known platform skedda")
    func decodeKnownPlatform() throws {
        let json = #"{"platform":"skedda"}"#
        struct Wrapper: Codable { let platform: BookingPlatform }
        let data = try #require(json.data(using: .utf8))
        let wrapper = try decoder.decode(Wrapper.self, from: data)
        #expect(wrapper.platform == BookingPlatform.skedda)
    }

    @Test("Decodes unknown platform to .other")
    func decodeUnknownPlatformFallsToOther() throws {
        let json = #"{"platform":"bogusplatform"}"#
        struct Wrapper: Codable { let platform: BookingPlatform }
        let data = try #require(json.data(using: .utf8))
        let wrapper = try decoder.decode(Wrapper.self, from: data)
        #expect(wrapper.platform == BookingPlatform.other)
    }

    // MARK: APIErrorBody

    @Test("Decodes 404 error body with string message")
    func decodeErrorBodyStringMessage() throws {
        let data = try #require(errorStringJSON.data(using: .utf8))
        let body = try decoder.decode(APIErrorBody.self, from: data)
        #expect(body.message == "Venue x not found")
        #expect(body.error == "Not Found")
        #expect(body.statusCode == 404)
    }

    @Test("Decodes error body where message is a string array joined by ', '")
    func decodeErrorBodyArrayMessage() throws {
        let data = try #require(errorArrayJSON.data(using: .utf8))
        let body = try decoder.decode(APIErrorBody.self, from: data)
        #expect(body.message == "a, b")
        #expect(body.error == "Bad Request")
        #expect(body.statusCode == 400)
    }
}
