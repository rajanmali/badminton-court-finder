import Foundation

struct APIErrorBody: Codable, Sendable {
    let message: String
    let error: String?
    let statusCode: Int

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // NestJS `message` may be a String or [String]; normalise to a single String.
        if let single = try? container.decode(String.self, forKey: .message) {
            message = single
        } else {
            let array = try container.decode([String].self, forKey: .message)
            message = array.joined(separator: ", ")
        }

        error = try container.decodeIfPresent(String.self, forKey: .error)
        statusCode = try container.decode(Int.self, forKey: .statusCode)
    }

    private enum CodingKeys: String, CodingKey {
        case message, error, statusCode
    }
}
