import Foundation

struct VenueListItem: Codable, Identifiable, Sendable, Equatable {
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
}
