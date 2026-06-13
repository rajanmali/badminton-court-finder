import Foundation

struct VenueListResponse: Codable, Sendable {
    let venues: [VenueListItem]
}

struct VenueDetailResponse: Codable, Sendable {
    let venue: VenueDetail
}
