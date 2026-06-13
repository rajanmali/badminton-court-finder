import Foundation

struct VenueDetail: Codable, Identifiable, Sendable, Equatable {
    // Shared with VenueListItem
    let id: String
    let name: String
    let suburb: String
    let lat: Double
    let lng: Double
    let courtCount: Int
    let dedicatedBadminton: Bool
    let distanceKm: Double?
    let priceFrom: Int?
    let hasLiveAvailability: Bool

    // Detail-only fields
    let slug: String
    let address: String
    let phone: String?
    let email: String?
    let bookingUrl: String
    let platform: BookingPlatform
    let rateCards: [RateCard]
    let openingHours: [OpeningHours]
}
