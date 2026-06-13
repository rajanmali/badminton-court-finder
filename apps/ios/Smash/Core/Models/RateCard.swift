import Foundation

struct RateCard: Codable, Identifiable, Sendable, Equatable {
    let id: String
    let label: String
    let priceCents: Int
    let daysApply: [String]
    let timeRangeStart: String?
    let timeRangeEnd: String?
    let notes: String?
}
