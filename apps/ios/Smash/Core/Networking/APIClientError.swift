import Foundation

/// Typed errors produced by ``APIClient``.
///
/// Conforms to `Sendable` so it can cross actor boundaries without warnings
/// under Swift 6 strict concurrency.
enum APIError: Error, LocalizedError, Sendable {

    /// The URL could not be constructed from the supplied path and base URL.
    case invalidURL

    /// A transport-level failure before any HTTP response was received
    /// (e.g. no network, DNS failure, TLS error, timeout).
    case network(URLError)

    /// The server returned a non-2xx HTTP status code.
    ///
    /// `body` contains the decoded `APIErrorBody` when the response body is
    /// valid JSON that matches the NestJS error shape; `nil` otherwise.
    case http(statusCode: Int, body: APIErrorBody?)

    /// The response body could not be decoded into the expected `Decodable` type.
    case decoding(any Error)

    // MARK: LocalizedError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Could not build a valid request URL. Please check the API configuration."

        case .network(let urlError):
            return "Network error: \(urlError.localizedDescription)"

        case .http(let statusCode, let body):
            // Prefer the decoded server message so the user sees something meaningful.
            if let message = body?.message {
                return message
            }
            return "Server returned HTTP \(statusCode)."

        case .decoding(let error):
            return "Could not parse server response: \(error.localizedDescription)"
        }
    }
}
