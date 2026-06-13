import Foundation

enum BookingPlatform: String, Codable, Sendable {
    case sportlogic
    case skedda
    case pitchbooking
    case yepbooking
    case council
    case other

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = BookingPlatform(rawValue: raw) ?? .other
    }
}
