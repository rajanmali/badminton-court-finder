import Foundation

/// A lightweight HTTP client that wraps `URLSession` with typed errors and
/// automatic retry for transient failures.
///
/// ## Retry policy (deliberate refinement vs React Query)
/// React Query retries **all** failures, including deterministic 4xx errors.
/// `APIClient` retries only *transient* failures — `URLError` and 5xx responses
/// — and surfaces 4xx errors (e.g. 404) immediately. Retrying a deterministic
/// "Venue not found" response wastes time and degrades the UX. The
/// user-visible retry-twice behaviour for transient failures is preserved.
///
/// ## Swift 6 concurrency
/// `APIClient` is a plain `struct` and therefore `Sendable`. It holds only
/// value types and a `URLSession`, which is itself `Sendable`. The `get`
/// method is `nonisolated` (structs are nonisolated by default) so callers
/// on any executor — including background actors — do not pay a MainActor hop.
struct APIClient: Sendable {

    // MARK: Properties

    private let baseURL: URL
    private let session: URLSession
    private let retryCount: Int
    private let retryDelay: Duration

    // MARK: Init

    /// Creates an `APIClient`.
    ///
    /// - Parameters:
    ///   - baseURL: Base URL including the path prefix (e.g. `/api/v1`).
    ///              Defaults to the value injected from Info.plist via
    ///              ``AppConfig/apiBaseURL``.
    ///   - session: `URLSession` to use. Defaults to `.shared`. Pass a custom
    ///              session in tests (e.g. one backed by `StubURLProtocol`).
    ///   - retryCount: Number of *additional* attempts after the first failure.
    ///                 Total attempts = `retryCount + 1`. Defaults to `2`
    ///                 (mirrors React Query's `retry: 2`).
    ///   - retryDelay: How long to wait between retry attempts. Defaults to
    ///                 300 ms. Pass `.zero` in tests for speed.
    init(
        baseURL: URL = AppConfig.apiBaseURL,
        session: URLSession = .shared,
        retryCount: Int = 2,
        retryDelay: Duration = .milliseconds(300)
    ) {
        self.baseURL = baseURL
        self.session = session
        self.retryCount = retryCount
        self.retryDelay = retryDelay
    }

    // MARK: Public API

    /// Performs a GET request and decodes the response body as `T`.
    ///
    /// - Parameter path: URL path to append to `baseURL`. Must begin with
    ///   `"/"` (e.g. `"/venues"`, `"/venues/abc-123"`).
    /// - Returns: The decoded value.
    /// - Throws: ``APIError``
    ///
    /// `T` only needs to be `Decodable`; `Sendable` is not required on the
    /// decoded value because `APIClient` itself is `Sendable` and the return
    /// value is consumed by the caller's actor after the `await` point.
    func get<T: Decodable>(_ path: String) async throws -> T {
        // Build the full URL by string-concatenating so that the `/api/v1`
        // prefix on baseURL is not discarded (URL(string:relativeTo:) strips
        // the last path component when relativeTo has a non-empty path and
        // the relative string starts with "/").
        guard let url = URL(string: baseURL.absoluteString + path) else {
            throw APIError.invalidURL
        }

        let request = URLRequest(url: url)
        let decoder = JSONDecoder()
        let maxAttempts = retryCount + 1

        var lastError: APIError?

        for attempt in 1 ... maxAttempts {
            do {
                let (data, response) = try await session.data(for: request)

                guard let http = response as? HTTPURLResponse else {
                    // Unexpected non-HTTP response; treat as a network error.
                    throw APIError.network(URLError(.badServerResponse))
                }

                let status = http.statusCode

                if (200 ..< 300).contains(status) {
                    // Success path — decode immediately; decode errors are NOT retried.
                    do {
                        return try decoder.decode(T.self, from: data)
                    } catch {
                        throw APIError.decoding(error)
                    }
                }

                if (500 ..< 600).contains(status) {
                    // Server error — retryable.
                    let body = try? decoder.decode(APIErrorBody.self, from: data)
                    lastError = .http(statusCode: status, body: body)
                    if attempt < maxAttempts {
                        try await Task.sleep(for: retryDelay)
                        continue
                    }
                    throw lastError!
                }

                // 4xx or any other non-2xx — deterministic failure, do NOT retry.
                let body = try? decoder.decode(APIErrorBody.self, from: data)
                throw APIError.http(statusCode: status, body: body)

            } catch let apiError as APIError {
                // Re-throw typed errors that should not be retried (4xx, decoding).
                throw apiError
            } catch let urlError as URLError {
                // Transport failure — retryable.
                lastError = .network(urlError)
                if attempt < maxAttempts {
                    try await Task.sleep(for: retryDelay)
                    continue
                }
                throw APIError.network(urlError)
            } catch {
                // Unexpected error — surface as a network error.
                throw APIError.network(URLError(.unknown))
            }
        }

        // Unreachable: the loop always either returns or throws.
        throw lastError ?? APIError.network(URLError(.unknown))
    }
}
