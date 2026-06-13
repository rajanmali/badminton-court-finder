import Foundation

struct OpeningHours: Codable, Sendable, Equatable {
    let dayOfWeek: Int
    let openTime: String?
    let closeTime: String?
    let isClosed: Bool
}
